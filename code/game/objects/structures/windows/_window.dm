/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER //Just above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE //initially is 0 for tile smoothing
	flags_1 = ON_BORDER_1
	obj_flags = CAN_BE_HIT | BLOCKS_CONSTRUCTION_DIR | IGNORE_DENSITY

	max_integrity = 50
	can_be_unanchored = TRUE
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/glass_window

	can_atmos_pass = ATMOS_PASS_PROC
	rad_insulation = RAD_VERY_LIGHT_INSULATION
	pass_flags_self = PASSTRANSPARENT
	z_flags = Z_BLOCK_IN_DOWN | Z_BLOCK_IN_UP

	/// Window construction states, by default it's out of frame
	var/state = WINDOW_OUT_OF_FRAME
	/// Is it reinforced with rebars?
	var/reinf = FALSE
	/// is it made of plasma?
	var/plasma_made = FALSE
	/// Heat resistance before it fails (glass melting point is 1400 to 1600 c, or 1673 to 1873 k, but breaks earlier due to thermal stress)
	var/heat_resistance = 800
	/// Deconstruction speed... self explainatory
	var/decon_speed = 30
	/// Is it fulltile or a pane?
	var/fulltile = FALSE
	/// Type of debris when it's broken
	var/glass_type = /obj/item/stack/sheet/glass
	/// How much material is yielded when deconstructed?
	var/glass_amount = 1
	/// Overlay for damaged states, only apply to fulltiles *currently*
	var/mutable_appearance/crack_overlay
	/// Ignore this, just use explosion_block
	var/real_explosion_block
	/// Various sounds effect
	var/breaksound = "shatter"
	var/knocksound = 'sound/effects/glassknock.ogg'
	var/bashsound = 'sound/effects/glassbash.ogg'
	var/hitsound = 'sound/effects/glasshit.ogg'

	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.4

	/// If we added a leaning component to ourselves
	var/added_leaning = FALSE

/obj/structure/window/corner
	icon_state = "window_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/corner/spawner, 0)

/obj/structure/window/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/corner/unanchored/spawner, 0)

/obj/structure/window/examine(mob/user)
	. = ..()
	if(fulltile)
		. += span_notice("That's an unusually <b>big</b> window... Maybe it has an hollow padding?")
	if(reinf)
		. += span_notice("This window is reinforced with rebars.")
		if(anchored && state == WINDOW_SCREWED_TO_FRAME)
			. += span_notice("The window is <b>screwed</b> to the frame.")
		else if(anchored && state == WINDOW_IN_FRAME)
			. += span_notice("The window is <i>unscrewed</i> but <b>pried</b> into the frame.")
		else if(anchored && state == WINDOW_OUT_OF_FRAME)
			. += span_notice("The window is out of the frame, but could be <i>pried</i> in. It is <b>screwed</b> to the floor.")
		else if(!anchored)
			. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")
	else
		if(anchored)
			. += span_notice("The window is <b>screwed</b> to the floor.")
		else
			. += span_notice("The window is <i>unscrewed</i> from the floor, and could be deconstructed by <b>wrenching</b>.")

CREATION_TEST_IGNORE_SUBTYPES(/obj/structure/window)

/obj/structure/window/Initialize(mapload, direct)
	. = ..()
	if(direct)
		setDir(direct)
	if(reinf && anchored)
		state = WINDOW_SCREWED_TO_FRAME

	air_update_turf(TRUE, TRUE)

	if(fulltile)
		setDir()
		obj_flags &= ~BLOCKS_CONSTRUCTION_DIR
		obj_flags &= ~IGNORE_DENSITY
	else
		AddElement(/datum/element/simple_rotation, ROTATION_NEEDS_ROOM, post_rotation_proccall = PROC_REF(post_rotation))

	//windows only block while reinforced and fulltile, so we'll use the proc
	real_explosion_block = explosion_block
	explosion_block = EXPLOSION_BLOCK_PROC

	AddElement(/datum/element/atmos_sensitive)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	if (flags_1 & ON_BORDER_1)
		AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/window/MouseDrop_T(atom/dropping, mob/user, params)
	. = ..()
	if (flags_1 & ON_BORDER_1)
		return

	//Adds the component only once. We do it here & not in Initialize() because there are tons of windows & we don't want to add to their init times
	LoadComponent(/datum/component/leanable, dropping)

/obj/structure/window/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("mode" = RCD_DECONSTRUCT, "delay" = 20, "cost" = 5)
	return FALSE

/obj/structure/window/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	if(passed_mode == RCD_DECONSTRUCT)
		to_chat(user, span_notice("You deconstruct the window."))
		log_attack("[key_name(user)] has deconstructed [src] at [loc_name(src)] using [format_text(initial(the_rcd.name))]")
		qdel(src)
		return TRUE
	return FALSE

/obj/structure/window/narsie_act()
	add_atom_colour(NARSIE_WINDOW_COLOUR, FIXED_COLOUR_PRIORITY)

/obj/structure/window/ratvar_act()
	if(!fulltile)
		new/obj/structure/window/reinforced/clockwork(get_turf(src), dir)
	else
		new/obj/structure/window/fulltile/reinforced/clockwork(get_turf(src))
	qdel(src)

/obj/structure/window/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	..()
	if(anchored && current_size >= STAGE_TWO)
		set_anchored(FALSE)
	if(current_size >= STAGE_FIVE)
		deconstruct(FALSE)

/obj/structure/window/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(!density)
		return TRUE
	if(fulltile)
		return FALSE
	if(border_dir == dir)
		return FALSE
	if(istype(mover, /obj/structure/window))
		var/obj/structure/window/moved_window = mover
		return valid_build_direction(loc, moved_window.dir, is_fulltile = moved_window.fulltile)
	if(istype(mover, /obj/structure/windoor_assembly) || istype(mover, /obj/machinery/door/window))
		return valid_build_direction(loc, mover.dir, is_fulltile = FALSE)
	return TRUE

/obj/structure/window/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(leaving.movement_type & PHASING)
		return
	if(leaving == src)
		return // Let's not block ourselves.
	if (leaving.pass_flags & PASSTRANSPARENT)
		return
	if (fulltile)
		return
	if(direction == dir && density)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/window/attack_tk(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_notice("Something knocks on [src]."))
	add_fingerprint(user)
	playsound(src, knocksound, 50, 1)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/obj/structure/window/attack_hulk(mob/living/carbon/human/user)
	if(!can_be_reached(user))
		return FALSE
	return ..()

/obj/structure/window/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!can_be_reached(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(!user.combat_mode)
		user.visible_message("<span class='notice'>[user] knocks on [src].</span>", \
			"<span class='notice'>You knock on [src].</span>")
		playsound(src, knocksound, 50, TRUE)
	else
		user.visible_message("<span class='warning'>[user] bashes [src]!</span>", \
			"<span class='warning'>You bash [src]!</span>")
		playsound(src, bashsound, 100, TRUE)

/obj/structure/window/attack_paw(mob/user)
	return attack_hand(user)

/obj/structure/window/attack_generic(mob/user, damage_amount = 0, damage_type = BRUTE, damage_flag = 0, sound_effect = 1)	//used by attack_alien, attack_animal, and attack_slime
	if(!can_be_reached(user))
		return
	..()

/obj/structure/window/attackby(obj/item/I, mob/living/user, list/modifiers)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack

	add_fingerprint(user)

	if(I.tool_behaviour == TOOL_WELDER)
		if(atom_integrity < max_integrity)
			if(!I.tool_start_check(user, amount = 0))
				return
			to_chat(user, span_notice("You begin repairing [src]..."))
			if(I.use_tool(src, user, 40, volume = 50))
				atom_integrity = max_integrity
				update_nearby_icons()
				to_chat(user, span_notice("You repair [src]."))
		else
			to_chat(user, span_warning("[src] is already in good condition!"))
		return

	if(!(flags_1&NODECONSTRUCT_1))
		if(I.tool_behaviour == TOOL_SCREWDRIVER)
			I.play_tool_sound(src, 75)
			if(reinf)
				if(state == WINDOW_SCREWED_TO_FRAME || state == WINDOW_IN_FRAME)
					to_chat(user, span_notice("You begin to [state == WINDOW_SCREWED_TO_FRAME ? "unscrew the window from":"screw the window to"] the frame..."))
					if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
						state = (state == WINDOW_IN_FRAME ? WINDOW_SCREWED_TO_FRAME : WINDOW_IN_FRAME)
						to_chat(user, span_notice("You [state == WINDOW_IN_FRAME ? "unfasten the window from":"fasten the window to"] the frame."))
				else if(state == WINDOW_OUT_OF_FRAME)
					to_chat(user, span_notice("You begin to [anchored ? "unscrew the frame from":"screw the frame to"] the floor..."))
					if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
						set_anchored(!anchored)
						to_chat(user, span_notice("You [anchored ? "fasten the frame to":"unfasten the frame from"] the floor."))
			else //if we're not reinforced, we don't need to check or update state
				to_chat(user, span_notice("You begin to [anchored ? "unscrew the window from":"screw the window to"] the floor..."))
				if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_anchored), anchored)))
					set_anchored(!anchored)
					to_chat(user, span_notice("You [anchored ? "fasten the window to":"unfasten the window from"] the floor."))
			return


		else if(I.tool_behaviour == TOOL_CROWBAR && reinf && (state == WINDOW_OUT_OF_FRAME || state == WINDOW_IN_FRAME))
			to_chat(user, span_notice("You begin to lever the window [state == WINDOW_OUT_OF_FRAME ? "into":"out of"] the frame..."))
			I.play_tool_sound(src, 75)
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = (state == WINDOW_OUT_OF_FRAME ? WINDOW_IN_FRAME : WINDOW_OUT_OF_FRAME)
				to_chat(user, span_notice("You pry the window [state == WINDOW_IN_FRAME ? "into":"out of"] the frame."))
			return

		else if(I.tool_behaviour == TOOL_WRENCH && !anchored)
			I.play_tool_sound(src, 75)
			to_chat(user, span_notice(" You begin to disassemble [src]..."))
			if(I.use_tool(src, user, decon_speed, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				new glass_type(user.loc, glass_amount, TRUE, user)
				playsound(src, 'sound/items/Deconstruct.ogg', 50, 1)
				to_chat(user, span_notice("You successfully disassemble [src]."))
				qdel(src)
			return
	return ..()

/obj/structure/window/set_anchored(anchorvalue)
	..()
	air_update_turf(TRUE, anchorvalue)
	update_nearby_icons()

/obj/structure/window/proc/check_state(checked_state)
	if(state == checked_state)
		return TRUE

/obj/structure/window/proc/check_anchored(checked_anchored)
	if(anchored == checked_anchored)
		return TRUE

/obj/structure/window/proc/check_state_and_anchored(checked_state, checked_anchored)
	return check_state(checked_state) && check_anchored(checked_anchored)

/obj/structure/window/proc/can_be_reached(mob/user)
	if(fulltile)
		return TRUE
	var/checking_dir = get_dir(user, src)
	if(!(checking_dir & dir))
		return TRUE // Only windows on the other side may be blocked by other things.
	checking_dir = REVERSE_DIR(checking_dir)
	for(var/obj/blocker in loc)
		if(!blocker.CanPass(user, checking_dir))
			return FALSE
	return TRUE

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, hitsound, 75, 1)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			playsound(src, 'sound/items/Welder.ogg', 100, 1)


/obj/structure/window/deconstruct(disassembled = TRUE)
	if(QDELETED(src))
		return
	if(!disassembled)
		playsound(src, breaksound, 70, 1)
		if(!(flags_1 & NODECONSTRUCT_1))
			for(var/obj/item/shard/debris in spawnDebris(drop_location()))
				transfer_fingerprints_to(debris) // transfer fingerprints to shards only
	qdel(src)
	update_nearby_icons()

/obj/structure/window/proc/spawnDebris(location)
	. = list()
	if (plasma_made)
		. += new /obj/item/shard/plasma(location)
		. += new /obj/effect/decal/cleanable/glass/plasma(location)
		if (fulltile)
			. += new /obj/item/shard/plasma(location)
	else
		. += new /obj/item/shard(location)
		. += new /obj/effect/decal/cleanable/glass(location)
		if (fulltile)
			. += new /obj/item/shard(location)
	if (reinf)
		. += new /obj/item/stack/rods(location, (fulltile ? 2 : 1))

/obj/structure/window/proc/post_rotation(mob/user, degrees)
	air_update_turf(TRUE, FALSE)

/obj/structure/window/Destroy()
	var/turf/local_turf = get_turf(src)
	update_nearby_icons()
	. = ..()
	local_turf.air_update_turf(TRUE, FALSE)

/obj/structure/window/Move()
	var/turf/T = loc
	. = ..()
	if(anchored)
		move_update_air(T)

/obj/structure/window/can_atmos_pass(turf/T, vertical = FALSE)
	if(!anchored || !density)
		return TRUE
	return !(fulltile || dir == get_dir(loc, T))

//This proc is used to update the icons of nearby windows.
/obj/structure/window/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

//merges adjacent full-tile windows into one
/obj/structure/window/update_icon()
	if(!QDELETED(src))
		if(!fulltile)
			return
		var/ratio = atom_integrity / max_integrity
		ratio = ceil(ratio*4) * 25
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
		cut_overlay(crack_overlay)
		if(ratio > 75)
			return
			/*_[rand(0,4)]*/
		crack_overlay = mutable_appearance('icons/obj/structures/windows.dmi', "damage_[ratio]", -(layer+0.1))
		add_overlay(crack_overlay)

/obj/structure/window/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + heat_resistance

/obj/structure/window/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(round(air.return_volume() / 100), BURN, 0, 0)

/obj/structure/window/get_dumping_location()
	return null

/obj/structure/window/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(fulltile || (dir == to_dir))
		return 0
	return 1

/obj/structure/window/GetExplosionBlock()
	return reinf && fulltile ? real_explosion_block : 0

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/spawner, 0)

/obj/structure/window/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/unanchored/spawner, 0)

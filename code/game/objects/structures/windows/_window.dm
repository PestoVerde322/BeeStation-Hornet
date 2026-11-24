/obj/structure/window
	name = "window"
	desc = "A window."
	icon = 'icons/obj/structures/windows.dmi'
	icon_state = "window"
	density = TRUE
	layer = ABOVE_OBJ_LAYER // Above doors
	pressure_resistance = 4*ONE_ATMOSPHERE
	anchored = TRUE
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
	var/decon_speed = 3 SECONDS
	/// Is it fulltile or a pane?
	var/fulltile = FALSE
	/// Does it have a border next to a wall and how many in all cardinalities?
	var/bordWall = FALSE
	var/list/bordWallDir = list()
	/// Does it have a border next to a door and how many in all cardinalities?
	var/bordDoor = FALSE
	var/list/bordDoorDir = list()
	/// Type of debris when it's broken
	var/glass_type = /obj/item/stack/sheet/glass
	/// How much material is yielded when deconstructed?
	var/glass_amount = 1
	/// Overlay for damaged states, only apply to fulltiles *currently*
	var/mutable_appearance/crack_overlay
	/// Overlay for trims, only apply to fulltiles *currently*
	var/mutable_appearance/trim_overlay
	/// Ignore this, just use explosion_block
	var/real_explosion_block
	var/breaksound = "shatter"
	var/knocksound = 'sound/effects/glassknock.ogg'
	var/bashsound = 'sound/effects/glassbash.ogg'
	var/hitsound = 'sound/effects/glasshit.ogg'

	flags_ricochet = RICOCHET_HARD
	ricochet_chance_mod = 0.4

	/// If we added a leaning component to ourselves
	var/added_leaning = FALSE

	///For debug purposes, perhaps, it can stay...
	var/debug_window = TRUE

//merges adjacent full-tile windows into one
/obj/structure/window/update_icon()
	if(!QDELETED(src))
		if(!fulltile)
			return
		if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
			QUEUE_SMOOTH(src)
		var/ratio = atom_integrity / max_integrity
		ratio = ceil(ratio*4) * 25
		cut_overlay(crack_overlay)
		if(ratio <= 75)
			/*_[rand(0,4)]*/
			crack_overlay = mutable_appearance('icons/obj/structures/windows.dmi', "damage_[ratio]", -(layer+0.1))
			add_overlay(crack_overlay)
		windowSmoothLite()

/// Before I get eviscerated by more skilled coders saying "JUST USE 8-BIT SMOOTHING ALREADY", let me learn how to code in dm properly, and really i can't see an instance
/// where *that* was used to append an icon on top of an already smoothing item, or any other case like that really, so...
/obj/structure/window/proc/windowSmoothLite()
	//we will use a 4 dir way, simply to not lose my sanity to use the icon cutter tool,
	//ill adviced and not optimized, but it will do the job
	cut_overlay(trim_overlay)
	var/border_icon = 'icons/obj/structures/windows.dmi'
	if(!anchored)
		return
	for(var/direction in GLOB.cardinals)
		var/turf/closed/adj_turf = get_step(src, direction)
		if(istype(adj_turf, /turf/closed/wall)) //dedicated for walls, anything else goes in the else...
			bordWall = TRUE
			//only used for logging
			bordWallDir += direction
			if(debug_window)
				trim_overlay = mutable_appearance(border_icon, "window_trim_[direction]")
				add_overlay(trim_overlay)
			continue
		else
			for(var/obj/machinery/door/STUCK_DOOR_STUCK_PLEASE_I_BEG_YOU in adj_turf)
				bordDoor = TRUE
				//only used for logging
				bordDoorDir += direction
				if(debug_window)
					trim_overlay = mutable_appearance(border_icon, "window_trim_[direction]")
					add_overlay(trim_overlay)
				continue

//This proc is used to update the icons of nearby windows.eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
/obj/structure/window/proc/update_nearby_icons()
	update_appearance()
	if(smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK))
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/window/examine(mob/user)
	. = ..()
	if(fulltile)
		. += span_notice("That's an unusually <b>big</b> window... Maybe it has an hollow padding?")
		if(debug_window)
			if(bordWall)
				. += span_notice("<b>DEBUG:</b> bordering a wall - dir:")
				for(var/ofWalldirs in bordWallDir)
					. += span_notice("[ofWalldirs]")
			if(bordDoor)
				. += span_notice("<b>DEBUG:</b> bordering a door - dir:")
				for(var/ofDoordirs in bordDoorDir)
					. += span_notice("[ofDoordirs]")
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
		windowSmoothLite() //update_icon just won't do it... don't ask
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

/obj/structure/window/mouse_drop_receive(atom/dropping, mob/user, params)
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

/obj/structure/window/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir, armour_penetration = 0)
	. = ..()
	if(.) //received damage
		update_nearby_icons()

/obj/structure/window/repair_damage(amount)
	. = ..()
	update_nearby_icons()

/obj/structure/window/attackby(obj/item/I, mob/living/user, list/modifiers, list/attack_modifiers)
	if(!can_be_reached(user))
		return TRUE //skip the afterattack
	add_fingerprint(user)
	return ..()

/obj/structure/window/welder_act(mob/living/user, obj/item/tool)
	if(atom_integrity >= max_integrity)
		to_chat(user, span_warning("[src] is already in good condition!"))
		return ITEM_INTERACT_SUCCESS
	if(!tool.tool_start_check(user, amount = 0))
		return FALSE
	to_chat(user, span_notice("You begin repairing [src]..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume = 50))
		repair_damage(max_integrity)
		to_chat(user, span_notice("You repair [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/screwdriver_act(mob/living/user, obj/item/tool)
	switch(state)
		if(WINDOW_SCREWED_TO_FRAME)
			to_chat(user, span_notice("You begin to unscrew the window from the frame..."))
			if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_IN_FRAME
				to_chat(user, span_notice("You unfasten the window from the frame."))
		if(WINDOW_IN_FRAME)
			to_chat(user, span_notice("You begin to screw the window to the frame..."))
			if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_SCREWED_TO_FRAME
				to_chat(user, span_notice("You fasten the window to the frame."))
		if(WINDOW_OUT_OF_FRAME)
			if(anchored)
				to_chat(user, span_notice("You begin to unscrew the frame from the floor..."))
				if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
					set_anchored(FALSE)
					to_chat(user, span_notice("You unfasten the frame from the floor."))
			else
				to_chat(user, span_notice("You begin to screw the frame to the floor..."))
				if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
					set_anchored(TRUE)
					to_chat(user, span_notice("You fasten the frame to the floor."))
			update_nearby_icons()
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/wrench_act(mob/living/user, obj/item/tool)
	if(anchored)
		return FALSE
	if(reinf && state >= WINDOW_OUT_OF_FRAME)
		return FALSE
	to_chat(user, span_notice("You begin to disassemble [src]..."))
	if(!tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
		return ITEM_INTERACT_SUCCESS
	var/obj/item/stack/sheet/G = new glass_type(user.loc, glass_amount)
	if (!QDELETED(G))
		G.add_fingerprint(user)
	playsound(src, 'sound/items/deconstruct.ogg', 50, TRUE)
	to_chat(user, span_notice("You successfully disassemble [src]."))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/window/crowbar_act(mob/living/user, obj/item/tool)
	if(!anchored)
		return FALSE
	switch(state)
		if(WINDOW_IN_FRAME)
			to_chat(user, span_notice("You begin to lever the window out of the frame..."))
			if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_OUT_OF_FRAME
				to_chat(user, span_notice("You pry the window out of the frame."))
		if(WINDOW_OUT_OF_FRAME)
			to_chat(user, span_notice("You begin to lever the window back into the frame..."))
			if(tool.use_tool(src, user, decon_speed, volume = 75, extra_checks = CALLBACK(src, PROC_REF(check_state_and_anchored), state, anchored)))
				state = WINDOW_SCREWED_TO_FRAME
				to_chat(user, span_notice("You pry the window back into the frame."))
		else
			return FALSE
	return ITEM_INTERACT_SUCCESS

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

/obj/structure/window/corner
	icon_state = "window_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/corner/spawner, 0)

/obj/structure/window/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/corner/unanchored/spawner, 0)

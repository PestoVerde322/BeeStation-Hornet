/* Full Tile Windows (more atom_integrity) */

/// Base fulltile window
/obj/structure/window/fulltile
	icon = 'icons/obj/smooth_structures/windows/window.dmi'
	icon_state = "window-0"
	base_icon_state = "window"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_AIRLOCK)
	max_integrity = 100
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1
	obj_flags = CAN_BE_HIT
	glass_amount = 2

/obj/structure/window/fulltile/unanchored
	anchored = FALSE

/obj/structure/window/fulltile/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through. this one has a padding that is flush to the wall."
	icon = 'icons/obj/smooth_structures/windows/plasma_window.dmi'
	icon_state = "plasma_window-0"
	base_icon_state = "plasma_window"
	max_integrity = 600
	plasma_made = TRUE
	armor_type = /datum/armor/plasma_window

/obj/structure/window/fulltile/plasma/unanchored
	anchored = FALSE

//to be converted to ordinary instead of reinforced
/obj/structure/window/fulltile/depleteduranium
	name = "depleted uranium window"
	desc = "A window made out of depleted uranium. It looks perfect for radiation shielding!"
	icon = 'icons/obj/smooth_structures/windows/reinforced_du_window.dmi'
	icon_state = "reinforced_du_window-0"
	base_icon_state = "reinforced_du_window"
	glass_type = /obj/item/stack/sheet/glass //TODO implement DU glass!
	max_integrity = 500
	rad_insulation = RAD_FULL_INSULATION

/obj/structure/window/fulltile/depleteduranium/unanchored
	anchored = FALSE

/obj/structure/window/fulltile/depleteduranium/debug
	name = "unbreakable depleted uranium window"
	max_integrity = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/obj/structure/window/fulltile/paperframe //TODO: finish the bamboo walls that goes alongside this
	name = "paper frame"
	desc = "A fragile separator made of thin wood and paper."
	icon = 'icons/obj/smooth_structures/windows/paperframes.dmi'
	icon_state = "paperframes-0"
	base_icon_state = "paperframes"
	smoothing_groups = list(SMOOTH_GROUP_PAPERFRAME)
	canSmoothWith = list(SMOOTH_GROUP_PAPERFRAME)
	opacity = TRUE
	max_integrity = 25
	glass_type = /obj/item/stack/sheet/paperframes
	heat_resistance = 233
	decon_speed = 10
	can_atmos_pass = ATMOS_PASS_YES
	resistance_flags = FLAMMABLE
	armor_type = /datum/armor/none
	knocksound = "pageturn"
	bashsound = 'sound/weapons/slashmiss.ogg'
	breaksound = 'sound/items/poster_ripped.ogg'
	hitsound = 'sound/weapons/slashmiss.ogg'
	var/static/mutable_appearance/torn = mutable_appearance('icons/obj/smooth_structures/windows/paperframes.dmi',icon_state = "torn", layer = ABOVE_OBJ_LAYER - 0.1)
	var/static/mutable_appearance/paper = mutable_appearance('icons/obj/smooth_structures/windows/paperframes.dmi',icon_state = "paper", layer = ABOVE_OBJ_LAYER - 0.1)

/obj/structure/window/fulltile/paperframe/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/window/fulltile/paperframe/examine(mob/user)
	. = ..()
	if(atom_integrity < max_integrity)
		. += span_info("It looks a bit damaged, you may be able to fix it with some <b>paper</b>.")

/obj/structure/window/fulltile/paperframe/spawnDebris(location)
	. = list(new /obj/item/stack/sheet/wood(location))
	for (var/i in 1 to rand(1,4))
		. += new /obj/item/paper/natural(location)

/obj/structure/window/fulltile/paperframe/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	add_fingerprint(user)
	if(user.combat_mode)
		take_damage(4,BRUTE,MELEE, 0)
		if(!QDELETED(src))
			update_appearance()

/obj/structure/window/fulltile/paperframe/update_icon()
	if(atom_integrity < max_integrity)
		cut_overlay(paper)
		add_overlay(torn)
		set_opacity(FALSE)
	else
		cut_overlay(torn)
		add_overlay(paper)
		set_opacity(TRUE)
	QUEUE_SMOOTH(src)

/obj/structure/window/fulltile/paperframe/attackby(obj/item/W, mob/living/user)
	if(W.get_temperature())
		fire_act(W.get_temperature())
		return
	if(user.combat_mode)
		return ..()
	if(istype(W, /obj/item/paper) && atom_integrity < max_integrity)
		user.visible_message("[user] starts to patch the holes in \the [src].")
		if(do_after(user, 20, target = src))
			atom_integrity = min(atom_integrity+4,max_integrity)
			qdel(W)
			user.visible_message("[user] patches some of the holes in \the [src].")
			if(atom_integrity == max_integrity)
				update_appearance()
			return
	..()
	update_appearance()

/obj/structure/window/fulltile/bronze
	name = "brass window"
	icon = 'icons/obj/smooth_structures/windows/clockwork_window.dmi'
	icon_state = "clockwork_window-0"
	base_icon_state = "clockwork_window"
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE, SMOOTH_GROUP_WINDOW_FULLTILE_BRONZE)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE)
	max_integrity = 50

/obj/structure/window/fulltile/bronze/unanchored
	anchored = FALSE

//TODO unfuck the ratrat windows and items, they do NOT belong under clockwork_turfs.dm!

/// Reinforced fulltile window

/obj/structure/window/fulltile/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with iron rod matrix."
	icon = 'icons/obj/smooth_structures/windows/reinforced_window.dmi'
	icon_state = "reinforced_window-0"
	base_icon_state = "reinforced_window"
	max_integrity = 200
	reinf = TRUE

/obj/structure/window/fulltile/reinforced/unanchored
	anchored = FALSE

/obj/structure/window/fulltile/reinforced/tinted
	icon = 'icons/obj/smooth_structures/windows/reinforced_tinted_window.dmi'
	icon_state = "reinforced_tinted_window-0"
	base_icon_state = "reinforced_tinted_window"

/obj/structure/window/fulltile/reinforced/tinted/nightclub
	color = "#9b1d70"

/obj/structure/window/fulltile/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and an iron rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon = 'icons/obj/smooth_structures/windows/reinforced_plasma_window.dmi'
	icon_state = "reinforced_plasma_window-0"
	base_icon_state = "reinforced_plasma_window"
	plasma_made = TRUE
	max_integrity = 1200 //4000 max integrity is ridicolous, you get TWICE the normal variant, take it or leave it

/obj/structure/window/fulltile/reinforced/plasma/unanchored
	anchored = FALSE

/obj/structure/window/fulltile/reinforced/ice //Currently unused maybe remove?
	name = "frosted reinforced window"
	icon = 'icons/obj/smooth_structures/windows/rice_window.dmi'
	icon_state = "rice_window-0"
	base_icon_state = "rice_window"
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_SHUTTLE_PARTS)
	max_integrity = 150

/obj/structure/window/fulltile/reinforced/shuttle
	name = "shuttle window"
	desc = "A reinforced, air-locked pod window."
	icon = 'icons/obj/smooth_structures/windows/shuttle_window.dmi'
	icon_state = "shuttle_window-0"
	base_icon_state = "shuttle_window"
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_SHUTTLE, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_AIRLOCK)
	max_integrity = 500
	heat_resistance = 1600
	armor_type = /datum/armor/window_titanium
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/titaniumglass
	ricochet_chance_mod = 0.9

/obj/structure/window/fulltile/reinforced/shuttle/unanchored
	anchored = FALSE

/obj/structure/window/fulltile/reinforced/shuttle/narsie_act()
	add_atom_colour("#3C3434", FIXED_COLOUR_PRIORITY)

/obj/structure/window/fulltile/reinforced/shuttle/tinted
	opacity = TRUE

/obj/structure/window/fulltile/reinforced/shuttle/unanchored
	anchored = FALSE

/obj/structure/window/fulltile/reinforced/plasma/plastitanium
	name = "plastitanium window"
	desc = "A durable looking window made of an alloy of of plasma and titanium."
	icon = 'icons/obj/smooth_structures/windows/plastitanium_window.dmi'
	icon_state = "plastitanium_window-0"
	base_icon_state = "plastitanium_window"
	smoothing_groups = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM, SMOOTH_GROUP_SHUTTLE_PARTS)
	canSmoothWith = list(SMOOTH_GROUP_WINDOW_FULLTILE_PLASTITANIUM, SMOOTH_GROUP_WALLS, SMOOTH_GROUP_AIRLOCK)
	max_integrity = 200
	obj_flags = CAN_BE_HIT
	heat_resistance = 1600
	plasma_made = FALSE //IT'S NOT MADE OF PLASMA!
	armor_type = /datum/armor/window_plastitanium
	explosion_block = 3
	glass_type = /obj/item/stack/sheet/plastitaniumglass

/obj/structure/window/fulltile/reinforced/plasma/plastitanium/unanchored
	anchored = FALSE


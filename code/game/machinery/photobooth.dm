/**
 * Photobooth
 * A machine used to change occupant's security record photos, working similarly to a
 * camera, but doesn't give any physical photo to the user.
 * Links to buttons for remote control.
 */
/obj/machinery/photobooth
	name = "photobooth"
	desc = "A machine with some drapes and a camera, used to update security record photos. Requires Law Office access to use."
	icon = 'icons/obj/machines/photobooth.dmi'
	icon_state = "booth_open"
	base_icon_state = "booth"
	var/static/mutable_appearance/top_layer
	state_open = TRUE
	circuit = /obj/item/circuitboard/machine/photobooth
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	light_color = COLOR_OFF_WHITE
	light_power = 1
	light_on = FALSE
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	req_one_access = list(ACCESS_LAWYER, ACCESS_SECURITY)
	///Boolean on whether we should add a height chart to the underlays of the people we take photos of.
	var/add_height_chart = FALSE
	///Boolean on whether the machine is currently busy taking someone's pictures, so you can't start taking pictures while it's working.
	var/taking_pictures = FALSE

	///Name of lighting mask for the vending machine
	var/light_mask

/obj/machinery/photobooth/Initialize(mapload)
	. = ..()
	top_layer = top_layer || mutable_appearance(icon, layer = ABOVE_MOB_LAYER)

/obj/machinery/photobooth/interact(mob/living/user, list/modifiers)
	. = ..()
	if(taking_pictures)
		balloon_alert(user, "machine busy!")
		return
	if(state_open)
		close_machine()
	else
		open_machine()

/obj/machinery/photobooth/AltClick(mob/user, list/modifiers)
	if(taking_pictures)
		balloon_alert(user, "machine busy!")
		return TRUE
	if(occupant)
		if(allowed(user))
			start_taking_pictures()
		else
			balloon_alert(user, "access denied!")
		return TRUE
	return ..()

/obj/machinery/photobooth/close_machine(mob/user, density_to_set = TRUE)
	if(panel_open)
		balloon_alert(user, "close panel first!")
		return
	playsound(src, 'sound/effects/curtain.ogg', 50, TRUE)
	return ..()

/obj/machinery/photobooth/open_machine(drop = TRUE, density_to_set = FALSE)
	playsound(src, 'sound/effects/curtain.ogg', 50, TRUE)
	return ..()

/obj/machinery/photobooth/update_icon_state()
	. = ..()
	if(machine_stat & (BROKEN|NOPOWER))
		icon_state = "[base_icon_state]_off"
	else if(state_open)
		icon_state = "[base_icon_state]_open"
		light_mask = "[base_icon_state]_open_light-mask"
	else
		icon_state = "[base_icon_state]_closed"
		light_mask = "[base_icon_state]_closed_light-mask"

/obj/machinery/photobooth/update_overlays()
	. = ..()
	cut_overlays()
	add_overlay(top_layer)
	top_layer.icon_state = "booth_top"
	if(light_mask && !(machine_stat & BROKEN) && powered())
		. += emissive_appearance(icon, light_mask, layer)
		ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)
	if((machine_stat & MAINT) || panel_open)
		. += "[base_icon_state]_panel"

/obj/machinery/photobooth/update_appearance(updates=ALL)
	. = ..()
	if(machine_stat & BROKEN)
		set_light(0)
		return
	set_light(powered() ? MINIMUM_USEFUL_LIGHT_RANGE : 0)

/obj/machinery/photobooth/screwdriver_act(mob/living/user, obj/item/tool)
	if(!has_buckled_mobs() && default_deconstruction_screwdriver(user, icon_state, icon_state, tool))
		update_appearance(UPDATE_ICON)
		return TRUE
	return ..()

/obj/machinery/photobooth/crowbar_act(mob/living/user, obj/item/tool)
	if(default_deconstruction_crowbar(tool))
		return TRUE
	return ..()

/obj/machinery/photobooth/on_emag(mob/user, obj/item/card/emag/emag_card)
	. = ..()
	if(obj_flags & EMAGGED)
		return FALSE
	req_access = list() //in case someone sets this to something
	req_one_access = list()
	balloon_alert(user, "beeps softly")
	obj_flags |= EMAGGED
	return TRUE

/**
 * Entering & buckling on the photomachine
 */

///The weight action we give to people that buckle themselves to us.
	var/datum/action/push_weights/weight_action

/obj/machinery/photobooth/buckle_mob(mob/living/buckled, force, check_loc, needs_anchored = TRUE)
	. = ..()

/obj/machinery/photobooth/post_buckle_mob(mob/living/buckled)
	weight_action.Grant(buckled)
	buckled.add_overlay(overlay)
	src.cut_overlay(overlay)

/obj/machinery/photobooth/unbuckle_mob(mob/living/buckled_mob, force, can_fall)
	. = ..()
	src.add_overlay(overlay)
	buckled_mob.cut_overlay(overlay)
	weight_action.Remove(buckled_mob)



/**
 * Handles the effects of taking pictures of the user, calling finish_taking_pictures
 * to actually update the records.
 */
/obj/machinery/photobooth/proc/start_taking_pictures()
	taking_pictures = TRUE
	if(obj_flags & EMAGGED)
		var/mob/living/carbon/carbon_occupant = occupant
		for(var/i in 1 to 5) //play a ton of sounds to mimic it blinding you
			playsound(src, pick('sound/items/polaroid1.ogg', 'sound/items/polaroid2.ogg'), 75, TRUE)
			if(carbon_occupant)
				carbon_occupant.flash_act(5)
			sleep(0.2 SECONDS)
		if(carbon_occupant)
			carbon_occupant.emote("scream")
		finish_taking_pictures()
		return
	if(!do_after(occupant, 2 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM)) //gives them time to put their hand items away.
		taking_pictures = FALSE
		return
	playsound(src, 'sound/items/polaroid1.ogg', 75, TRUE)
	//flash()
	if(!do_after(occupant, 3 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
		taking_pictures = FALSE
		return
	playsound(src, 'sound/items/polaroid2.ogg', 75, TRUE)
	//flash()
	if(!do_after(occupant, 2 SECONDS, src, timed_action_flags = IGNORE_HELD_ITEM))
		taking_pictures = FALSE
		return
	finish_taking_pictures()

///Updates the records (if possible), giving feedback, and spitting the user out if all's well.
/obj/machinery/photobooth/proc/finish_taking_pictures()
	taking_pictures = FALSE
	if(!GLOB.manifest.change_pictures(occupant.name, occupant, add_height_chart = add_height_chart))
		balloon_alert(occupant, "record not found!")
		return
	balloon_alert(occupant, "records updated")
	open_machine()

/*
///Mimicing the camera, gives a flash effect by turning the light on and calling flash_end.
/obj/machinery/photobooth/proc/flash()
	set_light_on(TRUE)
	addtimer(CALLBACK(src, PROC_REF(flash_end)), FLASH_LIGHT_DURATION, TIMER_OVERRIDE|TIMER_UNIQUE)

///Called by a timer to turn the light off to end the flash effect.
/obj/machinery/photobooth/proc/flash_end()
	set_light_on(FALSE)
*/

/**
 * Security photobooth
 * Adds a height chart in the background, used for people you want to evidently stick out as prisoners.
 * Good for people you plan on putting in the permabrig.
 */
/obj/machinery/photobooth/security
	name = "security photobooth"
	desc = "A machine with some drapes and a camera, used to update security record photos. Requires Security access to use, and adds a height chart to the person."
	circuit = /obj/item/circuitboard/machine/photobooth/security
	req_one_access = list(ACCESS_SECURITY)
	add_height_chart = TRUE

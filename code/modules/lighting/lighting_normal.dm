//This implements normals, i have genuineley no idea what in the name of all 7 skies i'm doing...
/datum/light_normal
	/// normal to be applied
	var/icon_normal = null

/obj/item/test_normals
	name = "personal Normal device"
	desc = "A device that normally, does not exist. (USE FOR STRICTLY DEBUG REASONS!!!)"
	icon = 'icons/obj/aicards.dmi'
	icon_state = "pai"
	normal_icon_state = "pai_normal"
	inhand_icon_state = "electronic"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

/datum/light_normal/update_overlays()
	. = ..()
	///normals ain't normaling if there's normality
	if(!normal_on || normal_icon_state == null)
		return

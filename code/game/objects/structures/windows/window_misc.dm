/// ANY other type of window thats... not the default one!

/obj/structure/window/reinforced
	name = "reinforced window"
	desc = "A window that is reinforced with iron rod matrix."
	icon_state = "rwindow"
	reinf = TRUE
	heat_resistance = 1600
	armor_type = /datum/armor/glass_window_reinforced
	max_integrity = 100
	explosion_block = 1
	glass_type = /obj/item/stack/sheet/rglass
	rad_insulation = RAD_HEAVY_INSULATION
	ricochet_chance_mod = 0.8

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/spawner, 0)

/obj/structure/window/reinforced/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/unanchored/spawner, 0)

/obj/structure/window/reinforced/corner
	icon_state = "rwindow_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/corner/spawner, 0)

/obj/structure/window/reinforced/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/corner/unanchored/spawner, 0)

/obj/structure/window/plasma
	name = "plasma window"
	desc = "A window made out of a plasma-silicate alloy. It looks insanely tough to break and burn through."
	icon_state = "plasmawindow"
	plasma_made = TRUE
	heat_resistance = 25000
	armor_type = /datum/armor/plasma_window
	max_integrity = 300
	glass_type = /obj/item/stack/sheet/plasmaglass
	rad_insulation = RAD_NO_INSULATION

/obj/structure/window/plasma/Initialize(mapload)
	. = ..()
	RemoveElement(/datum/element/atmos_sensitive)

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/plasma/spawner, 0)

/obj/structure/window/plasma/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/plasma/unanchored/spawner, 0)

/obj/structure/window/plasma/corner
	icon_state = "plasmawindow_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/plasma/corner/spawner, 0)

/obj/structure/window/plasma/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/plasma/corner/unanchored/spawner, 0)

/obj/structure/window/reinforced/plasma
	name = "reinforced plasma window"
	desc = "A window made out of a plasma-silicate alloy and an iron rod matrix. It looks hopelessly tough to break and is most likely nigh fireproof."
	icon_state = "plasmarwindow"
	plasma_made = TRUE
	heat_resistance = 50000
	armor_type = /datum/armor/plasma_window_reinforced
	max_integrity = 500
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/plasmarglass

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/plasma/spawner, 0)

/obj/structure/window/reinforced/plasma/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/plasma/unanchored/spawner, 0)

/obj/structure/window/reinforced/plasma/corner
	icon_state = "plasmarwindow_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/plasma/corner/spawner, 0)

/obj/structure/window/reinforced/plasma/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/plasma/corner/unanchored/spawner, 0)

/obj/structure/window/reinforced/tinted
	name = "tinted window"
	icon_state = "twindow" //what what, hon hon
	opacity = TRUE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tinted/spawner, 0)

/obj/structure/window/reinforced/tinted/corner
	icon_state = "twindow_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tinted/corner/spawner, 0)

/obj/structure/window/reinforced/tinted/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tinted/corner/unanchored/spawner, 0)

/obj/structure/window/reinforced/tinted/frosted
	name = "frosted window"
	icon_state = "twindow"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/reinforced/tinted/frosted/spawner, 0)

/obj/structure/window/depleteduranium
	name = "depleted uranium window"
	desc = "A window made out of depleted uranium. It looks perfect for radiation shielding!"
	icon_state = "duwindow"
	reinf = TRUE
	heat_resistance = 50000
	armor_type = /datum/armor/depleted_uranium_window
	max_integrity = 500
	explosion_block = 2
	glass_type = /obj/item/stack/sheet/mineral/uranium
	rad_insulation = RAD_FULL_INSULATION

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/depleteduranium/spawner, 0)

/obj/structure/window/depleteduranium/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/depleteduranium/unanchored/spawner, 0)

/obj/structure/window/depleteduranium/corner
	icon_state = "duwindow_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/depleteduranium/corner/spawner, 0)

/obj/structure/window/depleteduranium/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/depleteduranium/corner/unanchored/spawner, 0)

/obj/structure/window/bronze
	name = "brass window"
	desc = "A paper-thin pane of translucent yet reinforced brass. Nevermind, this is just weak bronze!"
	icon = 'icons/obj/smooth_structures/windows/clockwork_window.dmi'
	icon_state = "clockwork_window_single"
	glass_type = /obj/item/stack/sheet/bronze

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/bronze/spawner, 0)

/obj/structure/window/bronze/unanchored
	anchored = FALSE

/obj/structure/window/bronze/corner
	icon_state = "clockwork_window_single_corner"
	density = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/bronze/corner/spawner, 0)

/obj/structure/window/bronze/corner/unanchored
	anchored = FALSE

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/window/bronze/corner/unanchored/spawner, 0)

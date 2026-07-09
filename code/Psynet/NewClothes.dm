// ============================
// psynet_clothing.dm - ОДЕЖДА PSYNET (ПОЛНЫЙ ФАЙЛ)
// ============================

/obj/item/clothing/psynet_uniform
	name = "psynet clothing"
	desc = "Одежда Psynet."
	icon = 'icons/obj/clothing/newuniforms.dmi'
	icon_state = ""
	var/icon/inventory_icon = 'icons/obj/clothing/newuniforms.dmi'
	var/inventory_state = ""
	var/icon/male_sprite_file = 'icons/mob/clothing/new_clothes_male.dmi'
	var/icon/female_sprite_file = 'icons/mob/clothing/new_clothes_female.dmi'
	var/list/sleeves_up = list()
	var/list/pants_up = list()
	var/list/torn_parts = list()
	body_parts_covered = UPPER_TORSO|LOWER_TORSO|ARMS|LEGS
	flags = FPRINT | TABLEPASS | ONESIZEFITSALL
	var/overlay_color = null        // Цвет верхнего слоя (RGB строка, например "#FF0000")
	var/base_color = null           // Цвет основной одежды

/obj/item/clothing/psynet_uniform/proc/apply_color_to_icon(icon/I, color)
	if(!color) return I
	var/icon/colored = new(I)
	colored.Blend(color, ICON_MULTIPLY)
	return colored

/obj/item/clothing/psynet_uniform/New()
	..()
	if(inventory_state != "")
		icon = inventory_icon
		icon_state = inventory_state

/obj/item/clothing/psynet_uniform/proc/get_sprite_file(mob/living/carbon/human/H)
	if(!istype(H)) return male_sprite_file
	return (H.gender == MALE) ? male_sprite_file : female_sprite_file

/obj/item/clothing/psynet_uniform/proc/get_sprite(mob/living/carbon/human/H, part)
	if(!istype(H)) return null

	var/state = H.lying ? "_l" : "_s"
	var/base = inventory_state
	if(base == "") base = icon_state
	var/icon/sprite_file = get_sprite_file(H)

	if(part == "body")
		return list("icon" = sprite_file, "icon_state" = "[base]_body_[state]")

	// Проверка конечности — ВОТ ЭТО ВАЖНО
	var/datum/organ/external/limb = H.organs[part]
	if(limb && limb.destroyed)
		return null

	if(torn_parts.Find(part)) return null
	if((part in list("l_arm","r_arm")) && sleeves_up.Find(part)) return null
	if((part in list("l_leg","r_leg")) && pants_up.Find(part)) return null

	return list("icon" = sprite_file, "icon_state" = "[base]_[part]_[state]")

/obj/item/clothing/psynet_uniform/equipped(mob/user, slot)
	..()
	var/mob/living/carbon/human/H = user
	if(!istype(H)) return
	H.update_clothing()

/obj/item/clothing/psynet_uniform/dropped(mob/user)
	..()
	if(istype(user, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = user
		H.update_clothing()

/obj/item/clothing/psynet_uniform/attack_hand(mob/user)
	if(!istype(user, /mob/living/carbon/human)) return ..()
	var/mob/living/carbon/human/H = user
	if(H.a_intent != "grab") return ..()

	var/zone = H.zone_sel?.selecting
	if(!zone) return ..()

	switch(zone)
		if("l_arm")
			if(H.organs["l_arm"] && H.organs["l_arm"]:destroyed)
				H << "<span class='warning'>У вас нет левой руки.</span>"
				return
			if(torn_parts.Find("l_arm"))
				H << "<span class='warning'>Левый рукав уже оторван.</span>"
				return
			if(sleeves_up.Find("l_arm"))
				sleeves_up -= "l_arm"
				H.visible_message("<span class='notice'>[H] опускает левый рукав.</span>")
			else
				sleeves_up |= "l_arm"
				H.visible_message("<span class='notice'>[H] поднимает левый рукав.</span>")

		if("r_arm")
			if(H.organs["r_arm"] && H.organs["r_arm"]:destroyed)
				H << "<span class='warning'>У вас нет правой руки.</span>"
				return
			if(torn_parts.Find("r_arm"))
				H << "<span class='warning'>Правый рукав уже оторван.</span>"
				return
			if(sleeves_up.Find("r_arm"))
				sleeves_up -= "r_arm"
				H.visible_message("<span class='notice'>[H] опускает правый рукав.</span>")
			else
				sleeves_up |= "r_arm"
				H.visible_message("<span class='notice'>[H] поднимает правый рукав.</span>")

		if("l_leg")
			if(H.organs["l_leg"] && H.organs["l_leg"]:destroyed)
				H << "<span class='warning'>У вас нет левой ноги.</span>"
				return
			if(torn_parts.Find("l_leg"))
				H << "<span class='warning'>Левая штанина уже оторвана.</span>"
				return
			if(pants_up.Find("l_leg"))
				pants_up -= "l_leg"
				H.visible_message("<span class='notice'>[H] опускает левую штанину.</span>")
			else
				pants_up |= "l_leg"
				H.visible_message("<span class='notice'>[H] поднимает левую штанину.</span>")

		if("r_leg")
			if(H.organs["r_leg"] && H.organs["r_leg"]:destroyed)
				H << "<span class='warning'>У вас нет правой ноги.</span>"
				return
			if(torn_parts.Find("r_leg"))
				H << "<span class='warning'>Правая штанина уже оторвана.</span>"
				return
			if(pants_up.Find("r_leg"))
				pants_up -= "r_leg"
				H.visible_message("<span class='notice'>[H] опускает правую штанину.</span>")
			else
				pants_up |= "r_leg"
				H.visible_message("<span class='notice'>[H] поднимает правую штанину.</span>")

		else return ..()

	H.update_clothing()

/obj/item/clothing/psynet_uniform/MiddleClick(mob/user)
	if(!istype(user, /mob/living/carbon/human)) return
	var/mob/living/carbon/human/H = user
	if(H.a_intent != "grab") return

	var/zone = H.zone_sel?.selecting
	if(!zone) return

	switch(zone)
		if("l_arm")
			if(H.organs["l_arm"] && H.organs["l_arm"]:destroyed) return
			if(torn_parts.Find("l_arm")) return
			torn_parts |= "l_arm"
			sleeves_up -= "l_arm"
			new /obj/item/clothing/rag(H.loc)
			H.visible_message("<span class='danger'>[H] отрывает левый рукав!</span>")

		if("r_arm")
			if(H.organs["r_arm"] && H.organs["r_arm"]:destroyed) return
			if(torn_parts.Find("r_arm")) return
			torn_parts |= "r_arm"
			sleeves_up -= "r_arm"
			new /obj/item/clothing/rag(H.loc)
			H.visible_message("<span class='danger'>[H] отрывает правый рукав!</span>")

		if("l_leg")
			if(H.organs["l_leg"] && H.organs["l_leg"]:destroyed) return
			if(torn_parts.Find("l_leg")) return
			torn_parts |= "l_leg"
			pants_up -= "l_leg"
			new /obj/item/clothing/rag(H.loc)
			H.visible_message("<span class='danger'>[H] отрывает левую штанину!</span>")

		if("r_leg")
			if(H.organs["r_leg"] && H.organs["r_leg"]:destroyed) return
			if(torn_parts.Find("r_leg")) return
			torn_parts |= "r_leg"
			pants_up -= "r_leg"
			new /obj/item/clothing/rag(H.loc)
			H.visible_message("<span class='danger'>[H] отрывает правую штанину!</span>")

	H.update_clothing()

// ===== ГОТОВАЯ ОДЕЖДА =====
/obj/item/clothing/psynet_uniform/cargo
	name = "cargo uniform"
	desc = "Прочный комбинезон карго."
	icon_state = "zcargo"
	inventory_state = "zcargo"

//ОДЕЖДА МИГРАНТОВ!
/obj/item/clothing/psynet_uniform/migrant
	name = "migrant uniform"
	desc = "Одежда мигранта."
	icon_state = "migrant"
	inventory_state = "migrant"
	base_color = "#4A6B8A"
	overlay_color = "#8B4513"
	var/overlay_state = "migrant_o"

/obj/item/clothing/psynet_uniform/migrant/New()
	..()
	var/icon/base = new /icon(inventory_icon, inventory_state)
	if(base_color)
		base.Blend(base_color, ICON_MULTIPLY)

	var/icon/over = new /icon(inventory_icon, overlay_state)
	if(overlay_color)
		over.Blend(overlay_color, ICON_MULTIPLY)

	base.Blend(over, ICON_OVERLAY)
	icon = base

/obj/item/clothing/psynet_uniform/migrant/blue
	base_color = "#124f9b"
	overlay_color = "#081285"

/obj/item/clothing/psynet_uniform/migrant/red
	base_color = "#994d0f"
	overlay_color = "#781012"

/obj/item/clothing/psynet_uniform/migrant/green
	base_color = "#33AA33"
	overlay_color = "#556633"
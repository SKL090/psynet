// ============================
// gurps_weapons.dm - ОРУЖИЕ С ТИПАМИ УРОНА, ЗВУКАМИ И КРОВАВЫМИ СПРАЙТАМИ
// ============================

/obj/item/weapon/gurps
	name = "gurps weapon"
	desc = "Оружие для GURPS-боёвки."
	icon = 'icons/obj/lwweapons.dmi'
	var/gurps_skill = "brawling"
	var/gurps_damage_type = DAMAGE_CRUSH
	var/gurps_alt_type = null
	var/gurps_current_type = null
	var/gurps_alt_name = ""
	var/gurps_damage_bonus = 0
	var/sharpness = 100
	var/sharpness_max = 100
	var/sharpness_loss_on_hit = 1
	var/gurps_dull_damage_penalty = 2
	var/gurps_metal = TRUE
	var/gurps_damage_mode = "thr"
	var/gurps_damage_modifier = 0
	var/gurps_alt_damage_mode = null
	var/gurps_alt_damage_modifier = null
	var/gurps_accuracy = 0
	var/gurps_min_strength = 6
	var/gurps_twohanded = FALSE
	force = 5

	var/list/hitsound_miss = list('sound/trauma/punchmiss.ogg')
	var/list/hitsound_flesh = list('sound/trauma/punch1.ogg')
	var/list/hitsound_cut = null
	var/list/hitsound_pierce = null
	var/list/hitsound_crush = null
	var/list/parrysound = list('sound/weapons2/parry.ogg')

	var/inhand_state = ""
	var/bloody_inhand_state = ""
	var/bloody_icon_state = ""

/obj/item/weapon/gurps/New()
	..()
	icon = 'icons/obj/lwweapons.dmi'

/obj/item/weapon/gurps/proc/get_miss_sound()
	if(!hitsound_miss || !hitsound_miss.len) return 'sound/trauma/punchmiss.ogg'
	return pick(hitsound_miss)

/obj/item/weapon/gurps/proc/get_hit_sound()
	if(gurps_current_type != null)
		if(gurps_current_type == DAMAGE_PIERCE && hitsound_pierce && hitsound_pierce.len)
			return pick(hitsound_pierce)
		if(gurps_current_type == DAMAGE_CUT && hitsound_cut && hitsound_cut.len)
			return pick(hitsound_cut)
		if(gurps_current_type == DAMAGE_CRUSH && hitsound_crush && hitsound_crush.len)
			return pick(hitsound_crush)
	if(gurps_damage_type == DAMAGE_PIERCE && hitsound_pierce && hitsound_pierce.len)
		return pick(hitsound_pierce)
	if(gurps_damage_type == DAMAGE_CUT && hitsound_cut && hitsound_cut.len)
		return pick(hitsound_cut)
	if(gurps_damage_type == DAMAGE_CRUSH && hitsound_crush && hitsound_crush.len)
		return pick(hitsound_crush)
	if(!hitsound_flesh || !hitsound_flesh.len) return 'sound/trauma/punch1.ogg'
	return pick(hitsound_flesh)

/obj/item/weapon/gurps/proc/get_parry_sound()
	if(!parrysound || !parrysound.len) return 'sound/weapons2/parry.ogg'
	return pick(parrysound)

/obj/item/weapon/gurps/proc/is_edged_mode()
	return gurps_damage_type == DAMAGE_CUT && gurps_current_type != DAMAGE_PIERCE

/obj/item/weapon/gurps/proc/is_dull()
	return is_edged_mode() && sharpness <= 50

/obj/item/weapon/gurps/proc/reduce_sharpness(amount = 1)
	if(!is_edged_mode()) return
	sharpness = max(0, sharpness - amount)

/obj/item/weapon/gurps/proc/get_sharpness_text()
	if(!is_edged_mode()) return null
	if(sharpness > 75) return "Лезвие острое."
	if(sharpness > 50) return "Лезвие слегка затуплено."
	if(sharpness > 0) return "Лезвие тупое."
	return "Лезвие полностью затуплено."

/obj/item/weapon/gurps/proc/get_damage_type()
	if(gurps_current_type != null) return gurps_current_type
	if(is_dull()) return DAMAGE_CRUSH
	return gurps_damage_type

/obj/item/weapon/gurps/proc/get_damage_mode()
	if(gurps_current_type != null && gurps_alt_damage_mode)
		return gurps_alt_damage_mode
	return gurps_damage_mode

/obj/item/weapon/gurps/proc/get_damage_modifier()
	if(gurps_current_type != null && !isnull(gurps_alt_damage_modifier))
		return gurps_alt_damage_modifier
	if(is_dull()) return gurps_damage_modifier - gurps_dull_damage_penalty
	return gurps_damage_modifier

/obj/item/weapon/gurps/proc/make_bloody()
	if(bloody_icon_state)
		icon_state = bloody_icon_state
	if(bloody_inhand_state)
		inhand_state = bloody_inhand_state
		item_state = bloody_inhand_state

/obj/item/weapon/gurps/pickup(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_clothing()

/obj/item/weapon/gurps/dropped(mob/user)
	..()
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_clothing()

/obj/item/weapon/gurps/attack_self(mob/user)
	if(!gurps_alt_type) return
	if(gurps_current_type == null)
		gurps_current_type = gurps_alt_type
		user.visible_message(
			"<span class='notice'>[user] меняет хват [src]. Теперь [gurps_alt_name].</span>",
			"<span class='notice'>Теперь вы будете [gurps_alt_name] врага.</span>"
		)
	else
		gurps_current_type = null
		user.visible_message(
			"<span class='notice'>[user] меняет хват [src] обратно.</span>",
			"<span class='notice'>Вы вернулись к основному типу атаки.</span>"
		)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		H.update_clothing()

// ===== НОЖ =====
/obj/item/weapon/gurps/knife
	name = "Боевой нож"
	desc = "Боевой нож. Острый и надёжный."
	icon_state = "combat"
	item_state = "knife"
	gurps_skill = "knife"
	gurps_damage_type = DAMAGE_CUT
	gurps_alt_type = DAMAGE_PIERCE
	gurps_alt_name = "колоть"
	gurps_damage_bonus = 2
	gurps_damage_mode = "sw"
	gurps_damage_modifier = -3
	gurps_alt_damage_mode = "thr"
	gurps_alt_damage_modifier = -1
	gurps_min_strength = 6
	force = 10
	hitsound_miss = list('sound/trauma/swing/swing_knife1.ogg', 'sound/trauma/swing/swing_knife2.ogg', 'sound/trauma/swing/swing_knife3.ogg')
	hitsound_cut = list('sound/trauma/slash1.ogg', 'sound/trauma/slash2.ogg', 'sound/trauma/slash3.ogg')
	hitsound_pierce = list('sound/trauma/stab1.ogg', 'sound/trauma/stab2.ogg', 'sound/trauma/stab3.ogg')
	parrysound = list('sound/weapons2/parry.ogg')
	inhand_state = "knife"
	bloody_inhand_state = "knifeb"
	bloody_icon_state = "combat_blood"

// ===== МЕЧ =====
/obj/item/weapon/gurps/sword
	name = "Меч"
	desc = "Обоюдоострый меч."
	icon_state = "sword"
	item_state = "claymore"
	gurps_skill = "sword"
	gurps_damage_type = DAMAGE_CUT
	gurps_alt_type = DAMAGE_PIERCE
	gurps_alt_name = "колоть"
	gurps_damage_bonus = 4
	gurps_damage_mode = "sw"
	gurps_damage_modifier = 1
	gurps_alt_damage_mode = "thr"
	gurps_alt_damage_modifier = 1
	gurps_accuracy = 1
	gurps_min_strength = 10
	force = 16
	hitsound_miss = list('sound/trauma/swing/swing_massive.ogg', 'sound/trauma/swing/swing_massive2.ogg', 'sound/trauma/swing/swing_massive3.ogg')
	hitsound_cut = list('sound/trauma/blade_slice1.ogg', 'sound/trauma/blade_slice2.ogg', 'sound/trauma/blade_slice3.ogg')
	hitsound_pierce = list('sound/trauma/stab1.ogg', 'sound/trauma/stab2.ogg', 'sound/trauma/stab3.ogg')
	parrysound = list('sound/weapons2/parry.ogg')
	inhand_state = "claymore"
	bloody_inhand_state = "claymoreb"
	bloody_icon_state = "sword_blood"

// ===== ЖЕЛЕЗНЫЙ КИНЖАЛ =====
/obj/item/weapon/gurps/dagger
	name = "Железный Кинжал"
	desc = "Тонкий кинжал. Только колющие удары."
	icon_state = "dagger"
	item_state = "dagger"
	gurps_skill = "knife"
	gurps_damage_type = DAMAGE_PIERCE
	gurps_damage_bonus = 2
	gurps_damage_mode = "thr"
	gurps_damage_modifier = -1
	gurps_accuracy = 2
	gurps_min_strength = 5
	force = 8
	hitsound_miss = list('sound/trauma/swing/swing_knife1.ogg', 'sound/trauma/swing/swing_knife2.ogg', 'sound/trauma/swing/swing_knife3.ogg')
	hitsound_pierce = list('sound/trauma/stab1.ogg', 'sound/trauma/stab2.ogg', 'sound/trauma/stab3.ogg')
	parrysound = list('sound/weapons2/parry.ogg')
	inhand_state = "dagger"
	bloody_inhand_state = "daggerb"
	bloody_icon_state = "dagger_blood"

// ===== ТОПОР =====
/obj/item/weapon/gurps/axe
	name = "Боевой топор"
	desc = "Тяжёлый боевой топор. Можно ударить обухом."
	icon_state = "combataxe"
	item_state = "hatchet"
	gurps_skill = "axe_club"
	gurps_damage_type = DAMAGE_CUT
	gurps_alt_type = DAMAGE_CRUSH
	gurps_alt_name = "бить обухом"
	gurps_damage_bonus = 8
	gurps_damage_mode = "sw"
	gurps_damage_modifier = 2
	gurps_alt_damage_mode = "sw"
	gurps_alt_damage_modifier = 0
	gurps_accuracy = -1
	gurps_min_strength = 13
	gurps_twohanded = TRUE
	force = 22
	hitsound_miss = list('sound/trauma/swing/swing_massive.ogg')
	hitsound_cut = list('sound/trauma/blade_slice1.ogg')
	hitsound_crush = list('sound/trauma/punch2.ogg')
	parrysound = list('sound/weapons2/parry.ogg')
	inhand_state = "hatchet"
	bloody_inhand_state = "hatchetb"
	bloody_icon_state = "combataxe_blood"

// ===== ДУБИНКА =====
/obj/item/weapon/gurps/club
	name = "Тяжелая палица"
	desc = "Тяжёлая дубинка."
	icon_state = "club"
	item_state = "club"
	gurps_skill = "axe_club"
	gurps_damage_type = DAMAGE_CRUSH
	gurps_metal = FALSE
	gurps_damage_bonus = 4
	gurps_damage_mode = "sw"
	gurps_damage_modifier = 1
	gurps_min_strength = 8
	force = 12
	hitsound_crush = list('sound/trauma/punch2.ogg', 'sound/trauma/punch3.ogg')
	parrysound = list('sound/weapons2/parry.ogg')
	inhand_state = "club"
	bloody_inhand_state = "clubb"
	bloody_icon_state = "club_blood"
/obj/item/weapon/gurps/examine()
	..()
	var/text = get_sharpness_text()
	if(text) usr << "[text] Острота: [sharpness]%."

/obj/item/weapon/gurps/afterattack(atom/target, mob/user, flag)
	..()
	if(!is_edged_mode() || !target || ismob(target)) return
	if((isturf(target) && target.density) || (isobj(target) && target.density))
		reduce_sharpness(2)

// ============================
// gurps_combat.dm - НОВАЯ БОЕВКА (LIFEWEB СТИЛЬ) ФИНАЛ
// ============================

// Типы урона
#define DAMAGE_CUT    1
#define DAMAGE_PIERCE 2
#define DAMAGE_CRUSH  3

// ---------- ВСПОМОГАТЕЛЬНЫЕ ПРОКИ ДЛЯ ЗОН ----------

/proc/gurps_normalize_zone(zone)
	if(!zone) return "chest"
	switch(zone)
		if("eyes", "r_eye", "l_eye") return "head"
		if("mouth", "face") return "head"
		if("neck", "throat") return "neck"
	return zone

/proc/gurps_get_zone_data(zone)
	zone = gurps_normalize_zone(zone)
	var/list/data = list("mod" = 0, "dmg_mult" = 1.0)

	switch(zone)
		if("head")
			data["mod"] = -5
			data["dmg_mult"] = 2.0
		if("r_eye", "l_eye")
			data["mod"] = -9
			data["dmg_mult"] = 2.0
		if("face")
			data["mod"] = -5
			data["dmg_mult"] = 2.0
		if("mouth")
			data["mod"] = -7
			data["dmg_mult"] = 2.0
		if("chest")
			data["mod"] = 0
			data["dmg_mult"] = 1.0
		if("vitals")
			data["mod"] = -3
			data["dmg_mult"] = 1.5
		if("groin")
			data["mod"] = -3
			data["dmg_mult"] = 1.2
		if("r_arm", "l_arm")
			data["mod"] = -2
			data["dmg_mult"] = 0.8
		if("r_hand", "l_hand")
			data["mod"] = -4
			data["dmg_mult"] = 0.5
		if("r_leg", "l_leg")
			data["mod"] = -2
			data["dmg_mult"] = 0.8
		if("r_foot", "l_foot")
			data["mod"] = -4
			data["dmg_mult"] = 0.5
		if("neck")
			data["mod"] = -5
			data["dmg_mult"] = 1.5
	return data

// ---------- БОЕВОЙ РЕЖИМ ----------
/mob/living/carbon/human
	var/gurps_combat_mode = FALSE
	// Новый человек начинает с подготовленным уклонением.
	var/gurps_defense_active = TRUE
	var/obj/screen/gurps_defense_icon = null
	// Number of parries made during the current GURPS one-second turn.
	var/gurps_parry_turn = -1
	var/gurps_parry_count = 0

/mob/living/carbon/human/verb/gurps_toggle_combat_mode()
	set name = "Боевой режим"
	set category = "GURPS"
	gurps_combat_mode = !gurps_combat_mode
	if(gurps_combat_mode)
		src << "<span class='danger'><B>Боевой режим! +1 к атаке и защите.</B></span>"
	else
		src << "<span class='notice'>Вы вышли из боевого режима.</span>"

/mob/living/carbon/human/proc/gurps_combat_bonus()
	if(gurps_combat_mode) return 1
	return 0

/mob/living/carbon/human/proc/gurps_combat_penalty()
	if(!gurps_combat_mode)
		for(var/mob/living/carbon/human/H in view(5, src))
			if(H != src && H.gurps_combat_mode)
				return -1
	return 0

// ---------- АКТИВНАЯ ЗАЩИТА ----------
/mob/living/carbon/human/proc/gurps_update_defense_hud()
	if(!gurps_defense_icon) return
	gurps_defense_icon.icon_state = (gurps_defense_mode == "dodge") ? "dodge1" : "dodge0"

/mob/living/carbon/human/proc/gurps_prepare_defense(mode)
	// Выбранный режим уже постоянно активен: повторный клик ничего не делает.
	if((mode == "dodge" && gurps_defense_mode == "dodge") || (mode == "parry" && gurps_defense_mode != "dodge"))
		return FALSE

	if(mode == "dodge")
		gurps_defense_mode = "dodge"
		gurps_defense_active = TRUE
		gurps_update_defense_hud()
		src << "<span class='notice'>Вы готовитесь уклониться!</span>"
		src.visible_message("<span class='warning'>[src] готовится к активной защите!</span>")
		return TRUE
	var/obj/item/weapon/WPN = (hand ? l_hand : r_hand)
	if(!WPN)
		gurps_defense_mode = "parry_fist"
		gurps_defense_active = TRUE
		gurps_update_defense_hud()
		src << "<span class='notice'>Вы готовитесь парировать руками.</span>"
		return TRUE
	if(WPN.force < 5)
		src << "<span class='warning'>Это оружие слишком лёгкое для парирования!</span>"
		return FALSE
	gurps_defense_mode = "parry"
	gurps_defense_active = TRUE
	gurps_update_defense_hud()
	src << "<span class='notice'>Вы готовитесь парировать [WPN]!</span>"
	return TRUE

/obj/screen/gurps_defense
	name = "gurps_defense"
	icon = 'icons/mob/HUD/lifeweb hud.dmi'
	icon_state = "dodge1"
	mouse_opacity = 1

/obj/screen/gurps_defense/Click(location, control, params)
	if(!ishuman(usr)) return
	var/mob/living/carbon/human/H = usr
	var/list/click_params = params2list(params)
	var/icon_y = text2num(click_params["icon-y"])
	if(icon_y > 16)
		H.gurps_prepare_defense("dodge")
	else
		H.gurps_prepare_defense("parry")

/mob/living/carbon/human/proc/gurps_defense_roll(attacker_skill)
	if(!gurps_defense_active) return list("success" = FALSE)

	var/defense_skill = 0
	if(gurps_defense_mode == "dodge")
		// GURPS 4e: Dodge = floor(Basic Speed) + 3.
		var/basic_speed = (gurps_dexterity + gurps_health) / 4
		defense_skill = (basic_speed - (basic_speed % 1)) + 3
	else if(gurps_defense_mode == "parry_fist")
		// GURPS 4e: Parry = floor(Skill / 2) + 3.
		var/brawling_skill = gurps_get_skill("brawling")
		defense_skill = ((brawling_skill - (brawling_skill % 2)) / 2) + 3
	else if(gurps_defense_mode == "parry")
		var/obj/item/weapon/WPN = (hand ? l_hand : r_hand)
		if(!WPN || WPN.force < 5) return list("success" = FALSE)
		var/parry_skill
		if(istype(WPN, /obj/item/weapon/gurps))
			var/obj/item/weapon/gurps/GW = WPN
			parry_skill = gurps_get_skill(GW.gurps_skill)
		else
			parry_skill = gurps_dexterity - 1
		parry_skill -= gurps_hand_finger_penalty()
		defense_skill = ((parry_skill - (parry_skill % 2)) / 2) + 3
	else
		return list("success" = FALSE)

	if(lying || paralysis) defense_skill -= 3
	else if(stunned) defense_skill -= 4

	// Project-specific modifiers: combat stance remains meaningful.
	defense_skill += gurps_combat_bonus()
	if(!gurps_combat_mode) defense_skill -= 2

	// GURPS 4e: every parry after the first during the same one-second turn
	// receives cumulative -4. Dodge has no equivalent repeat penalty.
	if(gurps_defense_mode != "dodge")
		var/current_turn = world.time - (world.time % 10)
		if(gurps_parry_turn != current_turn)
			gurps_parry_turn = current_turn
			gurps_parry_count = 0
		defense_skill -= gurps_parry_count * 4
		gurps_parry_count++

	var/list/result = gurps_skill_check(defense_skill)
	if(result["success"])
		if(gurps_defense_mode == "parry")
			var/obj/item/weapon/WPN = (hand ? l_hand : r_hand)
			if(WPN && istype(WPN, /obj/item/weapon/gurps))
				var/obj/item/weapon/gurps/GW = WPN
				playsound(src.loc, GW.get_parry_sound(), 60, 1)
			else if(WPN) playsound(src.loc, 'sound/weapons/parry.ogg', 50, 1)
		src << "<span class='notice'>Вы успешно защитились!</span>"
	return result

// ---------- ОТБРАСЫВАНИЕ ----------
/proc/gurps_knockback(mob/living/carbon/human/target, mob/living/carbon/human/attacker, damage, is_crit)
	if(!target || !attacker) return 0
	if(target.stat == 2) return 0

	var/knock_chance = damage * 2
	var/str_diff = attacker.gurps_strength - target.gurps_strength
	knock_chance += str_diff * 5

	if(is_crit)
		knock_chance *= 1.5

	knock_chance = max(5, min(90, knock_chance))

	if(prob(knock_chance))
		var/tiles = 1
		if(damage >= 15) tiles = 2
		if(damage >= 25) tiles = 3
		if(damage >= 35) tiles = 4
		if(damage >= 45) tiles = 5

		if(str_diff >= 4) tiles = min(5, tiles + 1)
		if(str_diff >= 8) tiles = min(5, tiles + 1)
		if(str_diff <= -4) tiles = max(1, tiles - 1)
		if(str_diff <= -8) tiles = max(1, tiles - 1)

		var/dir_to_target = get_dir(attacker, target)

		for(var/i = 1 to tiles)
			var/turf/T = get_step(target, dir_to_target)
			if(T && !T.density)
				target.Move(T)
			else
				target.weakened = max(target.weakened, 3)
				target.stunned = max(target.stunned, 2)
				break

		if(tiles >= 3)
			target.weakened = max(target.weakened, 2)
			target.stunned = max(target.stunned, 2)

		if(tiles >= 5)
			target.weakened = max(target.weakened, 5)
			target.paralysis = max(target.paralysis, 2)

		playsound(target.loc, 'sound/weapons/thudswoosh.ogg', 60, 1)
		return tiles

	return 0

// ---------- ПОЛУЧЕНИЕ ЗОНЫ ----------
/proc/gurps_get_target_zone(mob/living/carbon/human/attacker)
	if(!attacker)
		return gurps_roll_hit_zone()

	if(attacker.zone_sel && istype(attacker.zone_sel, /obj/screen/zone_sel))
		var/obj/screen/zone_sel/Z = attacker.zone_sel
		if(Z.selecting)
			return Z.selecting

	if(attacker.zone_sel2 && istype(attacker.zone_sel2, /obj/screen/zone_sel))
		var/obj/screen/zone_sel/Z = attacker.zone_sel2
		if(Z.selecting)
			return Z.selecting

	return gurps_roll_hit_zone()

// ---------- ОПРЕДЕЛЕНИЕ ТИПА УРОНА ----------
/proc/gurps_get_weapon_dmg_type(obj/item/weapon/W)
	if(!W) return DAMAGE_CRUSH

	if(istype(W, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = W
		return GW.get_damage_type()

	var/wname = lowertext(W.name)

	if(findtext(wname, "screwdriver") || findtext(wname, "отвёртка") || findtext(wname, "отвертка"))
		return DAMAGE_PIERCE
	if(findtext(wname, "spear") || findtext(wname, "копьё") || findtext(wname, "копье"))
		return DAMAGE_PIERCE
	if(findtext(wname, "stiletto") || findtext(wname, "стилет"))
		return DAMAGE_PIERCE

	if(findtext(wname, "knife") || findtext(wname, "нож"))
		return DAMAGE_CUT
	if(findtext(wname, "scalpel") || findtext(wname, "скальпель"))
		return DAMAGE_CUT
	if(findtext(wname, "saw") || findtext(wname, "пила"))
		return DAMAGE_CUT
	if(findtext(wname, "hatchet") || findtext(wname, "топор") || findtext(wname, "axe"))
		return DAMAGE_CUT
	if(findtext(wname, "sword") || findtext(wname, "меч") || findtext(wname, "клинок") || findtext(wname, "blade"))
		return DAMAGE_CUT
	if(findtext(wname, "wirecutter") || findtext(wname, "кусачки"))
		return DAMAGE_CUT
	if(findtext(wname, "circular") || findtext(wname, "циркуляр"))
		return DAMAGE_CUT
	if(findtext(wname, "shard") || findtext(wname, "осколок") || findtext(wname, "стекло"))
		return DAMAGE_CUT

	if(findtext(wname, "hammer") || findtext(wname, "молот") || findtext(wname, "кувалда") || findtext(wname, "sledge"))
		return DAMAGE_CRUSH
	if(findtext(wname, "crowbar") || findtext(wname, "лом"))
		return DAMAGE_CRUSH
	if(findtext(wname, "wrench") || findtext(wname, "ключ"))
		return DAMAGE_CRUSH
	if(findtext(wname, "club") || findtext(wname, "дубина") || findtext(wname, "палица") || findtext(wname, "дубинка"))
		return DAMAGE_CRUSH

	if(W.force >= 12)
		return DAMAGE_CUT

	return DAMAGE_CRUSH

/proc/gurps_is_slashing_weapon(obj/item/weapon/W)
	if(!W) return 0

	if(istype(W, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = W
		return (GW.get_damage_type() == DAMAGE_CUT)

	var/wname = lowertext(W.name)
	if(findtext(wname, "knife") || findtext(wname, "нож")) return 1
	if(findtext(wname, "scalpel") || findtext(wname, "скальпель")) return 1
	if(findtext(wname, "saw") || findtext(wname, "пила")) return 1
	if(findtext(wname, "hatchet") || findtext(wname, "топор") || findtext(wname, "axe")) return 1
	if(findtext(wname, "sword") || findtext(wname, "меч") || findtext(wname, "клинок") || findtext(wname, "blade")) return 1
	if(findtext(wname, "wirecutter") || findtext(wname, "кусачки")) return 1
	if(findtext(wname, "circular") || findtext(wname, "циркуляр")) return 1
	if(findtext(wname, "shard") || findtext(wname, "осколок") || findtext(wname, "стекло")) return 1

	if(W.force >= 15) return 1

	return 0

// ---------- УДАР РУКОЙ ----------
/proc/gurps_target_has_hard_armor(mob/living/carbon/human/H, zone)
	if(!H) return FALSE
	zone = gurps_normalize_zone(zone)
	if(zone == "head") return istype(H.head, /obj/item/clothing/head/helmet)
	if(zone in list("chest", "vitals", "groin"))
		return istype(H.wear_suit, /obj/item/clothing/suit/armor) || istype(H.wear_suit, /obj/item/clothing/suit/swat_suit)
	return FALSE

/proc/gurps_is_metal_weapon(obj/item/weapon/W)
	if(istype(W, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = W
		return GW.gurps_metal
	return W && W.force >= 10

/proc/gurps_unarmed_attack(mob/living/carbon/human/attacker, mob/living/carbon/human/target)
	if(!istype(attacker) || !istype(target)) return
	if(!attacker.gurps_spend_endurance(1)) return

	var/skill = attacker.gurps_get_skill("brawling")
	var/zone = gurps_get_target_zone(attacker)
	var/original_zone = zone

	zone = gurps_normalize_zone(zone)
	var/list/zone_data = gurps_get_zone_data(zone)

	skill += zone_data["mod"]

	if(attacker.lying || attacker.weakened) skill -= 4
	if(target.lying || target.weakened) skill += 4

	skill += attacker.gurps_combat_bonus()
	skill += target.gurps_combat_penalty()

	var/ignore_defense = FALSE
	if(gurps_is_behind_fov(target, attacker))
		skill += 2
		ignore_defense = TRUE

	var/list/attack = gurps_skill_check(skill)

	if(attack["crit_fail"])
		gurps_crit_fail_message(attacker)
		gurps_play_hit_sound(attacker, gurps_get_punch_sound(), 60)
		gurps_play_hit_sound(attacker, gurps_get_miss_sound(), 50)
		if(prob(40))
			var/datum/organ/external/E = attacker.organs[pick("l_arm","r_arm")]
			if(E) E.take_damage(rand(1,5),0,0,DAMAGE_CRUSH,0)
			attacker.UpdateDamageIcon()
			attacker.updatehealth()
		if(prob(25))
			attacker.weakened = max(attacker.weakened,2)
			attacker.visible_message("<span class='danger'>[attacker] теряет равновесие!</span>")
		return

	if(!attack["success"])
		var/ricochet_chance = 15 + (skill / 2)

		if(prob(ricochet_chance) && target.organs.len > 1)
			var/list/other_zones = list()
			for(var/z in target.organs)
				var/datum/organ/external/OE = target.organs[z]
				if(OE && !OE.destroyed && z != zone)
					other_zones += z

			if(other_zones.len > 0)
				var/ricochet_zone = pick(other_zones)
				var/datum/organ/external/RE = target.organs[ricochet_zone]

				if(RE && !RE.destroyed)
					var/ricochet_damage = max(1, round((attacker.gurps_strength - 10) * 0.5 + rand(1, 2)))
					ricochet_damage = round(ricochet_damage * gurps_get_zone_data(ricochet_zone)["dmg_mult"] * 0.5)

					RE.take_damage(ricochet_damage, 0, 0, DAMAGE_CRUSH, 0)

					gurps_play_hit_sound(attacker, gurps_get_punch_sound(), 40)

					gurps_combat_ricochet_message(attacker, target, null, original_zone, ricochet_zone)

					target.UpdateDamageIcon()
					target.updatehealth()
					return

		gurps_combat_miss_message(attacker, target, null, original_zone)
		gurps_play_hit_sound(attacker, gurps_get_miss_sound(), 50)
		return

	if(!ignore_defense && !(target.lying || target.weakened) && target.gurps_defense_active)
		var/list/defense = target.gurps_defense_roll(skill)
		if(defense["success"])
			if(target.gurps_defense_mode == "parry_fist")
				gurps_play_hit_sound(target, 'sound/weapons/punchmiss.ogg', 50)
			gurps_combat_defense_message(attacker, target, null, target.gurps_defense_mode)
			return

	var/damage = gurps_roll_basic_damage(attacker.gurps_strength, "thr")
	damage = round(damage * zone_data["dmg_mult"])
	var/is_crit = attack["crit"]
	if(is_crit) damage *= 2

	if(attacker.gloves && attacker.gloves.force > 0)
		damage += attacker.gloves.force / 2

	var/datum/organ/external/E = target.organs[zone]
	if(!E) E = target.organs["chest"]

	if(E && E.destroyed)
		gurps_combat_destroyed_message(attacker, target, null, original_zone)
		gurps_play_hit_sound(attacker, gurps_get_miss_sound(), 50)
		return

	gurps_play_hit_sound(target, gurps_get_punch_sound(), 50)

	var/was_broken = E.broken
	var/was_artery = E.artery_cut
	var/was_tendon = E.tendon_damaged

	E.take_damage(damage, 0, 0, DAMAGE_CRUSH, is_crit)

	var/effect_msg = gurps_determine_effect(E, was_broken, was_artery, was_tendon, is_crit)

	if(target.stat != 2)
		gurps_knockback(target, attacker, damage, is_crit)

	gurps_combat_hit_message(attacker, target, null, original_zone, damage, DAMAGE_CRUSH, is_crit, effect_msg)

	target.lastattacker = attacker
	target.UpdateDamageIcon()
	target.updatehealth()

// ---------- УДАР ОРУЖИЕМ ----------
/proc/gurps_weapon_attack(mob/living/carbon/human/attacker, mob/living/carbon/human/target, obj/item/weapon, def_zone)
	if(!istype(attacker) || !istype(target)) return
	if(!weapon) return
	if(!istype(weapon, /obj/item/weapon/gurps) && weapon.force <= 0)
		return

	var/stamina = 1
	if(weapon.force >= 15) stamina = 2
	if(weapon.force >= 25) stamina = 3
	if(!attacker.gurps_spend_endurance(stamina)) return

	var/skill_name = "brawling"
	var/dmg_type = gurps_get_weapon_dmg_type(weapon)
	var/is_slash = gurps_is_slashing_weapon(weapon)

	if(istype(weapon, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = weapon
		skill_name = GW.gurps_skill

	var/skill = attacker.gurps_get_skill(skill_name)
	var/finger_penalty = attacker.gurps_hand_finger_penalty()
	if(finger_penalty >= 4)
		attacker << "<span class='warning'>В этой руке слишком мало пальцев, чтобы удержать оружие.</span>"
		attacker.drop_item()
		return
	skill -= finger_penalty

	if(!def_zone)
		def_zone = gurps_get_target_zone(attacker)

	var/original_zone = def_zone
	def_zone = gurps_normalize_zone(def_zone)
	var/list/zone_data = gurps_get_zone_data(def_zone)

	skill += zone_data["mod"]

	if(attacker.lying || attacker.weakened) skill -= 4
	if(target.lying || target.weakened) skill += 4

	skill += attacker.gurps_combat_bonus()
	skill += target.gurps_combat_penalty()

	if(istype(weapon, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = weapon
		skill += GW.gurps_accuracy

	var/ignore_defense = FALSE
	if(gurps_is_behind_fov(target, attacker))
		skill += 2
		ignore_defense = TRUE

	var/list/attack = gurps_skill_check(skill)

	if(attack["crit_fail"])
		gurps_crit_fail_message(attacker)
		if(istype(weapon, /obj/item/weapon/gurps))
			var/obj/item/weapon/gurps/edge_weapon = weapon
			edge_weapon.reduce_sharpness(2)
			var/obj/item/weapon/gurps/GW = weapon
			gurps_play_hit_sound(attacker, GW.get_hit_sound(), 60)
			gurps_play_hit_sound(attacker, GW.get_miss_sound(), 50)
		else
			gurps_play_hit_sound(attacker, gurps_get_punch_sound(), 60)
			gurps_play_hit_sound(attacker, gurps_get_miss_sound(), 50)
		if(prob(40))
			attacker.visible_message("<span class='danger'>[attacker] роняет [weapon]!</span>")
			attacker.drop_item()
		if(prob(30))
			var/datum/organ/external/E = attacker.organs[pick("l_arm","r_arm")]
			if(E) E.take_damage(rand(1,8),0,is_slash,dmg_type,0)
			attacker.UpdateDamageIcon()
			attacker.updatehealth()
		if(prob(20))
			attacker.weakened = max(attacker.weakened,3)
			attacker.visible_message("<span class='danger'>[attacker] теряет равновесие!</span>")
		return

	if(!attack["success"])
		var/ricochet_chance = 10 + (skill / 3)

		if(prob(ricochet_chance) && target.organs.len > 1)
			var/list/other_zones = list()
			for(var/z in target.organs)
				var/datum/organ/external/OE = target.organs[z]
				if(OE && !OE.destroyed && z != def_zone)
					other_zones += z

			if(other_zones.len > 0)
				var/ricochet_zone = pick(other_zones)
				var/datum/organ/external/RE = target.organs[ricochet_zone]

				if(RE && !RE.destroyed)
					var/ricochet_damage = max(1, round(weapon.force * 0.4))
					ricochet_damage = round(ricochet_damage * gurps_get_zone_data(ricochet_zone)["dmg_mult"] * 0.4)

					RE.take_damage(ricochet_damage, 0, is_slash, dmg_type, 0)

					if(istype(weapon, /obj/item/weapon/gurps))
						var/obj/item/weapon/gurps/GW = weapon
						gurps_play_hit_sound(attacker, GW.get_hit_sound(), 40)
					else
						gurps_play_hit_sound(attacker, gurps_get_punch_sound(), 40)

					gurps_combat_ricochet_message(attacker, target, weapon, original_zone, ricochet_zone)

					target.UpdateDamageIcon()
					target.updatehealth()
					return

		gurps_combat_miss_message(attacker, target, weapon, original_zone)
		if(istype(weapon, /obj/item/weapon/gurps))
			var/obj/item/weapon/gurps/GW = weapon
			gurps_play_hit_sound(attacker, GW.get_miss_sound(), 50)
		else
			gurps_play_hit_sound(attacker, gurps_get_miss_sound(), 50)
		return

	if(!ignore_defense && !(target.lying || target.weakened) && target.gurps_defense_active)
		// Голыми руками можно парировать только безоружную атаку. Против ножа
		// и любого вооружённого удара такой бросок защиты не совершается.
		if(target.gurps_defense_mode != "parry_fist")
			var/list/defense = target.gurps_defense_roll(skill)
			if(defense["success"])
				if(istype(weapon, /obj/item/weapon/gurps))
					var/obj/item/weapon/gurps/GW = weapon
					var/obj/item/weapon/defender_weapon = (target.hand ? target.l_hand : target.r_hand)
					if(gurps_is_metal_weapon(defender_weapon)) GW.reduce_sharpness(2)
				gurps_play_hit_sound(target, gurps_get_parry_weapon_sound(), 60)
				gurps_combat_defense_message(attacker, target, weapon, target.gurps_defense_mode)
				return

	var/damage = gurps_roll_weapon_damage(attacker, weapon)
	damage = round(damage * zone_data["dmg_mult"])
	var/is_crit = attack["crit"]
	if(is_crit) damage = round(damage * 1.5)

	var/datum/organ/external/E = target.organs[def_zone]
	if(!E) E = target.organs["chest"]

	if(E && E.destroyed)
		gurps_combat_destroyed_message(attacker, target, weapon, original_zone)
		if(istype(weapon, /obj/item/weapon/gurps))
			var/obj/item/weapon/gurps/GW = weapon
			gurps_play_hit_sound(attacker, GW.get_miss_sound(), 50)
		else
			gurps_play_hit_sound(attacker, gurps_get_miss_sound(), 50)
		return

	if(istype(weapon, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = weapon
		gurps_play_hit_sound(target, GW.get_hit_sound(), 50)
	else
		gurps_play_hit_sound(target, gurps_get_punch_sound(), 50)

	var/was_broken = E.broken
	var/was_artery = E.artery_cut
	var/was_tendon = E.tendon_damaged

	E.take_damage(damage, 0, is_slash, dmg_type, is_crit)

	if(weapon && istype(weapon, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = weapon
		if(gurps_target_has_hard_armor(target, def_zone)) GW.reduce_sharpness(2)
		if(E.broken && !was_broken) GW.reduce_sharpness(2)
		if(E.destroyed) GW.reduce_sharpness(3)
		GW.make_bloody()

	var/effect_msg = gurps_determine_effect(E, was_broken, was_artery, was_tendon, is_crit)

	if(target.stat != 2)
		gurps_knockback(target, attacker, damage, is_crit)

	gurps_combat_hit_message(attacker, target, weapon, original_zone, damage, dmg_type, is_crit, effect_msg)

	target.lastattacker = attacker
	target.UpdateDamageIcon()
	target.updatehealth()

// ---------- ЗОНЫ ПОПАДАНИЯ ----------
/proc/gurps_roll_hit_zone()
	switch(gurps_roll_3d6())
		if(3) return "head"
		if(4) return "r_eye"
		if(5) return "l_eye"
		if(6) return "face"
		if(7) return "mouth"
		if(8) return "neck"
		if(9,10) return "chest"
		if(11) return "vitals"
		if(12) return "groin"
		if(13) return "r_arm"
		if(14) return "l_arm"
		if(15) return "r_hand"
		if(16) return "l_hand"
		if(17) return "r_leg"
		if(18) return "l_leg"
	return "chest"

/proc/gurps_zone_modifier(zone)
	var/list/data = gurps_get_zone_data(zone)
	return data["mod"]

/proc/gurps_zone_damage_mod(zone)
	var/list/data = gurps_get_zone_data(zone)
	return data["dmg_mult"]
// ============================
// gurps_effects.dm - ВСЕ ВИЗУАЛЬНЫЕ, ЗВУКОВЫЕ ЭФФЕКТЫ И СООБЩЕНИЯ (ФИНАЛ)
// ============================

// ---------- КРОВЬ ПРИ ПОПАДАНИИ ----------
/proc/gurps_spawn_hit_blood(mob/living/carbon/human/target, zone, damage)
	if(!target || !isturf(target.loc) || damage < 5) return

	var/obj/decal/cleanable/blood/splatter/S = new(target.loc)
	if(target.dna) S.blood_DNA = target.dna.unique_enzymes
	S.blood_type = target.b_type

	if(damage >= 15)
		for(var/dir in cardinal)
			var/turf/T = get_step(target, dir)
			if(T && !T.density && prob(60))
				var/obj/decal/cleanable/blood/splatter/SS = new(T)
				if(target.dna) SS.blood_DNA = target.dna.unique_enzymes
				SS.blood_type = target.b_type

	// Ordinary hits leave only splatter. Pools are reserved for arterial cuts
	// and severed or ruptured body parts.

// ---------- АРТЕРИАЛЬНЫЙ ФОНТАН ----------
/proc/gurps_spawn_artery_spray(mob/living/carbon/human/H)
	if(!H || !isturf(H.loc)) return

	var/obj/decal/cleanable/blood/pool/P = locate() in H.loc
	if(!P)
		P = new /obj/decal/cleanable/blood/pool(H.loc)
		if(H.dna) P.blood_DNA = H.dna.unique_enzymes
		P.blood_type = H.b_type
		if(H.microorganism) P.microorganism = H.microorganism.getcopy()
	else
		P.add_pool_blood(10)

	for(var/i = 1 to 4)
		var/turf/T = get_step(H, pick(cardinal))
		if(T && !T.density)
			var/obj/decal/cleanable/blood/splatter/S = new(T)
			if(H.dna) S.blood_DNA = H.dna.unique_enzymes
			S.blood_type = H.b_type

	playsound(H.loc, pick('sound/trauma/blood/blood1.ogg', 'sound/trauma/blood/blood2.ogg', 'sound/effects/splat.ogg'), 60, 1)

// ---------- ЗВУКИ ----------
/proc/gurps_play_hit_sound(mob/living/carbon/human/target, sound_file, volume = 50)
	if(!target) return
	if(!isturf(target.loc)) return
	playsound(target.loc, sound_file, volume, 1)

/proc/gurps_get_throat_sound()
	return pick('sound/voice/throat.ogg', 'sound/voice/throat2.ogg', 'sound/voice/throat3.ogg')

/proc/gurps_get_artery_sound()
	return pick('sound/trauma/blood/blood_splat.ogg')

/proc/gurps_get_blood_sound()
	return pick('sound/trauma/blood/blood1.ogg', 'sound/trauma/blood/blood2.ogg', 'sound/effects/splat.ogg')

/proc/gurps_get_chop_sound()
	return pick('sound/trauma/chop.ogg', 'sound/trauma/chop2.ogg', 'sound/trauma/chop3.ogg')

/proc/gurps_get_punch_sound()
	return pick('sound/weapons/punch1.ogg', 'sound/weapons/punch2.ogg', 'sound/weapons/punch3.ogg', 'sound/weapons/punch4.ogg')

/proc/gurps_get_fracture_sound()
	return pick('sound/effects/trauma1.ogg', 'sound/effects/trauma2.ogg', 'sound/effects/trauma3.ogg')

/proc/gurps_get_skull_fracture_sound()
	return pick('sound/trauma/blast.ogg', 'sound/trauma/blast2.ogg', 'sound/trauma/blast3.ogg')

/proc/gurps_get_miss_sound()
	return 'sound/weapons/punchmiss.ogg'

/proc/gurps_get_parry_weapon_sound()
	return pick('sound/weapons2/parry.ogg')

// ---------- НАЗВАНИЯ ЗОН ----------
/proc/gurps_zone_name_combat(zone)
	switch(zone)
		if("head") return pick("голову", "череп", "башку")
		if("mouth") return pick("рот")
		if("eyes") return pick("глаза")
		if("neck", "throat") return pick("шею", "горло", "глотку")
		if("chest") return pick("грудь")
		if("vitals") return pick("живот")
		if("groin") return pick("пах")
		if("l_arm") return pick("левую руку")
		if("r_arm") return pick("правую руку")
		if("l_hand") return pick("левую кисть", "левую ладонь")
		if("r_hand") return pick("правую кисть", "правую ладонь")
		if("l_leg") return pick("левую ногу")
		if("r_leg") return pick("правую ногу")
		if("l_foot") return pick("левую ступню")
		if("r_foot") return pick("правую ступню")
	return zone

// ---------- ПРЕДЛОГ ----------
/proc/gurps_zone_preposition(zone, weapon)
	if(!weapon) return "в"
	if(istype(weapon, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = weapon
		switch(GW.get_damage_type())
			if(DAMAGE_PIERCE) return "в"
			if(DAMAGE_CUT) return "по"
			if(DAMAGE_CRUSH) return "по"
	return "в"

// ---------- ГЛАГОЛЫ АТАКИ ----------
/proc/gurps_attack_verb(obj/item/weapon, zone, damage, dmg_type, crit, miss)
	if(miss)
		if(weapon)
			return pick("размахивает", "замахивается", "бьёт мимо", "не попадает", "промахивается")
		else
			return pick("промахивается", "бьёт в воздух", "не попадает", "замахивается мимо")

	if(!weapon)
		if(crit)
			return pick("с сокрушительной силой бьёт", "обрушивает мощный удар", "проводит сокрушительный апперкот")
		return pick("бьёт", "ударяет", "врезает", "заезжает", "впечатывает", "обрушивает")

	if(dmg_type == DAMAGE_PIERCE)
		if(crit)
			return pick("с грациозным выпадом втыкает", "делает изящный укол", "пронзает точным выпадом", "наносит смертоносный укол")
		return pick("втыкает", "колет", "пронзает", "протыкает", "тычет")

	if(dmg_type == DAMAGE_CUT)
		if(crit)
			return pick("с грациозным замахом рассекает", "наносит глубокий порез", "вспарывает мощным ударом", "рассекает с хрустом")
		return pick("режет", "кромсает", "полосует", "рассекает", "шинкует", "рубит")

	if(dmg_type == DAMAGE_CRUSH)
		if(crit)
			return pick("с сокрушительной силой обрушивает", "наносит сокрушительный удар", "впечатывает со всей дури", "проводит мощный замах")
		return pick("бьёт", "ударяет", "дубасит", "обрушивает", "впечатывает", "прикладывает")

// ============================
// ГЛАВНЫЕ СООБЩЕНИЯ БОЕВКИ
// ============================

// --- СООБЩЕНИЕ ПРОМАХА ---
/proc/gurps_combat_miss_message(mob/attacker, mob/target, obj/item/weapon, intended_zone)
	if(!attacker || !target) return

	var/zone_name = gurps_zone_name_combat(intended_zone)

	if(weapon)
		attacker.visible_message(
			"<span class='warning'>[attacker] замахивается [weapon] в [zone_name] [target], но промахивается!</span>",
			"<span class='warning'>Вы замахиваетесь [weapon] в [zone_name], но промахиваетесь!</span>"
		)
	else
		attacker.visible_message(
			"<span class='warning'>[attacker] бьёт в [zone_name] [target], но промахивается!</span>",
			"<span class='warning'>Вы бьёте в [zone_name], но промахиваетесь!</span>"
		)

// --- СООБЩЕНИЕ РИКОШЕТА ---
/proc/gurps_combat_ricochet_message(mob/attacker, mob/target, obj/item/weapon, intended_zone, actual_zone)
	if(!attacker || !target) return

	var/intended_name = gurps_zone_name_combat(intended_zone)
	var/actual_name = gurps_zone_name_combat(actual_zone)

	if(weapon)
		attacker.visible_message(
			"<span class='warning'>[attacker] целится [weapon] в [intended_name] [target], но промахивается и попадает в [actual_name]!</span>",
			"<span class='warning'>Вы целитесь в [intended_name], но промахиваетесь и попадаете в [actual_name]!</span>"
		)
	else
		attacker.visible_message(
			"<span class='warning'>[attacker] целится в [intended_name] [target], но промахивается и попадает в [actual_name]!</span>",
			"<span class='warning'>Вы целитесь в [intended_name], но промахиваетесь и попадаете в [actual_name]!</span>"
		)

// --- СООБЩЕНИЕ ПОПАДАНИЯ ---
/proc/gurps_combat_hit_message(mob/attacker, mob/target, obj/item/weapon, zone, damage, dmg_type, is_crit, effect_msg)
	if(!attacker || !target) return

	var/verb = gurps_attack_verb(weapon, zone, damage, dmg_type, is_crit, FALSE)
	var/zone_name = gurps_zone_name_combat(zone)
	var/prep = gurps_zone_preposition(zone, weapon)

	var/msg_others = "<span class='danger'>[attacker] [verb]"
	if(weapon) msg_others += " [weapon]"
	msg_others += " [prep] [zone_name] [target].</span>"

	var/msg_self = "<span class='danger'>Вы [verb]"
	if(weapon) msg_self += " [weapon]"
	msg_self += " [prep] [zone_name] [target].</span>"

	if(effect_msg)
		msg_others += " <span class='danger'>[effect_msg]</span>"
		msg_self += " <span class='danger'>[effect_msg]</span>"
	else
		msg_others += " <span class='notice'>Заурядный удар.</span>"
		msg_self += " <span class='notice'>Заурядный удар.</span>"

	target.visible_message(msg_others, msg_self)

// --- СООБЩЕНИЕ УНИЧТОЖЕННОЙ КОНЕЧНОСТИ ---
/proc/gurps_combat_destroyed_message(mob/attacker, mob/target, obj/item/weapon, zone)
	if(!attacker || !target) return

	var/zone_name = gurps_zone_name_combat(zone)

	if(weapon)
		attacker.visible_message(
			"<span class='warning'>[attacker] бьёт [weapon] в [zone_name] [target], но там уже нечего повреждать!</span>",
			"<span class='warning'>Вы бьёте в [zone_name], но там уже нечего повреждать!</span>"
		)
	else
		attacker.visible_message(
			"<span class='warning'>[attacker] бьёт в [zone_name] [target], но там уже нечего повреждать!</span>",
			"<span class='warning'>Вы бьёте в [zone_name], но там уже нечего повреждать!</span>"
		)

// --- СООБЩЕНИЕ ЗАЩИТЫ ---
/proc/gurps_combat_defense_message(mob/attacker, mob/target, obj/item/weapon, defense_type)
	if(!attacker || !target) return

	switch(defense_type)
		if("dodge")
			attacker.visible_message(
				"<span class='warning'>[target] уклоняется от атаки [attacker]!</span>",
				"<span class='notice'>[target] уклонился от вашей атаки!</span>"
			)
		if("parry")
			attacker.visible_message(
				"<span class='warning'>[target] парирует удар [attacker]!</span>",
				"<span class='notice'>[target] парировал ваш удар!</span>"
			)

// --- КРИТИЧЕСКИЙ ПРОВАЛ ---
/proc/gurps_crit_fail_message(mob/attacker)
	if(!attacker) return
	attacker.visible_message(
		"<span class='danger'><B>Критический провал! [attacker] задевает себя!</B></span>",
		"<span class='danger'><B>КРИТИЧЕСКИЙ ПРОВАЛ! Вы задеваете себя!</B></span>"
	)

// --- ОПРЕДЕЛЕНИЕ ЭФФЕКТА ПОПАДАНИЯ ---
/proc/gurps_determine_effect(datum/organ/external/E, was_broken, was_artery, was_tendon, is_crit)
	if(!E) return ""

	if(E.destroyed)
		return "<B>Конечность уничтожена!</B>"

	if(E.broken && !was_broken)
		return "<B>ХРУСТЬ! Кость сломана!</B>"

	if(E.artery_cut && !was_artery)
		return "<B>Артерия разорвана! Кровь фонтанирует!</B>"

	if(E.tendon_damaged && !was_tendon)
		return "<B>Повреждено сухожилие!</B>"

	if(is_crit)
		return "<B>Мощный удар!</B>"

	return ""

// ============================
// ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ
// ============================

/proc/gurps_process_hit_effects(mob/living/carbon/human/target, zone, damage, dmg_type, is_crit, obj/item/weapon, mob/living/carbon/human/attacker)
	if(!target || !zone) return ""
	if(target.stat == 2) return ""

	var/extra_message = ""
	var/has_effect = FALSE

	if(zone in list("neck", "throat"))
		zone = "neck"

	var/datum/organ/external/E = target.organs[zone]
	if(!E) E = target.organs["chest"]
	if(!E || E.destroyed) return ""

	// ===== ШЕЯ/ГОРЛО =====
	if(zone == "neck")
		var/is_slashing = (dmg_type == DAMAGE_CUT)
		var/is_piercing = (dmg_type == DAMAGE_PIERCE)

		if(!has_effect && is_slashing && damage >= 20 && prob(damage * 0.5))
			var/datum/organ/external/head = target.organs["head"]
			if(head && !head.destroyed)
				head.destroyed = 1
				head.droplimb()
				extra_message = "<B>ГОЛОВА ОТРУБЛЕНА!</B>"
				has_effect = TRUE
				gurps_play_hit_sound(target, gurps_get_chop_sound(), 80)
				target.death()
				return extra_message

		if(!has_effect && (is_slashing || is_piercing) && damage >= 8 && prob(damage * 2.0))
			var/datum/organ/external/neck/N = E
			if(N && !N.artery_cut)
				N.artery_cut = 1
				target.bloodloss = max(target.bloodloss, 30)
				extra_message = "<B>Сонная артерия разорвана! Кровь фонтанирует из шеи!</B>"
				has_effect = TRUE
				gurps_play_hit_sound(target, gurps_get_throat_sound(), 70)
				gurps_play_hit_sound(target, gurps_get_artery_sound(), 70)
				target.visible_message(
					"<span class='danger'><B>[target] хватается за горло! Сонная артерия разорвана! Кровь фонтанирует!</B></span>",
					"<span class='danger'><B>Ваша сонная артерия разорвана! Вы хватаетесь за горло! Кровь хлещет!</B></span>"
				)
				gurps_spawn_artery_spray(target)
				target.losebreath += 10
				if(prob(40)) target.paralysis = max(target.paralysis, 15)
				if(prob(20)) target.emote("gasp")

		if(!has_effect && damage >= 5 && prob(damage * 3.0))
			extra_message = "<B>Удар в горло!</B>"
			has_effect = TRUE
			target.losebreath += 5
			target.stunned = max(target.stunned, 3)
			gurps_play_hit_sound(target, gurps_get_throat_sound(), 60)
			target.visible_message(
				"<span class='danger'>[target] хватается за горло, задыхаясь!</span>",
				"<span class='danger'>Удар в горло! Вы не можете дышать!</span>"
			)
			if(prob(30)) target.emote("gasp")

	// ===== УДАР В ЧЕЛЮСТЬ =====
	if(!has_effect && (zone == "face" || zone == "mouth") && damage >= 3 && attacker)
		if(prob(damage * 5))
			var/stun_chance = 40 + ((attacker.gurps_strength - target.gurps_strength) * 4)
			stun_chance = max(20, min(95, stun_chance))

			if(prob(stun_chance))
				extra_message = "<B>ТОЧНЫЙ УДАР В ЧЕЛЮСТЬ! [target] ОГЛУШЕН!</B>"
				target.stunned = max(target.stunned, 10)
				target.weakened = max(target.weakened, 5)
				target.eye_blurry = max(target.eye_blurry, 20)
				target.confused = max(target.confused, 15)
				gurps_play_hit_sound(target, gurps_get_punch_sound(), 60)

				if(prob(attacker.gurps_strength * 3))
					var/teeth = max(1, round(attacker.gurps_strength / 8))
					for(var/i = 1 to teeth)
						var/obj/item/weapon/tooth/T = new(target.loc)
						T.add_blood(target)
						T.throw_at(get_step(target, pick(cardinal)), 2, 1)
					target.visible_message("<span class='danger'>Изо рта [target] вылетают зубы!</span>")
					target.bloodloss += teeth * 2

				has_effect = TRUE
				return extra_message

	// ===== СОТРЯСЕНИЕ МОЗГА =====
	if(!has_effect && zone == "head" && damage >= 8 && prob(damage * 0.8))
		extra_message = "<B>Сотрясение мозга!</B>"
		has_effect = TRUE
		target.confused = max(target.confused, 25)
		target.eye_blurry = max(target.eye_blurry, 20)
		if(prob(35)) target.paralysis = max(target.paralysis, 5)

	// ===== КРИТИЧЕСКОЕ ПОПАДАНИЕ =====
	if(is_crit && !has_effect)
		extra_message = "<B>КРИТИЧЕСКОЕ ПОПАДАНИЕ!</B>"
		has_effect = TRUE
		if(damage >= 15)
			target.weakened = max(target.weakened, 3)
			target.stunned = max(target.stunned, 2)
		if(prob(50)) target.emote("scream")
		gurps_play_hit_sound(target, gurps_get_punch_sound(), 60)

	return extra_message

// ============================
// ПРЕДМЕТ "ЗУБ"
// ============================
/obj/item/weapon/tooth
	name = "выбитый зуб"
	desc = "Человеческий зуб с кровью."
	icon = 'icons/mob/flesh/gore.dmi'
	icon_state = "tooth1"
	w_class = 1
	throwforce = 0
	force = 1
	var/tooth_type = 1

/obj/item/weapon/tooth/New()
	..()
	tooth_type = rand(1, 3)
	icon_state = "tooth[tooth_type]"

/obj/item/weapon/tooth/Move()
	..()
	if(isturf(loc))
		icon_state = "mtooth[tooth_type]"
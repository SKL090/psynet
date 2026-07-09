// ============================
// gurps_core.dm — ЯДРО GURPS (ВЫНОСЛИВОСТЬ ОТ ЗДОРОВЬЯ)
// ============================

/mob/living/carbon/human
	var/gurps_strength = 10
	var/gurps_dexterity = 10
	var/gurps_health = 10
	var/gurps_intelligence = 10
	var/gurps_endurance = 12
	var/gurps_endurance_max = 12
	var/gurps_perception = 10
	var/gurps_defense_mode = "dodge"
	var/list/gurps_combat_skills = list(
		"brawling" = 0,
		"knife" = 0,
		"sword" = 0,
		"axe_club" = 0,
		"spear" = 0,
		"shield" = 0,
		"ranged" = 0
	)
	var/list/gurps_civil_skills = list(
		"firstaid" = 0,
		"surgery" = 0,
		"crafting" = 0,
		"engineering" = 0,
		"lockpicking" = 0,
		"persuasion" = 0,
		"intimidation" = 0,
		"stealth" = 0,
		"athletics" = 0,
		"cooking" = 0
	)

/mob/living/carbon/human/New()
	..()
	// GURPS-переменные инициализируются только если их ещё нет
	if(!gurps_strength) gurps_strength = 10
	if(!gurps_dexterity) gurps_dexterity = 10
	if(!gurps_health) gurps_health = 10
	if(!gurps_intelligence) gurps_intelligence = 10

	gurps_endurance_max = 10 + gurps_health
	gurps_endurance = gurps_endurance_max
	gurps_perception = gurps_intelligence

/mob/living/carbon/human/proc/gurps_update_endurance_max()
	gurps_endurance_max = 10 + gurps_health
	if(gurps_endurance > gurps_endurance_max)
		gurps_endurance = gurps_endurance_max

/mob/living/carbon/human/proc/gurps_regen_endurance()
	if(stat == 2) return
	if(gurps_endurance < gurps_endurance_max)
		if(lying || resting || sleeping)
			gurps_endurance = min(gurps_endurance_max, gurps_endurance + 0.7)
		else
			gurps_endurance = min(gurps_endurance_max, gurps_endurance + 0.4)

/mob/living/carbon/human/proc/gurps_spend_endurance(amount)
	if(gurps_endurance >= amount)
		gurps_endurance -= amount
		return TRUE

	src << "<span class='warning'>Вы слишком устали!</span>"
	if(prob(15))
		weakened = max(weakened, 1)
	return FALSE

/proc/gurps_roll_3d6()
	return rand(1, 6) + rand(1, 6) + rand(1, 6)

/proc/gurps_roll_2d6()
	return rand(1, 6) + rand(1, 6)

/proc/gurps_roll_1d6()
	return rand(1, 6)

/proc/gurps_skill_check(skill_level)
	var/roll = gurps_roll_3d6()

	var/crit_success = FALSE
	var/crit_fail = FALSE

	if(roll <= 4)
		crit_success = TRUE
	else if(roll <= 5 && skill_level >= 15)
		crit_success = TRUE
	else if(roll <= 6 && skill_level >= 16)
		crit_success = TRUE

	if(roll >= 18)
		crit_fail = TRUE
	else if(roll >= 17 && skill_level <= 15)
		crit_fail = TRUE
	else if(roll - skill_level >= 10 && skill_level < 10)
		crit_fail = TRUE

	return list(
		"roll" = roll,
		"success" = (roll <= skill_level && !crit_fail),
		"crit" = crit_success,
		"crit_fail" = crit_fail,
		"skill" = skill_level,
		"margin" = skill_level - roll
	)

/mob/living/carbon/human/proc/gurps_get_skill(skill_name)
	var/base = 0

	if(skill_name in gurps_combat_skills)
		base = gurps_combat_skills[skill_name]

	if(skill_name in gurps_civil_skills)
		base = gurps_civil_skills[skill_name]

	switch(skill_name)
		if("brawling", "knife", "sword", "axe_club", "spear", "shield", "ranged",
		   "stealth", "athletics", "crafting", "lockpicking", "dodge", "parry")
			return gurps_dexterity + base

	switch(skill_name)
		if("firstaid", "surgery", "persuasion", "intimidation", "engineering")
			return gurps_intelligence + base

	return gurps_dexterity + base

/mob/living/carbon/human/proc/gurps_improve_skill(skill_name, amount)
	if(gurps_combat_skills.Find(skill_name))
		gurps_combat_skills[skill_name] = min(6, gurps_combat_skills[skill_name] + amount)
		src << "<span class='notice'>Ваш навык [skill_name] улучшился! ([gurps_combat_skills[skill_name]]/6)</span>"
		return TRUE

	if(gurps_civil_skills.Find(skill_name))
		gurps_civil_skills[skill_name] = min(6, gurps_civil_skills[skill_name] + amount)
		src << "<span class='notice'>Ваш навык [skill_name] улучшился! ([gurps_civil_skills[skill_name]]/6)</span>"
		return TRUE

	return FALSE

/mob/living/carbon/human/proc/gurps_can_use_weapon(obj/item/weapon/W)
	if(!W) return TRUE

	if(istype(W, /obj/item/weapon/gurps))
		var/obj/item/weapon/gurps/GW = W

		if(gurps_strength < GW.gurps_min_strength)
			src << "<span class='warning'>Вам не хватает силы для [GW]! (Нужно: [GW.gurps_min_strength], у вас: [gurps_strength])</span>"
			return FALSE

		if(GW.gurps_twohanded && (l_hand && r_hand))
			src << "<span class='warning'>[GW] требует двух рук!</span>"
			return FALSE

	return TRUE

// ===== АДМИН: ИЗМЕНИТЬ СТАТЫ =====
/obj/admins/proc/gurps_edit_player(mob/living/carbon/human/H)
	if(!istype(H)) return

	var/choice = input("Статы [H.name]:\nST=[H.gurps_strength] DX=[H.gurps_dexterity] HT=[H.gurps_health] IQ=[H.gurps_intelligence]\nEN=[H.gurps_endurance]/[H.gurps_endurance_max]", "GURPS") as null|anything in list(
		"Сила (ST)", "Ловкость (DX)", "Здоровье (HT)", "Интеллект (IQ)", "Восприятие (PR)",
		"Навыки", "Случайные", "Сбросить всё", "Выход"
	)
	if(!choice || choice == "Выход") return

	switch(choice)
		if("Сила (ST)")
			H.gurps_strength = input("Сила:", "GURPS", H.gurps_strength) as num
			H.gurps_strength = max(1, round(H.gurps_strength))
		if("Ловкость (DX)")
			H.gurps_dexterity = input("Ловкость:", "GURPS", H.gurps_dexterity) as num
			H.gurps_dexterity = max(1, round(H.gurps_dexterity))
		if("Здоровье (HT)")
			H.gurps_health = input("Здоровье:", "GURPS", H.gurps_health) as num
			H.gurps_health = max(1, round(H.gurps_health))
			H.gurps_update_endurance_max()
		if("Интеллект (IQ)")
			H.gurps_intelligence = input("Интеллект:", "GURPS", H.gurps_intelligence) as num
			H.gurps_intelligence = max(1, round(H.gurps_intelligence))
			H.gurps_perception = H.gurps_intelligence
		if("Восприятие (PR)")
			H.gurps_perception = input("Восприятие:", "GURPS", H.gurps_perception) as num
			H.gurps_perception = max(1, round(H.gurps_perception))
		if("Навыки")
			gurps_edit_skills(H)
			return
		if("Случайные")
			H.gurps_strength = rand(8, 13)
			H.gurps_dexterity = rand(8, 13)
			H.gurps_health = rand(8, 13)
			H.gurps_intelligence = rand(8, 13)
			H.gurps_update_endurance_max()
			H.gurps_endurance = H.gurps_endurance_max
			H.gurps_perception = H.gurps_intelligence
		if("Сбросить всё")
			H.gurps_strength = 10
			H.gurps_dexterity = 10
			H.gurps_health = 10
			H.gurps_intelligence = 10
			H.gurps_update_endurance_max()
			H.gurps_endurance = H.gurps_endurance_max
			H.gurps_perception = 10
			for(var/s in H.gurps_combat_skills)
				H.gurps_combat_skills[s] = 0
			for(var/s in H.gurps_civil_skills)
				H.gurps_civil_skills[s] = 0

	message_admins("[key_name(usr)] изменил GURPS статы [key_name(H)]: ST=[H.gurps_strength] DX=[H.gurps_dexterity] HT=[H.gurps_health] IQ=[H.gurps_intelligence] EN=[H.gurps_endurance_max]")
	gurps_edit_player(H)

// ===== АДМИН: ИЗМЕНИТЬ НАВЫКИ =====
/obj/admins/proc/gurps_edit_skills(mob/living/carbon/human/H)
	if(!istype(H)) return

	var/choice = input("Категория навыков [H.name]:", "GURPS Skills") as null|anything in list("Боевые", "Гражданские", "Выход")
	if(!choice || choice == "Выход") return

	var/list/skill_list = (choice == "Боевые") ? H.gurps_combat_skills : H.gurps_civil_skills
	var/list/skill_names = list()
	for(var/s in skill_list) skill_names += "[s] ([skill_list[s]]/6)"
	skill_names += "Выход"

	var/skill_choice = input("Навык:", "GURPS Skills") as null|anything in skill_names
	if(!skill_choice || skill_choice == "Выход") return

	var/skill_name = copytext(skill_choice, 1, findtext(skill_choice, " ("))
	var/current = skill_list[skill_name]
	var/new_val = input("[skill_name]: текущий [current]/6", "GURPS Skills", current) as num
	if(isnull(new_val)) return
	new_val = max(0, min(6, round(new_val)))
	skill_list[skill_name] = new_val

	message_admins("[key_name(usr)] изменил навык [skill_name] игрока [key_name(H)]: [current] -> [new_val]")
	gurps_edit_skills(H)
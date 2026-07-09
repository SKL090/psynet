// ============================
// pain.dm - СИСТЕМА БОЛИ + GURPS ИНТЕГРАЦИЯ (ИСПРАВЛЕННАЯ ВЕРСИЯ)
// ============================

/mob/proc/flash_pain()
	if(pain)
		flick("pain", pain)

/mob/proc/flash_weak_pain()
	if(pain)
		flick("weak_pain", pain)

/mob/var/list/pain_stored = list()
/mob/var/last_pain_message = ""
/mob/var/next_pain_time = 0

// ===== ОСНОВНОЙ ПРОК БОЛИ =====
/mob/living/carbon/human/pain(var/partname, var/amount, var/force)
	if(stat != STAT_ALIVE) return
	if(nodamage) return
	if(world.time < next_pain_time && !force) return

	// ===== GURPS: НАКОПЛЕНИЕ БОЛИ =====
	gurps_pain_level = min(100, gurps_pain_level + amount * 0.3)

	// ===== ВЛИЯНИЕ БОЛИ НА ПАРАЛИЧ =====
	if(amount > 10)
		if(paralysis)
			paralysis = max(0, paralysis - round(amount / 10))

	// ===== ВЫРОНИТЬ ПРЕДМЕТ ОТ ОСТРОЙ БОЛИ =====
	if(amount > 50 && prob(amount / 5))
		drop_item()
		visible_message("<span class='warning'>[src] роняет предмет от боли!</span>")

	// ===== СООБЩЕНИЯ О БОЛИ =====
	var/msg
	switch(amount)
		if(1 to 10)
			msg = "<b>Моя [partname] немножечко побаливает."
		if(11 to 90)
			flash_weak_pain()
			msg = "<b><font size=2>Моя [partname] болит"
		if(91 to 10000)
			flash_pain()
			msg = "<b><font size=3>КАКАЯ ДИКАЯ БОЛЬ! Моя [partname]"

	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		src << msg
	next_pain_time = world.time + max(10, 100 - amount)

	// ===== GURPS: РЕАКЦИЯ НА СИЛЬНУЮ БОЛЬ =====
	// КРИТИЧЕСКАЯ БОЛЬ (≥80)
	if(amount >= 80 && prob(25))
		stunned = max(stunned, 6)
		weakened = max(weakened, 3)
		visible_message("<span class='danger'>[src] корчится от невыносимой боли!</span>")
		src << "<span class='danger'>Невыносимая боль! Вы не можете двигаться!</span>"
		emote("agony")

		// Шанс потерять сознание
		if(prob(10))
			visible_message("<span class='danger'>[src] теряет сознание от боли!</span>")
			paralysis = max(paralysis, 15)

	// СИЛЬНАЯ БОЛЬ (≥50)
	else if(amount >= 50 && prob(15))
		weakened = max(weakened, 2)
		src << "<span class='warning'>Боль сковывает движения.</span>"
		if(prob(30))
			emote("groan")
		else
			emote("scream")

	// СРЕДНЯЯ БОЛЬ (≥30)
	else if(amount >= 30 && prob(10))
		if(prob(40))
			emote("groan")

	// ===== GURPS: ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ =====
	// Боль в голове вызывает спутанность
	if(partname == "head" && amount >= 30)
		confused = max(confused, round(amount / 10))
		eye_blurry = max(eye_blurry, round(amount / 15))

	// Боль в ногах замедляет
	if(partname in list("left leg", "right leg", "left foot", "right foot") && amount >= 40)
		if(prob(20))
			weakened = max(weakened, 2)
			visible_message("<span class='warning'>[src] припадает на [partname] от боли.</span>")

	// Боль в руках мешает держать предметы
	if(partname in list("left arm", "right arm", "left hand", "right hand") && amount >= 40)
		if(prob(15))
			drop_item()
			visible_message("<span class='warning'>[src] роняет предмет из-за боли в [partname].</span>")

	// Боль в груди/животе вызывает одышку
	if(partname in list("chest", "groin") && amount >= 40)
		if(prob(10))
			losebreath += 2
			emote("gasp")

// ===== ОБРАБОТКА БОЛИ В LIFE (ВЫЗЫВАЕТСЯ ИЗ humanlife.dm) =====
/mob/living/carbon/human/handle_pain()
	if(stat != STAT_ALIVE) return
	if(nodamage) return

	var/maxdam = 0
	var/datum/organ/external/damaged_organ = null

	// Проверка на существование органов
	if(!organs2 || !organs2.len) return

	for(var/datum/organ/external/E in organs2)
		if(!E || E.destroyed) continue
		var/dam = E.get_damage()
		if(dam > maxdam && (maxdam == 0 || prob(70)))
			damaged_organ = E
			maxdam = dam

	if(damaged_organ)
		pain(damaged_organ.display_name, maxdam, 0)

	// ===== GURPS: ШОК ОТ НАКОПЛЕННОГО УРОНА =====
	if(maxdam >= 80 && prob(2))
		stunned = max(stunned, 6)
		weakened = max(weakened, 3)
		visible_message("<span class='danger'>[src] поддаётся боли от ран!</span>")
		emote("agony")

		if(prob(5))
			visible_message("<span class='danger'>[src] теряет сознание от болевого шока!</span>")
			paralysis = max(paralysis, 20)

	else if(maxdam >= 50 && prob(3))
		weakened = max(weakened, 2)
		visible_message("<span class='warning'>[src] стонет от боли.</span>")
		emote("groan")

	// ===== GURPS: НАКОПЛЕННАЯ БОЛЬ ОТ МНОЖЕСТВЕННЫХ РАН =====
	var/total_damage = 0
	for(var/datum/organ/external/E in organs2)
		if(E && !E.destroyed)
			total_damage += E.get_damage()

	// Если суммарный урон > 100, добавляем эффекты
	if(total_damage > 100)
		if(prob(3))
			src << "<span class='danger'>Вы чувствуете, как всё ваше тело кричит от боли!</span>"
			confused = max(confused, 5)
			eye_blurry = max(eye_blurry, 5)

		if(total_damage > 150 && prob(2))
			visible_message("<span class='danger'>[src] падает от истощения и боли!</span>")
			weakened = max(weakened, 10)
			paralysis = max(paralysis, 5)

	// ===== GURPS: ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ БОЛИ =====
	gurps_handle_pain_effects()

	// ===== БОЛЬ ОТ КРОВОТЕЧЕНИЯ =====
	if(bloodloss > 10 && prob(5))
		gurps_bleeding_pain()

	// ===== СНИЖЕНИЕ НАКОПЛЕННОЙ БОЛИ СО ВРЕМЕНЕМ =====
	if(gurps_pain_level > 0 && prob(10))
		gurps_pain_level = max(0, gurps_pain_level - 1)

// ===== НОВОЕ: БОЛЬ ОТ ПЕРЕЛОМОВ (ВЫЗЫВАЕТСЯ ИЗ neworgans.dm) =====
/proc/gurps_fracture_pain(mob/living/carbon/human/H, zone, severity)
	if(!H) return

	var/zone_name = gurps_zone_name_combat(zone)
	var/amount = 0

	switch(severity)
		if(1) // Трещина
			amount = 30 + rand(0, 20)
		if(2) // Перелом
			amount = 60 + rand(0, 30)
		if(3) // Смертельный
			amount = 90 + rand(0, 40)

	H.pain(zone_name, amount, 1) // force = 1, чтобы игнорировать таймер

// ===== НОВОЕ: БОЛЬ ОТ КРОВОТЕЧЕНИЯ =====
/mob/living/carbon/human/proc/gurps_bleeding_pain()
	if(bloodloss < 10) return

	var/amount = bloodloss / 2
	var/part = "тело"

	// Находим самую кровоточащую зону (используем датумы органов)
	var/max_bleed = 0
	for(var/organ_name in organs)
		var/datum/organ/external/E = organs[organ_name]
		if(E && E.artery_cut)
			var/bleed_amount = 50 // Артериальное кровотечение
			if(bleed_amount > max_bleed)
				max_bleed = bleed_amount
				part = E.display_name
		if(E && E.bleeding)
			var/bleed_amount = 20 // Обычное кровотечение
			if(bleed_amount > max_bleed)
				max_bleed = bleed_amount
				part = E.display_name

	if(amount > 20 && prob(5))
		pain(part, amount, 0)

// ===== НОВОЕ: БОЛЬ ОТ ОРГАНОВ =====
/proc/gurps_organ_pain(mob/living/carbon/human/H, organ_name, severity)
	if(!H) return

	var/amount = 0
	switch(severity)
		if("bruised")
			amount = 15 + rand(0, 15)
		if("damaged")
			amount = 35 + rand(0, 20)
		if("ruptured")
			amount = 60 + rand(0, 30)
		if("destroyed")
			amount = 90 + rand(0, 40)

	H.pain(organ_name, amount, 1)

// ===== НОВОЕ: ДОПОЛНИТЕЛЬНЫЕ ЭФФЕКТЫ БОЛИ =====
/mob/living/carbon/human/proc/gurps_handle_pain_effects()
	if(stat != STAT_ALIVE) return
	if(nodamage) return

	// ===== 1. БОЛЬ В ГОЛОВЕ =====
	var/datum/organ/external/head = organs["head"]
	if(head && !head.destroyed)
		var/dam = head.get_damage()
		if(dam >= 30)
			confused = max(confused, round(dam / 15))
			eye_blurry = max(eye_blurry, round(dam / 20))
		if(dam >= 50 && prob(5))
			visible_message("<span class='danger'>[src] держится за голову от боли!</span>")
			emote("scream")
			weakened = max(weakened, 2)

	// ===== 2. БОЛЬ В НОГАХ =====
	var/has_leg_pain = FALSE
	for(var/zone in list("l_leg", "r_leg", "l_foot", "r_foot"))
		var/datum/organ/external/E = organs[zone]
		if(E && !E.destroyed && E.get_damage() >= 40)
			has_leg_pain = TRUE
			break

	if(has_leg_pain && prob(10))
		weakened = max(weakened, 2)
		if(prob(20))
			visible_message("<span class='warning'>[src] прихрамывает от боли в ногах.</span>")

	// ===== 3. БОЛЬ В РУКАХ =====
	for(var/zone in list("l_arm", "r_arm", "l_hand", "r_hand"))
		var/datum/organ/external/E = organs[zone]
		if(E && !E.destroyed && E.get_damage() >= 40)
			if(prob(5))
				drop_item()
				visible_message("<span class='warning'>[src] роняет предмет от боли в руках.</span>")
			break

	// ===== 4. БОЛЬ В ГРУДИ =====
	var/datum/organ/external/chest = organs["chest"]
	if(chest && !chest.destroyed)
		var/dam = chest.get_damage()
		if(dam >= 40 && prob(10))
			losebreath += 1
			if(prob(20))
				emote("gasp")

	// ===== 5. НАКОПЛЕННАЯ БОЛЬ =====
	var/total = 0
	for(var/datum/organ/external/E in organs2)
		if(E && !E.destroyed)
			total += E.get_damage()

	if(total > 100 && prob(3))
		visible_message("<span class='danger'>[src] сгибается от общей боли в теле!</span>")
		weakened = max(weakened, 3)
		confused = max(confused, 5)

	if(total > 200 && prob(2))
		visible_message("<span class='danger'>[src] падает от невыносимой боли!</span>")
		weakened = max(weakened, 10)
		paralysis = max(paralysis, 5)

	// ===== 6. ПРОВЕРКА НА ПОТЕРЮ СОЗНАНИЯ ОТ БОЛИ =====
	if(gurps_pain_level >= 100 && prob(3))
		visible_message("<span class='danger'>[src] теряет сознание от запредельной боли!</span>")
		paralysis = max(paralysis, 15)
		gurps_pain_level = max(0, gurps_pain_level - 30)

// ===== ВЫЗОВ handle_pain() В humanlife.dm =====
// Добавьте эту строку в /mob/living/carbon/human/handle_regular_status_updates():
// handle_pain()
//
// Пример:
/*
/mob/living/carbon/human/handle_regular_status_updates()
	for(var/datum/organ/external/E in GetOrgans())
		E.process()
		if(E.broken)
			if(E.name == "l hand" || E.name == "l arm")
				if(hands && hands.dir == SOUTH && equipped())
					drop_item()
					emote("scream")
			else if(E.name == "r hand" || E.name == "r arm")
				if(hands && hands.dir == NORTH && equipped())
					drop_item()
					emote("scream")
		if(E.open && (!resting) && (!sleeping))
			emote("scream")
			E.take_damage(20,0)
			emote("collapse")
			paralysis = 10

	gurps_regen_endurance()
	gurps_process_health()
	handle_pain()  // <-- ДОБАВИТЬ ЭТУ СТРОКУ

	UpdateDamage()
	updatehealth()
	// ... остальной код ...
*/
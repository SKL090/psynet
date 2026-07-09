// ============================
// gurps_health.dm - СИСТЕМА ЗДОРОВЬЯ GURPS (ИСПРАВЛЕННАЯ ВЕРСИЯ)
// ============================
// Теперь не дублирует родные органы из neworgans.dm.
// Отвечает только за: витальные показатели, боль, хирургию, артерии/сухожилия (как статусы).

/mob/living/carbon/human
	// Вспомогательные списки для хирургии (артерии и сухожилия теперь в датумах органов)
	// Оставлены для обратной совместимости с хирургическими процедурами
	var/list/gurps_arteries = list()   // Будет синхронизироваться с E.artery_cut
	var/list/gurps_tendons = list()    // Будет синхронизироваться с E.tendon_damaged
	var/list/gurps_organ_status = list()
	var/gurps_blood_pressure = 120
	var/gurps_heart_rate = 70
	var/gurps_oxygen_saturation = 98
	var/gurps_toxin_level = 0
	var/gurps_pain_level = 0

/mob/living/carbon/human/New()
	..()
	// Инициализация вспомогательных списков (синхронизируются с датумами органов)
	if(!gurps_arteries.len)
		gurps_arteries = list("l_arm"=0, "r_arm"=0, "l_leg"=0, "r_leg"=0, "neck"=0)
	if(!gurps_tendons.len)
		gurps_tendons = list("l_arm"=0, "r_arm"=0, "l_hand"=0, "r_hand"=0, "l_leg"=0, "r_leg"=0)
	if(!gurps_organ_status.len)
		gurps_organ_status = list(
			"heart"="healthy", "lungs"="healthy", "liver"="healthy",
			"kidneys"="healthy", "stomach"="healthy", "intestines"="healthy",
			"brain"="healthy", "eyes"="healthy", "ears"="healthy"
		)

// ============================
// СИНХРОНИЗАЦИЯ С ДАТУМАМИ ОРГАНОВ
// ============================
/mob/living/carbon/human/proc/gurps_sync_arteries_tendons()
	// Синхронизирует gurps_arteries и gurps_tendons с реальным состоянием датумов органов
	for(var/organ_name in organs)
		var/datum/organ/external/E = organs[organ_name]
		if(!istype(E)) continue

		if(organ_name in gurps_arteries)
			gurps_arteries[organ_name] = E.artery_cut
		if(organ_name in gurps_tendons)
			gurps_tendons[organ_name] = E.tendon_damaged

// ---------- ПОВРЕЖДЕНИЕ ОРГАНА (ИСПОЛЬЗУЕТСЯ В neworgans.dm) ----------
/mob/living/carbon/human/proc/gurps_damage_organ(organ, severity)
	if(!gurps_organ_status[organ])
		return

	var/old = gurps_organ_status[organ]

	switch(severity)
		if(1)
			if(old == "healthy")
				gurps_organ_status[organ] = "bruised"
		if(2)
			gurps_organ_status[organ] = "damaged"
		if(3)
			gurps_organ_status[organ] = "ruptured"
		if(4)
			gurps_organ_status[organ] = "destroyed"

	if(old != gurps_organ_status[organ])
		visible_message("<span class='danger'>[organ] [src] повреждён! ([gurps_organ_status[organ]])</span>")

	gurps_update_vitals()

// ---------- ЖИЗНЕННЫЕ ПОКАЗАТЕЛИ ----------
/mob/living/carbon/human/proc/gurps_update_vitals()
	// Сердце
	switch(gurps_organ_status["heart"])
		if("healthy")
			gurps_heart_rate = rand(60, 100)
			gurps_blood_pressure = rand(110, 130)
		if("bruised")
			gurps_heart_rate = rand(50, 110)
			gurps_blood_pressure = rand(100, 140)
		if("damaged")
			gurps_heart_rate = rand(30, 130)
			gurps_blood_pressure = rand(80, 160)
			if(prob(20))
				oxyloss += 3
		if("ruptured")
			gurps_heart_rate = rand(20, 150)
			gurps_blood_pressure = rand(60, 180)
			oxyloss += 5
			if(prob(5))
				death()
		if("destroyed")
			gurps_heart_rate = 0
			gurps_blood_pressure = 0
			death()

	// Лёгкие
	switch(gurps_organ_status["lungs"])
		if("damaged")
			gurps_oxygen_saturation = rand(85, 95)
			if(prob(15))
				losebreath += 2
		if("ruptured")
			gurps_oxygen_saturation = rand(70, 85)
			losebreath += 3
		if("destroyed")
			gurps_oxygen_saturation = rand(40, 60)
			losebreath += 5
			if(prob(10))
				death()

	// Печень
	switch(gurps_organ_status["liver"])
		if("damaged")
			gurps_toxin_level = min(100, gurps_toxin_level + 2)
			if(prob(10))
				toxloss += 2
		if("ruptured")
			gurps_toxin_level = min(100, gurps_toxin_level + 5)
			toxloss += 3
		if("destroyed")
			gurps_toxin_level = min(100, gurps_toxin_level + 10)
			toxloss += 5

	// Мозг
	switch(gurps_organ_status["brain"])
		if("damaged")
			if(prob(15))
				eye_blurry = max(eye_blurry, 5)
		if("ruptured")
			eye_blurry = max(eye_blurry, 10)
			if(prob(20))
				paralysis = max(paralysis, 5)
		if("destroyed")
			paralysis = max(paralysis, 30)
			death()

	// Глаза
	if(gurps_organ_status["eyes"] in list("damaged", "ruptured"))
		eye_blurry = max(eye_blurry, 5)
	if(gurps_organ_status["eyes"] == "destroyed")
		blinded = 1

	// Уши
	if(gurps_organ_status["ears"] in list("damaged", "ruptured"))
		ear_damage = max(ear_damage, 10)
	if(gurps_organ_status["ears"] == "destroyed")
		ear_deaf = 1

	// Синхронизируем статусы артерий/сухожилий
	gurps_sync_arteries_tendons()

// ---------- ОБРАБОТКА В LIFE ----------
/mob/living/carbon/human/proc/gurps_process_health()
	gurps_update_vitals()
	gurps_sync_arteries_tendons()

	// Обработка всех артерий
	for(var/organ_name in organs)
		var/datum/organ/external/E = organs[organ_name]
		if(!istype(E) || !E.artery_cut) continue

		bloodloss = min(100, bloodloss + 3)
		if(prob(2) && bloodloss > 50)
			paralysis = max(paralysis, 10)

	// Обработка сухожилий (синхронизировано с датумами)
	for(var/t in gurps_tendons)
		if(gurps_tendons[t] == 1)
			if(t in list("l_arm", "r_arm", "l_hand", "r_hand"))
				if(hand ? (t == "l_arm" || t == "l_hand") : (t == "r_arm" || t == "r_hand"))
					if(prob(15))
						drop_item()
			if(t in list("l_leg", "r_leg"))
				if(prob(20))
					weakened = max(weakened, 2)

	// Обновление уровня боли
	gurps_pain_level = 0
	for(var/o in gurps_organ_status)
		switch(gurps_organ_status[o])
			if("bruised")   gurps_pain_level += 5
			if("damaged")   gurps_pain_level += 15
			if("ruptured")  gurps_pain_level += 30
			if("destroyed") gurps_pain_level += 50

	// Эффекты от сильной боли
	if(gurps_pain_level > 80 && prob(10))
		visible_message("<span class='danger'>[src] теряет сознание от боли!</span>")
		paralysis = max(paralysis, 10)

	if(gurps_pain_level > 50 && prob(5))
		emote("scream")
		weakened = max(weakened, 2)

// ---------- БОЛЬ (ВЫЗЫВАЕТСЯ ИЗ neworgans.dm) ----------
// Эта функция ПЕРЕОПРЕДЕЛЯЕТ базовую /mob/proc/pain() из life.dm
/mob/living/carbon/human/pain(var/partname, var/amount, var/force = 0)
	if(stat >= 1)
		return
	if(nodamage)
		return

	// Накопление боли
	if(force)
		gurps_pain_level += amount
	else
		gurps_pain_level += amount / 2

	// Сообщения о боли
	if(world.time < next_pain_time && !force)
		return

	var/msg
	switch(amount)
		if(1 to 10)
			msg = "<b>Моя [partname] немножечко побаливает."
		if(11 to 90)
			flash_weak_pain()
			msg = "<b><font size=1>Ouch! Your [partname] hurts."
		if(91 to 10000)
			flash_pain()
			msg = "<b><font size=3>КАКАЯ ДИКАЯ БОЛЬ! Моя [partname]"

	if(msg && (msg != last_pain_message || prob(10)))
		last_pain_message = msg
		src << msg
	next_pain_time = world.time + max(10, 100 - amount)

	// Реакция на сильную боль
	if(amount > 30 && force)
		emote("scream")

// ---------- ХИРУРГИЯ ----------
/mob/living/carbon/human/proc/gurps_surgery_fix_organ(organ)
	if(gurps_organ_status[organ] && gurps_organ_status[organ] != "healthy")
		gurps_organ_status[organ] = "healthy"

		var/datum/organ/external/chest/C = organs["chest"]
		var/datum/organ/external/vitals/V = organs["vitals"]

		switch(organ)
			if("heart")
				if(C && C.heart)
					C.heart.health = C.heart.max_health
					C.heart.status = "healthy"
			if("lungs")
				if(C && C.lungs)
					C.lungs.health = C.lungs.max_health
					C.lungs.status = "healthy"
			if("liver")
				if(C && C.liver)
					C.liver.health = C.liver.max_health
					C.liver.status = "healthy"
			if("stomach")
				if(V && V.stomach)
					V.stomach.health = V.stomach.max_health
					V.stomach.status = "healthy"
			if("intestines")
				if(V && V.intestines)
					V.intestines.health = V.intestines.max_health
					V.intestines.status = "healthy"

		gurps_update_vitals()
		visible_message("<span class='notice'>[organ] [src] восстановлен.</span>")
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/gurps_surgery_fix_artery(zone)
	// Синхронизируем перед проверкой
	gurps_sync_arteries_tendons()

	if(gurps_arteries[zone] == 1)
		// Исправляем в датуме органа
		var/datum/organ/external/E = organs[zone]
		if(E && istype(E))
			E.artery_cut = 0

		gurps_arteries[zone] = 0
		bloodloss = max(0, bloodloss - 10)
		visible_message("<span class='notice'>Артерия [zone] [src] перевязана.</span>")
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/gurps_surgery_fix_tendon(zone)
	// Синхронизируем перед проверкой
	gurps_sync_arteries_tendons()

	if(gurps_tendons[zone] == 1)
		// Исправляем в датуме органа
		var/datum/organ/external/E = organs[zone]
		if(E && istype(E))
			E.tendon_damaged = 0

		gurps_tendons[zone] = 0
		visible_message("<span class='notice'>Сухожилия [zone] [src] сшиты.</span>")
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/gurps_surgery_fix_fracture(zone)
	var/datum/organ/external/E = organs[zone]
	if(!E || !istype(E))
		return FALSE

	if(E.broken)
		// Лечим перелом
		E.broken = 0
		E.perma_injury = 0
		E.min_broken_damage = initial(E.min_broken_damage)

		// Восстанавливаем часть здоровья конечности
		E.brute_dam = max(0, E.brute_dam - 30)

		visible_message("<span class='notice'>Кость в [E.display_name] [src] вправлена.</span>")
		UpdateDamageIcon()
		updatehealth()
		return TRUE
	return FALSE

// ============================
// ДИАГНОСТИКА (ДЛЯ МЕДИЦИНСКИХ ПРИБОРОВ)
// ============================
/mob/living/carbon/human/proc/gurps_diagnose()
	var/list/report = list()

	report += "=== МЕДИЦИНСКИЙ ОТЧЁТ ==="
	report += "Пациент: [real_name]"
	report += ""
	report += "--- ВИТАЛЬНЫЕ ПОКАЗАТЕЛИ ---"
	report += "Пульс: [gurps_heart_rate] BPM"
	report += "Давление: [gurps_blood_pressure]/80"
	report += "Сатурация: [gurps_oxygen_saturation]%"
	report += "Токсины: [gurps_toxin_level]%"
	report += "Уровень боли: [gurps_pain_level]"
	report += "Кровопотеря: [bloodloss] мл"
	report += ""
	report += "--- СТАТУС ОРГАНОВ ---"
	for(var/o in gurps_organ_status)
		report += "[o]: [gurps_organ_status[o]]"

	report += ""
	report += "--- ПОВРЕЖДЕНИЯ КОНЕЧНОСТЕЙ ---"
	gurps_sync_arteries_tendons()

	for(var/organ_name in organs)
		var/datum/organ/external/E = organs[organ_name]
		if(!istype(E)) continue

		var/status = "Здоров"
		if(E.destroyed)
			status = "УНИЧТОЖЕН"
		else if(E.broken)
			status = "СЛОМАН"
		else if(E.brute_dam > E.max_damage * 0.5)
			status = "Сильно повреждён"
		else if(E.brute_dam > E.max_damage * 0.25)
			status = "Повреждён"

		var/add_info = ""
		if(E.artery_cut)
			add_info += " АРТЕРИЯ РАЗОРВАНА"
		if(E.tendon_damaged)
			add_info += " СУХОЖИЛИЯ ПОВРЕЖДЕНЫ"

		report += "[E.display_name]: [status][add_info] (HP: [E.max_damage - E.brute_dam]/[E.max_damage])"

	return report
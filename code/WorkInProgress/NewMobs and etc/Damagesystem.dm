// ============================
// Damagesystem.dm — ИСПРАВЛЕННАЯ ВЕРСИЯ (БЕЗ ДУБЛИКАТОВ GURPS)
// ============================

/mob/living/carbon/human/name = "human"
/mob/living/carbon/human/voice_name = "human"
/mob/living/carbon/human/icon = 'icons/mob/mob.dmi'
/mob/living/carbon/human/icon_state = "m-none"

/mob/living/carbon/human/random_events = list("blink")
/mob/living/carbon/human/species = "Human"
/mob/living/carbon/human/var/lastnutritioncomplaint = 0
/mob/living/carbon/human/var/bloodloss = 0
/mob/living/carbon/human/var/r_hair = 0.0
/mob/living/carbon/human/var/g_hair = 0.0
/mob/living/carbon/human/var/b_hair = 0.0
/mob/living/carbon/human/var/h_style = "Short Hair"
/mob/living/carbon/human/var/r_facial = 0.0
/mob/living/carbon/human/var/g_facial = 0.0
/mob/living/carbon/human/var/b_facial = 0.0
/mob/living/carbon/human/var/f_style = "Shaved"
/mob/living/carbon/human/var/r_eyes = 0.0
/mob/living/carbon/human/var/g_eyes = 0.0
/mob/living/carbon/human/var/b_eyes = 0.0
/mob/living/carbon/human/var/s_tone = 0.0
/mob/living/carbon/human/var/age = 30.0
/mob/living/carbon/human/var/b_type = "A+"
/mob/living/carbon/human/var/obj/overlay/hair
/mob/living/carbon/human/var/obj/item/weapon/r_store = null
/mob/living/carbon/human/var/obj/item/weapon/l_store = null

/mob/living/carbon/human/var/icon/stand_icon = null
/mob/living/carbon/human/var/icon/lying_icon = null

/mob/living/carbon/human/var/last_b_state = 1.0

/mob/living/carbon/human/var/image/face_standing = null
/mob/living/carbon/human/var/image/face_lying = null

/mob/living/carbon/human/var/hair_icon_state = "hair_a"
/mob/living/carbon/human/var/face_icon_state = "bald"

/mob/living/carbon/human/var/list/body_standing = list()
/mob/living/carbon/human/var/list/body_lying = list()

/mob/living/carbon/human/var/mutantrace = null
/mob/living/carbon/human/var/bot = 0
/mob/living/carbon/human/var/zombie = 0
/mob/living/carbon/human/var/pale = 0
/mob/living/carbon/human/var/zombietime = 0
/mob/living/carbon/human/var/zombifying = 0
/mob/living/carbon/human/var/image/zombieimage = null
/mob/living/var/list/organs2 = list()
/mob/living/carbon/human/var/datum/organ/external/DEBUG_lfoot
/mob/living/carbon/human/var/datum/reagents/vessel

// lastattacker уже определён в mob.dm — не дублируем

/mob/living/carbon/human/dummy
	real_name = "Test Dummy"
	nodamage = 1

// ============================
// ИНИЦИАЛИЗАЦИЯ ЧЕЛОВЕКА
// ============================
/mob/living/carbon/human/New()
	..()
	var/datum/reagents/R = new/datum/reagents(1000)
	reagents = R
	R.my_atom = src

	if (!dna)
		dna = new /datum/dna( null )

	// ===== СОЗДАНИЕ ВНЕШНИХ ОРГАНОВ =====
	var/datum/organ/external/chest/chest = new /datum/organ/external/chest( src )
	chest.owner = src

	var/datum/organ/external/groin/groin = new /datum/organ/external/groin( src )
	groin.owner = src

	var/datum/organ/external/head/head = new /datum/organ/external/head( src )
	head.owner = src

	// ===== ШЕЯ =====
	var/datum/organ/external/neck/neck = new /datum/organ/external/neck( src )
	neck.owner = src

	// ===== КОНЕЧНОСТИ =====
	var/datum/organ/external/l_arm/l_arm = new /datum/organ/external/l_arm( src )
	l_arm.owner = src

	var/datum/organ/external/r_arm/r_arm = new /datum/organ/external/r_arm( src )
	r_arm.owner = src

	var/datum/organ/external/l_hand/l_hand = new /datum/organ/external/l_hand( src )
	l_hand.owner = src
	l_hand.parent = l_arm

	var/datum/organ/external/r_hand/r_hand = new /datum/organ/external/r_hand( src )
	r_hand.owner = src
	r_hand.parent = r_arm

	var/datum/organ/external/l_leg/l_leg = new /datum/organ/external/l_leg( src )
	l_leg.owner = src

	var/datum/organ/external/r_leg/r_leg = new /datum/organ/external/r_leg( src )
	r_leg.owner = src

	var/datum/organ/external/l_foot/l_foot = new /datum/organ/external/l_foot( src )
	l_foot.owner = src
	l_foot.parent = l_leg

	var/datum/organ/external/r_foot/r_foot = new /datum/organ/external/r_foot( src )
	r_foot.owner = src
	r_foot.parent = r_leg

	// ===== СОЗДАНИЕ VITALS =====
	var/datum/organ/external/vitals/vitals = new /datum/organ/external/vitals(src)
	vitals.owner = src
	organs["vitals"] += vitals
	organs2 += vitals

	// ===== ВНУТРЕННИЕ ОРГАНЫ ГРУДИ =====
	chest.heart = new /datum/organ/internal/heart()
	chest.heart.owner = src
	chest.lungs = new /datum/organ/internal/lungs()
	chest.lungs.owner = src
	chest.liver = new /datum/organ/internal/liver()
	chest.liver.owner = src

	// ===== ВНУТРЕННИЕ ОРГАНЫ ЖИВОТА =====
	vitals.kidney_left = new /datum/organ/internal/kidney()
	vitals.kidney_left.owner = src
	vitals.kidney_left.name = "left kidney"
	vitals.kidney_right = new /datum/organ/internal/kidney()
	vitals.kidney_right.owner = src
	vitals.kidney_right.name = "right kidney"
	vitals.stomach = new /datum/organ/internal/stomach()
	vitals.stomach.owner = src
	vitals.intestines = new /datum/organ/internal/intestines()
	vitals.intestines.owner = src

	// ===== ВНУТРЕННИЕ ОРГАНЫ ГОЛОВЫ =====
	head.brain = new /datum/organ/internal/brain()
	head.brain.owner = src

	head.left_eye = new /datum/organ/internal/eyes/left()
	head.left_eye.owner = src
	head.left_eye.name = "left eye"

	head.right_eye = new /datum/organ/internal/eyes/right()
	head.right_eye.owner = src
	head.right_eye.name = "right eye"

	head.ears = new /datum/organ/internal/ears()
	head.ears.owner = src

	// ===== РЕГИСТРАЦИЯ ОРГАНОВ =====
	organs["chest"] += chest
	organs["groin"] += groin
	organs["head"] += head
	organs["neck"] += neck
	organs["l_arm"] += l_arm
	organs["r_arm"] += r_arm
	organs["l_hand"] += l_hand
	organs["r_hand"] += r_hand
	organs["l_leg"] += l_leg
	organs["r_leg"] += r_leg
	organs["l_foot"] += l_foot
	organs["r_foot"] += r_foot

	organs2 += chest
	organs2 += groin
	organs2 += head
	organs2 += neck
	organs2 += l_arm
	organs2 += r_arm
	organs2 += l_hand
	organs2 += r_hand
	organs2 += l_leg
	organs2 += r_leg
	organs2 += l_foot
	organs2 += r_foot

	DEBUG_lfoot = l_foot

	// ===== ГЕНЕРАЦИЯ ИКОНОК =====
	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"
	else
		gender = MALE
		g = "m"

	if(!stand_icon)
		stand_icon = new /icon('icons/mob/human.dmi', "body_[g]_s")
	if(!lying_icon)
		lying_icon = new /icon('icons/mob/human.dmi', "body_[g]_l")
	icon = stand_icon

	src << "\blue Your icons have been generated!"

	// ===== КРОВЬ =====
	vessel = new/datum/reagents(560)
	vessel.my_atom = src
	vessel.add_reagent("blood",560)

	update_clothing()
	spawn(1) fixblood()

// ============================
// ФИКСАЦИЯ КРОВИ
// ============================
/mob/living/carbon/human/proc/fixblood()
	for(var/datum/reagent/blood/B in vessel.reagent_list)
		if(B.id == "blood")
			B.blood_type = src.b_type
			B.blood_DNA = src.dna.unique_enzymes
			if(microorganism)
				B.microorganism = microorganism.getcopy()

// ============================
// BUMP (СТОЛКНОВЕНИЯ)
// ============================
/mob/living/carbon/human/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if (ismob(AM))
		var/mob/tmob = AM
		if(tmob.a_intent == "help" && a_intent == "help" && tmob.canmove && canmove)
			var/turf/oldloc = loc
			loc = tmob.loc
			tmob.loc = oldloc
			now_pushing = 0
			return
		if(istype(equipped(), /obj/item/weapon/baton))
			if(loc:ul_Luminosity() < 3 || blinded)
				var/obj/item/weapon/baton/W = equipped()
				if (world.time > lastDblClick+2)
					lastDblClick = world.time
					if(((prob(40)) || (prob(95) && mutations & 16)) && W.status)
						src << "\red You accidentally stun yourself with the [W.name]."
						weakened = max(12, weakened)
						playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
						W:charges--
					else if(W.status)
						for(var/mob/M in viewers(src, null))
							if(M.client)
								M << "\red <B>[src] accidentally bumps into [tmob] with the [W.name]."
						tmob.weakened = max(4, tmob.weakened)
						tmob.stunned = max(4, tmob.stunned)
						playsound(loc, 'sound/weapons/Egloves.ogg', 50, 1, -1)
						W:charges--
					now_pushing = 0
					return
	now_pushing = 0
	spawn(0)
		..()
		if (!istype(AM, /atom/movable))
			return
		if (!now_pushing)
			now_pushing = 1
			if (!AM.anchored)
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

// ============================
// ЗАДЕРЖКА ДВИЖЕНИЯ
// ============================
/mob/living/carbon/human/movement_delay()
	var/tally = 1.3

	if(zombie)
		return 4

	if(reagents.has_reagent("hyperzine")) return -1

	var/health_deficiency = (health_full - health)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	for(var/organ in list("l_leg","l_foot","r_leg","r_foot"))
		var/datum/organ/external/o = organs["[organ]"]
		if(o && o.broken)
			tally += 6

	if(wear_suit)
		switch(wear_suit.type)
			if(/obj/item/clothing/suit/straight_jacket)
				tally += 15
			if(/obj/item/clothing/suit/fire)
				tally += 1.3
			if(/obj/item/clothing/suit/fire/heavy)
				tally += 1.7
			if(/obj/item/clothing/suit/armor/riot)
				tally += 2
			if(/obj/item/clothing/suit/space)
				if(!istype(loc, /turf/space))
					tally += 3
			if(/obj/item/clothing/suit/space/spaceengi)
				if(!istype(loc, /turf/space))
					tally += 2

	if (istype(shoes, /obj/item/clothing/shoes))
		if (shoes.chained)
			tally += 15
		else
			tally += -1.0

	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.25

	return tally

// ============================
// STAT ПАНЕЛЬ (ТОЛЬКО СТАНДАРТНАЯ)
// ============================
/mob/living/carbon/human/Stat()
	..()
	if(ticker.mode.name == "AI malfunction")
		if(ticker.mode:malf_mode_declared)
			stat(null, "Time left: [ ticker.mode:AI_win_timeleft]")

	if (client.statpanel == "Status")
		if (internal)
			if (!internal.air_contents)
				del(internal)
			else
				stat("Internal Atmosphere Info", internal.name)
				stat("Tank Pressure", internal.air_contents.return_pressure())
				stat("Distribution Pressure", internal.distribute_pressure)


	// GURPS-панель
	if(statpanel("GURPS"))
		if(!gurps_strength || !gurps_combat_skills || !gurps_civil_skills) return

		stat("=== АТРИБУТЫ ===")
		stat("Сила (ST):", gurps_strength)
		stat("Ловкость (DX):", gurps_dexterity)
		stat("Здоровье (HT):", gurps_health)
		stat("Интеллект (IQ):", gurps_intelligence)
		stat("Восприятие (PR):", gurps_perception)
		stat("")
		stat("=== ВЫНОСЛИВОСТЬ ===")
		var/bar = ""
		var/filled = round((gurps_endurance / max(1, gurps_endurance_max)) * 20)
		for(var/i = 1 to 20) bar += (i <= filled) ? "|" : "."
		stat("EN:", "[gurps_endurance]/[gurps_endurance_max] [bar]")
		stat("")
		stat("=== БОЕВЫЕ НАВЫКИ (0-6) ===")
		for(var/s in gurps_combat_skills)
			stat("[s]:", gurps_combat_skills[s])
		stat("")
		stat("=== ГРАЖДАНСКИЕ НАВЫКИ (0-6) ===")
		for(var/s in gurps_civil_skills)
			stat("[s]:", gurps_civil_skills[s])

		stat("")
		stat("=== БОНУСЫ ===")
		if(gurps_combat_mode)
			stat("Боевой режим:", "АКТИВЕН (+1 атака/защита)")
		else
			stat("Боевой режим:", "Неактивен")
		if(gurps_defense_active)
			stat("Защита:", "АКТИВНА ([gurps_defense_mode])")
		else
			stat("Защита:", "Неактивна")
		if(gurps_dodge_penalty > 0)
			stat("Штраф защиты:", "-[gurps_dodge_penalty]")

// ============================
// ПОПАДАНИЕ ПУЛИ
// ============================
/mob/living/carbon/human/bullet_act(flag, A as obj)
	var/shielded = 0

	for(var/obj/item/device/shield/S in src)
		if (S.active)
			if (flag == "bullet")
				return
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"

	for(var/obj/item/weapon/cloaking_device/S in src)
		if (S.active)
			shielded = 1
			S.active = 0
			S.icon_state = "shield0"

	if (shielded && flag != "bullet")
		src << "\blue Your shield was disturbed by a laser!"
		if(paralysis <= 30)	paralysis = 30
		updatehealth()

	if (locate(/obj/item/weapon/grab, src))
		var/mob/safe = null
		if (istype(l_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = l_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting

		if (istype(r_hand, /obj/item/weapon/grab))
			var/obj/item/weapon/grab/G = r_hand
			if ((G.state == 3 && get_dir(src, A) == dir))
				safe = G.affecting

		if (safe)
			return safe.bullet_act(flag, A)

	if (flag == PROJECTILE_BULLET)
		var/d = 51
		if (istype(wear_suit, /obj/item/clothing/suit/armor || /obj/item/clothing/suit/storage/armourrigvest))
			if (prob(70))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 4
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(90))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 5
		if (stat != 2)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destroyed)
					return
				temp.take_damage(d, 0)
			UpdateDamageIcon()
			updatehealth()
			if (prob(50))
				if(weakened <= 5)	weakened = 5
		return

	else if (flag == PROJECTILE_TASER)
		if(zombie) return
		if (istype(wear_suit, /obj/item/clothing/suit/armor || /obj/item/clothing/suit/storage/armourrigvest))
			if (prob(5))
				show_message("\red Your armor absorbs the hit!", 4)
				return
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(70))
					show_message("\red Your armor absorbs the hit!", 4)
					return
		if (prob(75) && stunned <= 10)
			stunned = 10
		else
			weakened = 10
		if (stuttering < 10)
			stuttering = 10

	else if (flag == PROJECTILE_STUNBOLT)
		if(zombie) return
		if (istype(wear_suit, /obj/item/clothing/suit/armor || /obj/item/clothing/suit/storage/armourrigvest))
			if (prob(5))
				show_message("\red Your armor absorbs the hit!", 4)
				return
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(35))
					show_message("\red Your armor absorbs the hit!", 4)
					return
		if (prob(75) && stunned <= 20)
			stunned = 20
		else
			weakened = 20
		if (stuttering < 20)
			stuttering = 20

		if(stat != STAT_DEAD)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destroyed)
					return
				temp.take_damage(rand(10,20), 0)

	else if(flag == PROJECTILE_LASER)
		var/d = 20
		if (istype(wear_suit, /obj/item/clothing/suit/armor || /obj/item/clothing/suit/storage/armourrigvest))
			if (prob(40))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(40))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(70))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(90))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(60))
							d = d / 2
						d = d / 2

		if (!eye_blurry) eye_blurry = 4
		if (prob(25)) stunned++

		if (stat != 2)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destroyed)
					return
				temp.take_damage(d, 0)
			UpdateDamageIcon()
			updatehealth()
			if (prob(25))
				stunned = 1

	else if(flag == PROJECTILE_PULSE)
		var/d = 40
		if (istype(wear_suit, /obj/item/clothing/suit/armor || /obj/item/clothing/suit/storage/armourrigvest))
			if (prob(20))
				show_message("\red Your armor absorbs the hit!", 4)
				return
			else
				if (prob(20))
					show_message("\red Your armor only softens the hit!", 4)
					if (prob(20))
						d = d / 2
					d = d / 2
		else
			if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(50))
					show_message("\red Your armor absorbs the blow!", 4)
					return
				else
					if (prob(50))
						show_message("\red Your armor only softens the blow!", 4)
						if (prob(50))
							d = d / 2
						d = d / 2
		if (stat != 2)
			var/organ = organs[ran_zone("chest")]
			if (istype(organ, /datum/organ/external))
				var/datum/organ/external/temp = organ
				if(temp.destroyed)
					return
				temp.take_damage(d, 0)
			UpdateDamageIcon()
			updatehealth()
			if (prob(50))
				stunned = min(stunned, 5)

	else if(flag == PROJECTILE_BOLT)
		toxloss += 3
		radiation += 100
		updatehealth()
		stuttering += 5
		drowsyness += 5

	return

// ============================
// ВЗРЫВ
// ============================
/mob/living/carbon/human/ex_act(severity)
	flick("flash", flash)

	if (stat == 2 && client)
		gib(1)
		return

	else if (stat == 2 && !client)
		gibs(loc, microorganism)
		del(src)
		return

	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			b_loss += 500
			gib(1)
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 30
				ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				paralysis += 10
			if (!istype(ears, /obj/item/clothing/ears/earmuffs))
				ear_damage += 15
				ear_deaf += 60

	for(var/organ in organs)
		var/datum/organ/external/temp = organs[text("[]", organ)]
		if (istype(temp, /datum/organ/external))
			switch(temp.name)
				if("head")
					temp.take_damage(b_loss * 0.2, f_loss * 0.2)
				if("neck")
					temp.take_damage(b_loss * 0.15, f_loss * 0.15)
				if("chest")
					temp.take_damage(b_loss * 0.4, f_loss * 0.4)
				if("groin")
					temp.take_damage(b_loss * 0.1, f_loss * 0.1)
				if("l_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_arm")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_hand")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("l_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("r_leg")
					temp.take_damage(b_loss * 0.05, f_loss * 0.05)
				if("l_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)
				if("r_foot")
					temp.take_damage(b_loss * 0.0225, f_loss * 0.0225)

	UpdateDamageIcon()

// ============================
// БЛОБ
// ============================
/mob/living/carbon/human/blob_act()
	if (stat == 2)
		return
	var/shielded = 0
	for(var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
	var/damage = null
	if (stat != 2)
		damage = rand(1,20)

	if(shielded)
		damage /= 4

	show_message("\red The blob attacks you!")
	var/list/zones = list()
	for(var/datum/organ/external/part in organs2)
		if(!part.destroyed)
			zones += part.name
	var/zone = pick(zones)
	if(!zone)
		return
	var/datum/organ/external/temp = organs["[zone]"]
	if(!temp || temp.destroyed)
		return
	switch(zone)
		if ("head")
			if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
				if (prob(20))
					temp.take_damage(damage, 0)
				else
					show_message("\red You have been protected from a hit to the head.")
				return
			if (damage > 4.9)
				if (weakened < 10)
					weakened = rand(10, 15)
				for(var/mob/O in viewers(src, null))
					O.show_message(text("\red <B>The blob has weakened []!</B>", src), 1, "\red You hear someone fall.", 2)
			temp.take_damage(damage)
		if ("neck")
			if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(70)))
				show_message("\red You have been protected from a hit to the neck.")
				return
			temp.take_damage(damage)
		if ("chest")
			if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & UPPER_TORSO)) && prob(85)))
				show_message("\red You have been protected from a hit to the chest.")
				return
			if (damage > 4.9)
				if (prob(50))
					if (weakened < 5)
						weakened = 5
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>The blob has knocked down []!</B>", src), 1, "\red You hear someone fall.", 2)
				else
					if (stunned < 5)
						stunned = 5
					for(var/mob/O in viewers(src, null))
						if(O.client)	O.show_message(text("\red <B>The blob has stunned []!</B>", src), 1)
				if(stat != 2)	stat = 1
			temp.take_damage(damage)
		if ("groin")
			if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
				show_message("\red You have been protected from a hit to the lower chest.")
				return
			else
				temp.take_damage(damage, 0)
		if("l_arm")
			temp.take_damage(damage, 0)
		if("r_arm")
			temp.take_damage(damage, 0)
		if("l_hand")
			temp.take_damage(damage, 0)
		if("r_hand")
			temp.take_damage(damage, 0)
		if("l_leg")
			temp.take_damage(damage, 0)
		if("r_leg")
			temp.take_damage(damage, 0)
		if("l_foot")
			temp.take_damage(damage, 0)
		if("r_foot")
			temp.take_damage(damage, 0)

	UpdateDamageIcon()
	return

// ============================
// СНЯТИЕ ЭКИПИРОВКИ
// ============================
/mob/living/carbon/human/u_equip(obj/item/W as obj)
	if (W == wear_suit)
		wear_suit = null
	else if (W == w_uniform)
		W = r_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = l_store
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = wear_id
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		W = belt
		if (W)
			u_equip(W)
			if (client)
				client.screen -= W
			if (W)
				W.loc = loc
				W.dropped(src)
				W.layer = initial(W.layer)
		w_uniform = null
	else if (W == gloves)
		gloves = null
	else if (W == glasses)
		glasses = null
	else if (W == head)
		head = null
	else if (W == ears)
		ears = null
	else if (W == shoes)
		shoes = null
	else if (W == belt)
		belt = null
	else if (W == wear_mask)
		if(internal)
			if (internals)
				internals.icon_state = "internal0"
			internal = null
		wear_mask = null
	else if (W == wear_id)
		wear_id = null
	else if (W == r_store)
		r_store = null
	else if (W == l_store)
		l_store = null
	else if (W == back)
		back = null
	else if (W == handcuffed)
		handcuffed = null
	else if (W == r_hand)
		r_hand = null
	else if (W == l_hand)
		l_hand = null

	update_clothing()

// ============================
// ДВОЙНОЙ КЛИК ПО СЛОТАМ
// ============================
/mob/living/carbon/human/db_click(text, t1)
	var/obj/item/W = equipped()
	var/emptyHand = (W == null)
	if ((!emptyHand) && (!istype(W, /obj/item)))
		return
	if (emptyHand)
		usr.next_move = usr.prev_move
		usr:lastDblClick -= 3
	switch(text)
		if("mask")
			if (wear_mask)
				if (emptyHand)
					wear_mask.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/mask) ))
				return
			u_equip(W)
			wear_mask = W
			W.equipped(src, text)
		if("back")
			if (back)
				if (emptyHand)
					back.DblClick()
				return
			if (!istype(W, /obj/item))
				return
			if (!( W.flags & ONBACK ))
				return
			u_equip(W)
			back = W
			W.equipped(src, text)
		if("o_clothing")
			if (wear_suit)
				if (emptyHand)
					wear_suit.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/suit) ))
				return
			u_equip(W)
			wear_suit = W
			W.equipped(src, text)
		if("gloves")
			if (gloves)
				if (emptyHand)
					gloves.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/gloves) ))
				return
			u_equip(W)
			gloves = W
			W.equipped(src, text)
		if("shoes")
			if (shoes)
				if (emptyHand)
					shoes.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/shoes) ))
				return
			u_equip(W)
			shoes = W
			W.equipped(src, text)
		if("belt")
			if (belt)
				if (emptyHand)
					belt.DblClick()
				return
			if (!W || !W.flags || !( W.flags & ONBELT ))
				return
			u_equip(W)
			belt = W
			W.equipped(src, text)
		if("eyes")
			if (glasses)
				if (emptyHand)
					glasses.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/glasses) ))
				return
			u_equip(W)
			glasses = W
			W.equipped(src, text)
		if("head")
			if (head)
				if (emptyHand)
					head.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/head) ))
				return
			u_equip(W)
			head = W
			W.equipped(src, text)
		if("ears")
			if (ears)
				if (emptyHand)
					ears.DblClick()
				return
			if (!(istype(W, /obj/item/clothing/ears)) && !(istype(W, /obj/item/device/radio/headset)) && !(W.w_class == 1))
				return
			u_equip(W)
			ears = W
			W.equipped(src, text)
		if("i_clothing")
			if (w_uniform)
				if (emptyHand)
					w_uniform.DblClick()
				return
			if (!( istype(W, /obj/item/clothing/under) || istype(W, /obj/item/clothing/psynet_uniform) ))
				return
			u_equip(W)
			w_uniform = W
			W.equipped(src, text)
		if("id")
			if (wear_id)
				if (emptyHand)
					wear_id.DblClick()
				return
			if (!w_uniform)
				return
			if (!( istype(W, /obj/item/weapon/card/id) ))
				return
			u_equip(W)
			wear_id = W
			W.equipped(src, text)
		if("storage1")
			if (l_store)
				if (emptyHand)
					l_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( w_uniform )))
				return
			u_equip(W)
			l_store = W
		if("storage2")
			if (r_store)
				if (emptyHand)
					r_store.DblClick()
				return
			if ((!( istype(W, /obj/item) ) || W.w_class > 2 || !( w_uniform )))
				return
			u_equip(W)
			r_store = W

	update_clothing()
	return

// ============================
// МЕТЕОР
// ============================
/mob/living/carbon/human/meteorhit(O as obj)
	for(var/mob/M in viewers(src, null))
		if ((M.client && !( M.blinded )))
			M.show_message(text("\red [] has been hit by []", src, O), 1)
	if (health > 0)
		var/dam_zone = pick("chest", "chest", "chest", "head", "groin")
		if (istype(organs[dam_zone], /datum/organ/external))
			var/datum/organ/external/temp = organs[dam_zone]
			if(temp.destroyed)
				return
			temp.take_damage((istype(O, /obj/meteor/small) ? 10 : 25), 30)
			UpdateDamageIcon()
		updatehealth()
	return

// ============================
// ОБНОВЛЕНИЕ ОДЕЖДЫ И ВИЗУАЛА
// ============================
/mob/living/carbon/human/update_clothing()
	..()
	if (monkeyizing)
		return

	if(lying)
		layer = MOB_LAYER - 1
	else
		layer = MOB_LAYER

	overlays = null

	var/fat = ""

	if (mutations & 8)
		overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "hulk[fat][!lying ? "_s" : "_l"]")

	if (mutations & 2)
		overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "fire[fat][!lying ? "_s" : "_l"]")

	if (mutations & 1)
		overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "telekinesishead[fat][!lying ? "_s" : "_l"]")

	if (mutantrace)
		overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[mutantrace][fat][!lying ? "_s" : "_l"]")
		if(face_standing) del(face_standing)
		if(face_lying) del(face_lying)
		if(stand_icon) del(stand_icon)
		if(lying_icon) del(lying_icon)
	else
		if(!face_standing || !face_lying) update_face()
		if(!stand_icon || !lying_icon) update_body()

	if(buckled)
		if(istype(buckled, /obj/stool/bed)) lying = 1
		else lying = 0

	if (!w_uniform)
		for (var/obj/item/thing in list(r_store, l_store, wear_id, belt))
			if (thing)
				u_equip(thing)
				if (client) client.screen -= thing
				if (thing)
					thing.loc = loc
					thing.dropped(src)
					thing.layer = initial(thing.layer)

	// ===== ТЕЛО =====
	if (lying)
		icon = lying_icon
		overlays += body_lying
		if (face_lying) overlays += face_lying
	else
		icon = stand_icon
		overlays += body_standing
		if (face_standing) overlays += face_standing

	// ===== ГОЛЫЕ КОНЕЧНОСТИ (шею не рисуем) =====
	var/g = (gender == MALE) ? "m" : "f"
	var/state = (lying) ? "_l" : "_s"

	for(var/organ_name in organs)
		var/datum/organ/external/O = organs[organ_name]
		if(!istype(O) || O.destroyed) continue
		if(O.icon_name && O.name != "neck")
			var/limb_layer = MOB_LAYER - 0.1
			if(organ_name in list("l_hand", "r_hand"))
				limb_layer = MOB_LAYER + 0.3
			else if(organ_name in list("l_arm", "r_arm"))
				limb_layer = MOB_LAYER + 0.2

			var/icon/limb_icon = new /icon('icons/mob/human.dmi', "[O.icon_name]_[g][state]")
			if(s_tone >= 0)
				limb_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
			else
				limb_icon.Blend(rgb(-s_tone, -s_tone, -s_tone), ICON_SUBTRACT)
			if(zombie || pale)
				limb_icon.Blend(rgb(100,100,100))

			overlays += image("icon" = limb_icon, "layer" = limb_layer)

	// ===== PSYNET UNIFORM =====
	if(istype(w_uniform, /obj/item/clothing/psynet_uniform))
		var/obj/item/clothing/psynet_uniform/P = w_uniform
		var/icon/file = (gender == MALE) ? P.male_sprite_file : P.female_sprite_file
		var/base = P.inventory_state
		if(base == "") base = P.icon_state
		var/suffix = (lying) ? "_l" : "_s"

		var/icon/body_icon = new /icon(file, "[base]_body[suffix]")
		if(P.base_color) body_icon.Blend(P.base_color, ICON_MULTIPLY)
		overlays += image("icon" = body_icon, "layer" = MOB_LAYER + 0.11)

		if(!(P.torn_parts.Find("l_arm")) && !(P.sleeves_up.Find("l_arm")))
			var/datum/organ/external/l_arm = organs["l_arm"]
			if(!l_arm || !l_arm.destroyed)
				var/icon/l_arm_icon = new /icon(file, "[base]_l_arm[suffix]")
				if(P.base_color) l_arm_icon.Blend(P.base_color, ICON_MULTIPLY)
				overlays += image("icon" = l_arm_icon, "layer" = MOB_LAYER + 0.25)

		if(!(P.torn_parts.Find("r_arm")) && !(P.sleeves_up.Find("r_arm")))
			var/datum/organ/external/r_arm = organs["r_arm"]
			if(!r_arm || !r_arm.destroyed)
				var/icon/r_arm_icon = new /icon(file, "[base]_r_arm[suffix]")
				if(P.base_color) r_arm_icon.Blend(P.base_color, ICON_MULTIPLY)
				overlays += image("icon" = r_arm_icon, "layer" = MOB_LAYER + 0.25)

		if(!(P.torn_parts.Find("l_leg")) && !(P.pants_up.Find("l_leg")))
			var/datum/organ/external/l_leg = organs["l_leg"]
			if(!l_leg || !l_leg.destroyed)
				var/icon/l_leg_icon = new /icon(file, "[base]_l_leg[suffix]")
				if(P.base_color) l_leg_icon.Blend(P.base_color, ICON_MULTIPLY)
				overlays += image("icon" = l_leg_icon, "layer" = MOB_LAYER + 0.12)

		if(!(P.torn_parts.Find("r_leg")) && !(P.pants_up.Find("r_leg")))
			var/datum/organ/external/r_leg = organs["r_leg"]
			if(!r_leg || !r_leg.destroyed)
				var/icon/r_leg_icon = new /icon(file, "[base]_r_leg[suffix]")
				if(P.base_color) r_leg_icon.Blend(P.base_color, ICON_MULTIPLY)
				overlays += image("icon" = r_leg_icon, "layer" = MOB_LAYER + 0.12)

		if(base == "migrant")
			var/icon/over_file = (gender == MALE) ? 'icons/mob/clothing/overclothes_male2.dmi' : 'icons/mob/clothing/overclothes_female.dmi'
			var/over_suffix = (lying) ? "_l" : "_s"

			if(!lying)
				var/icon/body_over = new /icon(over_file, "emigrant_body[over_suffix]")
				if(P.overlay_color) body_over.Blend(P.overlay_color, ICON_MULTIPLY)
				overlays += image("icon" = body_over, "layer" = MOB_LAYER + 0.14)

				if(!(P.torn_parts.Find("l_arm")) && !(P.sleeves_up.Find("l_arm")))
					var/datum/organ/external/l_arm = organs["l_arm"]
					if(!l_arm || !l_arm.destroyed)
						var/icon/l_arm_over = new /icon(over_file, "emigrant_l_arm[over_suffix]")
						if(P.overlay_color) l_arm_over.Blend(P.overlay_color, ICON_MULTIPLY)
						overlays += image("icon" = l_arm_over, "layer" = MOB_LAYER + 0.3)

				if(!(P.torn_parts.Find("r_leg")) && !(P.pants_up.Find("r_leg")))
					var/datum/organ/external/r_leg = organs["r_leg"]
					if(!r_leg || !r_leg.destroyed)
						var/icon/r_leg_over = new /icon(over_file, "emigrant_r_leg[over_suffix]")
						if(P.overlay_color) r_leg_over.Blend(P.overlay_color, ICON_MULTIPLY)
						overlays += image("icon" = r_leg_over, "layer" = MOB_LAYER + 0.13)
				if(!(P.torn_parts.Find("l_leg")) && !(P.pants_up.Find("l_leg")))
					var/datum/organ/external/r_leg = organs["l_leg"]
					if(!r_leg || !r_leg.destroyed)
						var/icon/r_leg_over = new /icon(over_file, "emigrant_l_leg[over_suffix]")
						if(P.overlay_color) r_leg_over.Blend(P.overlay_color, ICON_MULTIPLY)
						overlays += image("icon" = r_leg_over, "layer" = MOB_LAYER + 0.13)
			else
				var/icon/body_over = new /icon(over_file, "emigrant_body[over_suffix]")
				if(P.overlay_color) body_over.Blend(P.overlay_color, ICON_MULTIPLY)
				overlays += image("icon" = body_over, "layer" = MOB_LAYER + 0.14)

			var/icon/letro_icon = new /icon(file, "letro_body[over_suffix]")
			if(P.overlay_color) letro_icon.Blend(P.overlay_color, ICON_MULTIPLY)
			overlays += image("icon" = letro_icon, "layer" = MOB_LAYER + 0.15)

	// Uniform
	if (w_uniform)
		w_uniform.screen_loc = ui_iclothing
		if (istype(w_uniform, /obj/item/clothing/under))
			var/t1 = w_uniform.item_color
			if (!t1) t1 = w_uniform.icon_state
			if(!lying)
				var/datum/organ/external/rhand = organs["r_hand"]
				var/datum/organ/external/lhand = organs["l_hand"]
				var/iconx = text("[][][][]",t1, (!(lying) ? "_s" : "_l"),(rhand.destroyed ? "_rhand" : null),(lhand.destroyed ? "_lhand" : null))
				overlays += image('icons/mob/uniform.dmi',"[iconx]",MOB_LAYER)
			else
				var/iconx = "[t1]_l"
				overlays += image('icons/mob/uniform.dmi',"[iconx]",MOB_LAYER)
			if (w_uniform.blood_DNA)
				var/icon/stain_icon = icon('icons/effects/blood.dmi', "uniformblood[!lying ? "" : "2"]")
				overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if (wear_id)
		overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "id[!lying ? null : "2"]", "layer" = MOB_LAYER)

	if (client)
		client.screen -= hud_used.intents
		client.screen -= hud_used.mov_int

	// Gloves
	if (gloves)
		var/datum/organ/external/rhand = organs["r_hand"]
		var/datum/organ/external/lhand = organs["l_hand"]
		var/t1 = gloves.item_state
		if (!t1) t1 = gloves.icon_state
		if(!lying)
			if(!rhand || !rhand.destroyed)
				overlays += image('icons/mob/hands.dmi',"[t1]_rhand",MOB_LAYER)
			if(!lhand || !lhand.destroyed)
				overlays += image('icons/mob/hands.dmi',"[t1]_lhand",MOB_LAYER)
		else
			if(!rhand || !rhand.destroyed)
				overlays += image('icons/mob/hands.dmi',"[t1]2_rhand",MOB_LAYER)
			if(!lhand || !lhand.destroyed)
				overlays += image('icons/mob/hands.dmi',"[t1]2_lhand",MOB_LAYER)
		if (gloves.blood_DNA)
			var/icon/stain_icon = icon('icons/effects/blood.dmi', "bloodyhands[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
	else if (blood_DNA)
		var/icon/stain_icon = icon('icons/effects/blood.dmi', "bloodyhands[!lying ? "" : "2"]")
		overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	// Glasses
	if (glasses)
		var/t1 = glasses.icon_state
		overlays += image("icon" = 'icons/mob/eyes.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)

	// Ears
	if (ears)
		var/t1 = ears.icon_state
		overlays += image("icon" = 'icons/mob/ears.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)

	// Shoes
	if (shoes)
		var/t1 = shoes.icon_state
		var/datum/organ/external/rfoot = organs["r_foot"]
		var/datum/organ/external/lfoot = organs["l_foot"]
		if((!rfoot || !rfoot.destroyed) && (!lfoot || !lfoot.destroyed))
			overlays += image("icon" = 'icons/mob/feet.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (shoes.blood_DNA)
			var/icon/stain_icon = icon('icons/effects/blood.dmi', "shoesblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)

	if(client) hud_used.other_update()

	// Mask
	if (wear_mask)
		if (istype(wear_mask, /obj/item/clothing/mask))
			var/t1 = wear_mask.icon_state
			overlays += image("icon" = 'icons/mob/mask.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
			if (!istype(wear_mask, /obj/item/clothing/mask/cigarette))
				if (wear_mask.blood_DNA)
					var/icon/stain_icon = icon('icons/effects/blood.dmi', "maskblood[!lying ? "" : "2"]")
					overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		wear_mask.screen_loc = ui_mask

	if (client)
		if (i_select)
			if (intent) client.screen += hud_used.intents
			else i_select.screen_loc = null
		if (m_select)
			if (m_int) client.screen += hud_used.mov_int
			else m_select.screen_loc = null

	// Suit
	if (wear_suit)
		if (istype(wear_suit, /obj/item/clothing/suit))
			var/t1 = wear_suit.icon_state
			overlays += image("icon" = 'icons/mob/suit.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		if (wear_suit.blood_DNA)
			var/icon/stain_icon = icon('icons/effects/blood.dmi', "suitblood[!lying ? "" : "2"]")
			overlays += image("icon" = stain_icon, "layer" = MOB_LAYER)
		wear_suit.screen_loc = ui_oclothing
		if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
			if (handcuffed)
				handcuffed.loc = loc; handcuffed.layer = initial(handcuffed.layer); handcuffed = null
			if ((l_hand || r_hand))
				var/h = hand; hand = 1; drop_item(); hand = 0; drop_item(); hand = h

	// Hair
	if(!lying)
		var/icon/hair_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[hair_icon_state]_s")
		hair_s.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
		overlays += image("icon" = hair_s, "layer" = MOB_LAYER)
	else
		var/icon/hair_l = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[hair_icon_state]_l")
		hair_l.Blend(rgb(r_hair, g_hair, b_hair), ICON_ADD)
		overlays += image("icon" = hair_l, "layer" = MOB_LAYER)

	// Head
	if (head)
		var/t1 = head.icon_state
		overlays += image("icon" = 'icons/mob/head.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		head.screen_loc = ui_head

	// Belt
	if (belt)
		var/t1 = belt.item_state; if (!t1) t1 = belt.icon_state
		overlays += image("icon" = 'icons/mob/belt.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		belt.screen_loc = ui_belt

	// Name
	if ((wear_mask && !(wear_mask.see_face)) || (head && !(head.see_face)))
		name = (wear_id && wear_id.registered) ? wear_id.registered : "Unknown"
	else
		name = (wear_id && wear_id.registered != real_name) ? "[real_name] (as [wear_id.registered])" : (face_dmg ? "Unknown" : real_name)

	if (wear_id) wear_id.screen_loc = ui_id
	if (l_store) l_store.screen_loc = ui_storage1
	if (r_store) r_store.screen_loc = ui_storage2

	// Back
	if (back)
		var/t1 = back.icon_state
		overlays += image("icon" = 'icons/mob/back.dmi', "icon_state" = text("[][]", t1, (!( lying ) ? null : "2")), "layer" = MOB_LAYER)
		back.screen_loc = ui_back

	if (handcuffed)
		pulling = null
		overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "handcuff[!lying ? "1" : "2"]", "layer" = MOB_LAYER)

	if (client)
		client.screen -= contents
		client.screen += contents

	if (r_hand)
		var/datum/organ/external/rhand = organs["r_hand"]
		if(!rhand || !rhand.destroyed)
			var/icon_file = 'icons/mob/items/items_righthand.dmi'
			var/icon_state = r_hand.item_state ? r_hand.item_state : r_hand.icon_state

			if(istype(r_hand, /obj/item/weapon/gurps))
				var/obj/item/weapon/gurps/GW = r_hand
				if(lying)
					icon_file = 'icons/mob/items/items_righthand2.dmi'
				else if(gender == FEMALE)
					// Проверяем есть ли женский спрайт для этого оружия
					var/list/female_states = list("gun", "gld", "biggun", "shotgun", "smallgun", "stick", "fire_extinguisher", "smg")
					if(GW.inhand_state in female_states)
						icon_file = 'icons/mob/items/items_righthand_f.dmi'
				if(GW.inhand_state)
					icon_state = GW.inhand_state

			if(icon_state)
				overlays += image("icon" = icon_file, "icon_state" = icon_state, "layer" = MOB_LAYER+1)
		r_hand.screen_loc = ui_rhand

	if (l_hand)
		var/datum/organ/external/lhand = organs["l_hand"]
		if(!lhand || !lhand.destroyed)
			var/icon_file = 'icons/mob/items/items_lefthand.dmi'
			var/icon_state = l_hand.item_state ? l_hand.item_state : l_hand.icon_state

			if(istype(l_hand, /obj/item/weapon/gurps))
				var/obj/item/weapon/gurps/GW = l_hand
				if(lying)
					icon_file = 'icons/mob/items/items_lefthand2.dmi'
				else if(gender == FEMALE)
					var/list/female_states = list("gun", "gld", "biggun", "shotgun", "smallgun", "stick", "fire_extinguisher", "smg")
					if(GW.inhand_state in female_states)
						icon_file = 'icons/mob/items/items_lefthand_f.dmi'
				if(GW.inhand_state)
					icon_state = GW.inhand_state

			if(icon_state)
				overlays += image("icon" = icon_file, "icon_state" = icon_state, "layer" = MOB_LAYER+1)
		l_hand.screen_loc = ui_lhand

	var/shielded = 0
	for (var/obj/item/device/shield/S in src)
		if (S.active)
			shielded = 1
			break


	if(client && client.admin_invis)
		invisibility = 100
	else
		invisibility = 0

	if (shielded) overlays += image("icon" = 'icons/mob/mob.dmi', "icon_state" = "shield", "layer" = MOB_LAYER)

	for (var/mob/M in viewers(1, src))
		if ((M.client && M.machine == src)) spawn (0) show_inv(M); return

	last_b_state = stat
	if(mutantrace && !lying)
		overlays += image("icon" = 'icons/effects/genetics.dmi', "icon_state" = "[mutantrace]_t", "layer" = MOB_LAYER)

// ============================
// АТАКИ РУКОЙ И ОРУЖИЕМ
// ============================
/mob/living/carbon/human/hand_p(mob/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (M.a_intent == "hurt")
		if (istype(M.wear_mask, /obj/item/clothing/mask/muzzle))
			return
		if (health > 0)
			if (istype(wear_suit, /obj/item/clothing/suit/space))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/space/santa))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/bio_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/armor || /obj/item/clothing/suit/storage/armourrigvest))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else if (istype(wear_suit, /obj/item/clothing/suit/swat_suit))
				if (prob(25))
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M.name] has attempted to bite []!</B>", src), 1)
					return
			else
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				var/damage = rand(1, 3)
				var/zones = list()
				for(var/datum/organ/external/p in organs2)
					if(!p.destroyed)
						zones += p.name
				if(!zones)
					return
				var/dam_zone = pick(zones)
				if (istype(organs[text("[]", dam_zone)], /datum/organ/external))
					var/datum/organ/external/temp = organs[text("[]", dam_zone)]
					if (temp.take_damage(damage, 0))
						UpdateDamageIcon()
					else
						UpdateDamage()
				updatehealth()
	return

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if (M.a_intent == "help")
		if (M.zombie) return
		if (health > 0)
			if (w_uniform) w_uniform.add_fingerprint(M)
			sleeping = 0; resting = 0
			if (paralysis >= 3) paralysis -= 3
			if (stunned >= 3) stunned -= 3
			if (weakened >= 3) weakened -= 3
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\blue [] shakes [] trying to wake [] up!", M, src, src), 1)
		else
			if (M.health >= -75.0)
				if (((M.head && M.head.flags & 4) || ((M.wear_mask && !(M.wear_mask.flags & 32)) || ((head && head.flags & 4) || (wear_mask && !(wear_mask.flags & 32))))))
					M << "\blue <B>Remove that mask!</B>"
					return
				var/obj/equip_e/human/O = new /obj/equip_e/human()
				O.source = M; O.target = src; O.s_loc = M.loc; O.t_loc = loc; O.place = "CPR"
				requests += O
				spawn(0) O.process()
				return
		return

	if (M.a_intent == "grab")
		if (M == src) return
		if (M.zombie) return
		if (w_uniform) w_uniform.add_fingerprint(M)
		var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M)
		G.assailant = M
		if (M.hand) M.l_hand = G
		else M.r_hand = G
		G.layer = 20; G.affecting = src; grabbed_by += G; G.synch()
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		return

	if (M.a_intent == "hurt")
		if (w_uniform) w_uniform.add_fingerprint(M)
		// GURPS-атака (функции из gurps_combat.dm)
		var/obj/item/weapon = (M.hand ? M.l_hand : M.r_hand)
		if(weapon && weapon.force > 0)
			gurps_weapon_attack(M, src, weapon, M.zone_sel?.selecting)
		else
			gurps_unarmed_attack(M, src)
		return

	if (!(lying) && !(M.gloves && M.gloves.elecgen == 1))
		if (w_uniform) w_uniform.add_fingerprint(M)
		var/randn = rand(1, 100)
		if (randn <= 25)
			weakened = 2
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='danger'><B>[M] толкает [src]!</B></span>")
		else if (randn <= 60)
			drop_item()
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='danger'><B>[M] обезоруживает [src]!</B></span>")
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='warning'>[M] пытается обезоружить [src]!</span>")
		return
	return

// ============================
// АТАКА ПРИШЕЛЬЦА
// ============================
/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if (!ticker)
		M << "You cannot attack people before the game has started."
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return

	if (M.a_intent == "help")
		for(var/mob/O in viewers(src, null))
			O.show_message(text("\blue [M] caresses [src] with its sythe like arm."), 1)
	else
		if (M.a_intent == "grab")
			if (M == src)
				return
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M )
			G.assailant = M
			if (M.hand)
				M.l_hand = G
			else
				M.r_hand = G
			G.layer = 20
			G.affecting = src
			grabbed_by += G
			G.synch()
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			for(var/mob/O in viewers(src, null))
				O.show_message(text("\red [] has grabbed [] passively!", M, src), 1)
		else
			if (M.a_intent == "hurt")
				if (w_uniform)
					w_uniform.add_fingerprint(M)
				var/damage = rand(10, 20)
				var/datum/organ/external/affecting = organs["chest"]
				var/t = M.zone_sel.selecting
				if ((t in list( "eyes", "mouth" )))
					t = "head"
				var/def_zone = ran_zone(t)
				if (organs[def_zone])
					affecting = organs[def_zone]
				if ((istype(affecting, /datum/organ/external) && prob(90)))
					playsound(loc, "punch", 25, 1, -1)
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[] has slashed at []!</B>", M, src), 1)
					if (def_zone == "head")
						if ((((head && head.body_parts_covered & HEAD) || (wear_mask && wear_mask.body_parts_covered & HEAD)) && prob(99)))
							if (prob(20))
								affecting.take_damage(damage, 0)
							else
								show_message("\red You have been protected from a hit to the head.")
							return
						if (damage > 4.9)
							if (weakened < 10)
								weakened = rand(10, 15)
							for(var/mob/O in viewers(M, null))
								O.show_message(text("\red <B>[] has weakened []!</B>", M, src), 1, "\red You hear someone fall.", 2)
						affecting.take_damage(damage)
					else
						if (def_zone == "chest")
							if ((((wear_suit && wear_suit.body_parts_covered & UPPER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(85)))
								show_message("\red You have been protected from a hit to the chest.")
								return
							if (damage > 4.9)
								if (prob(50))
									if (weakened < 5)
										weakened = 5
									playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
								else
									if (stunned < 5)
										stunned = 5
									for(var/mob/O in viewers(src, null))
										O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
								if(stat != 2)	stat = 1
							affecting.take_damage(damage)
						else
							if (def_zone == "groin")
								if ((((wear_suit && wear_suit.body_parts_covered & LOWER_TORSO) || (w_uniform && w_uniform.body_parts_covered & LOWER_TORSO)) && prob(75)))
									show_message("\red You have been protected from a hit to the lower chest.")
									return
								if (damage > 4.9)
									if (prob(50))
										if (weakened < 3)
											weakened = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has knocked down []!</B>", M, src), 1, "\red You hear someone fall.", 2)
									else
										if (stunned < 3)
											stunned = 3
										for(var/mob/O in viewers(src, null))
											O.show_message(text("\red <B>[] has stunned []!</B>", M, src), 1)
									if(stat != 2)	stat = 1
								affecting.take_damage(damage)
							else
								affecting.take_damage(damage)

					UpdateDamageIcon()
					updatehealth()
				else
					for(var/mob/O in viewers(src, null))
						O.show_message(text("\red <B>[M] has lunged at [src] but missed!</B>"), 1)
					return
			else
				if (!( lying ))
					if (w_uniform)
						w_uniform.add_fingerprint(M)
					var/randn = rand(1, 100)
					if (randn <= 25)
						weakened = 2
						for(var/mob/O in viewers(src, null))
							O.show_message(text("\red <B>[] has knocked over []!</B>", M, src), 1)
					else
						if (randn <= 60)
							drop_item()
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has knocked the item out of []'s hand!</B>", M, src), 1)
						else
							for(var/mob/O in viewers(src, null))
								O.show_message(text("\red <B>[] has tried to knock the item out of []'s hand!</B>", M, src), 1)
	return

/mob/living/carbon/human/restrained()
	if (handcuffed)
		return 1
	if (istype(wear_suit, /obj/item/clothing/suit/straight_jacket))
		return 1
	return 0

// ============================
// ОБНОВЛЕНИЕ ВНЕШНОСТИ
// ============================
/mob/living/carbon/human/proc/update_hair()
	switch(h_style)
		if("Short Hair") hair_icon_state = "hair_a"
		if("Long Hair") hair_icon_state = "hair_b"
		if("Cut Hair") hair_icon_state = "hair_c"
		if("Mohawk") hair_icon_state = "hair_d"
		if("Balding") hair_icon_state = "hair_e"
		if("Wave") hair_icon_state = "hair_f"
		if("Bedhead") hair_icon_state = "hair_bedhead"
		if("Dreadlocks") hair_icon_state = "hair_dreads"
		if("Ponytail") hair_icon_state = "hair_ponytail"
		else hair_icon_state = "bald"

	switch(f_style)
		if ("Watson") face_icon_state = "facial_watson"
		if ("Chaplin") face_icon_state = "facial_chaplin"
		if ("Selleck") face_icon_state = "facial_selleck"
		if ("Neckbeard") face_icon_state = "facial_neckbeard"
		if ("Full Beard") face_icon_state = "facial_fullbeard"
		if ("Long Beard") face_icon_state = "facial_longbeard"
		if ("Van Dyke") face_icon_state = "facial_vandyke"
		if ("Elvis") face_icon_state = "facial_elvis"
		if ("Abe") face_icon_state = "facial_abe"
		if ("Chinstrap") face_icon_state = "facial_chin"
		if ("Hipster") face_icon_state = "facial_hip"
		if ("Goatee") face_icon_state = "facial_gt"
		if ("Hogan") face_icon_state = "facial_hogan"
		else face_icon_state = "bald"

/mob/living/carbon/human/proc/update_body()
	if(stand_icon) del(stand_icon)
	if(lying_icon) del(lying_icon)

	if(mutantrace) return

	var/g = (gender == MALE) ? "m" : "f"

	stand_icon = new /icon('icons/mob/human.dmi', "blank")
	lying_icon = new /icon('icons/mob/human.dmi', "blank")

	for(var/organ_name in organs)
		var/datum/organ/external/O = organs[organ_name]
		if(!istype(O) || O.destroyed) continue
		if(O.icon_name && O.name != "neck")
			stand_icon.Blend(new /icon('icons/mob/human.dmi', "[O.icon_name]_[g]_s"), ICON_OVERLAY)
			lying_icon.Blend(new /icon('icons/mob/human.dmi', "[O.icon_name]_[g]_l"), ICON_OVERLAY)

	if(underwear > 0)
		stand_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('icons/mob/human.dmi', "underwear[underwear]_[g]_l"), ICON_OVERLAY)

	if(mutations & 64)
		stand_icon.Blend(new /icon('icons/mob/human.dmi', "husk_s"), ICON_OVERLAY)
		lying_icon.Blend(new /icon('icons/mob/human.dmi', "husk_l"), ICON_OVERLAY)

	if(s_tone >= 0)
		stand_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
		lying_icon.Blend(rgb(s_tone, s_tone, s_tone), ICON_ADD)
	else
		stand_icon.Blend(rgb(-s_tone, -s_tone, -s_tone), ICON_SUBTRACT)
		lying_icon.Blend(rgb(-s_tone, -s_tone, -s_tone), ICON_SUBTRACT)

	if(zombie || pale)
		stand_icon.Blend(rgb(100,100,100))
		lying_icon.Blend(rgb(100,100,100))

/mob/living/carbon/human/proc/update_face()
	if(organs)
		var/datum/organ/external/org = organs["head"]
		if(org)
			if(org.destroyed)
				del(face_standing)
				del(face_lying)
				return
	del(face_standing)
	del(face_lying)

	if (mutantrace)
		return

	var/g = "m"
	if (gender == MALE)
		g = "m"
	else if (gender == FEMALE)
		g = "f"

	var/icon/eyes_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_s")
	var/icon/eyes_l = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "eyes_l")
	eyes_s.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)
	eyes_l.Blend(rgb(r_eyes, g_eyes, b_eyes), ICON_ADD)

	var/icon/facial_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[face_icon_state]_s")
	var/icon/facial_l = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "[face_icon_state]_l")
	facial_s.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)
	facial_l.Blend(rgb(r_facial, g_facial, b_facial), ICON_ADD)

	var/icon/mouth_s = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "mouth_[g]_s")
	var/icon/mouth_l = new/icon("icon" = 'icons/mob/human_face.dmi', "icon_state" = "mouth_[g]_l")

	eyes_s.Blend(mouth_s, ICON_OVERLAY)
	eyes_l.Blend(mouth_l, ICON_OVERLAY)
	eyes_s.Blend(facial_s, ICON_OVERLAY)
	eyes_l.Blend(facial_l, ICON_OVERLAY)

	face_standing = new /image()
	face_lying = new /image()
	face_standing.icon = eyes_s
	face_lying.icon = eyes_l

	del(mouth_l)
	del(mouth_s)
	del(facial_l)
	del(facial_s)
	del(eyes_l)
	del(eyes_s)

// ============================
// SHOW INV
// ============================
/mob/living/carbon/human/show_inv(mob/user as mob)
	user.machine = src
	var/dat = {"<HTML>
	<B><HR><FONT size=3>[name]</FONT></B><BR><HR>
	<BR><B>Head(Mask):</B> <A href='?src=\ref[src];item=mask'>[(wear_mask ? wear_mask : "Nothing")]</A>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? l_hand : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? r_hand : "Nothing")]</A>
	<BR><B>Gloves:</B> <A href='?src=\ref[src];item=gloves'>[(gloves ? gloves : "Nothing")]</A>
	<BR><B>Eyes:</B> <A href='?src=\ref[src];item=eyes'>[(glasses ? glasses : "Nothing")]</A>
	<BR><B>Ears:</B> <A href='?src=\ref[src];item=ears'>[(ears ? ears : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? head : "Nothing")]</A>
	<BR><B>Shoes:</B> <A href='?src=\ref[src];item=shoes'>[(shoes ? shoes : "Nothing")]</A>
	<BR><B>Belt:</B> <A href='?src=\ref[src];item=belt'>[(belt ? belt : "Nothing")]</A>
	<BR><B>Uniform:</B> <A href='?src=\ref[src];item=uniform'>[(w_uniform ? w_uniform : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? wear_suit : "Nothing")]</A>
	<BR><B>Back:</B> <A href='?src=\ref[src];item=back'>[(back ? back : "Nothing")]</A>
	<BR><B>ID:</B> <A href='?src=\ref[src];item=id'>[(wear_id ? wear_id : "Nothing")]</A>
	<BR>[(handcuffed ? "<A href='?src=\ref[src];item=handcuff'>Handcuffed</A>" : "<A href='?src=\ref[src];item=handcuff'>Not Handcuffed</A>")]
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pockets</A>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A><BR></HTML>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")

/mob/living/carbon/human/verb/fuck()
	set hidden = 1
	alert("Go play HellMOO if you wanna do that.")

/mob/living/carbon/human/HasEntered(var/atom/movable/AM)
	var/obj/machinery/bot/mulebot/MB = AM
	if(istype(MB)) MB.RunOver(src)

/mob/living/carbon/human/proc/zombify()
	zombietime = 0; zombifying = 0; zombie = 1
	update_body()
	src << "\red You've become a zombie"
	if(l_hand) {if(client) client.screen -= l_hand; if(l_hand) {l_hand.loc = loc; l_hand.dropped(src); l_hand.layer = initial(r_hand.layer); l_hand = null}}
	if(r_hand) {if(client) client.screen -= r_hand; if(r_hand) {r_hand.loc = loc; r_hand.dropped(src); r_hand.layer = initial(r_hand.layer); r_hand = null}}
	sight |= SEE_MOBS; see_in_dark = 4; see_invisible = 2
	for(var/mob/O in viewers(src, null))
		O.show_message(text("\red <B>[src] seizes up and falls limp, \his eyes dead and lifeless...</B>"), 1)
	UpdateZombieIcons(); UpdateDamageIcon()

/proc/UpdateZombieIcons()
	spawn(0)
		for(var/mob/living/carbon/human/H in world)
			del(H.zombieimage)
			if(H.zombie) H.zombieimage = image('icons/mob/mob.dmi', loc = H, icon_state = "rev")
			else if(H.zombifying) H.zombieimage = image('icons/mob/mob.dmi', loc = H, icon_state = "rev_head")
			else H.zombieimage = null
		for(var/mob/living/carbon/human/H in world)
			if(H.zombie) for(var/mob/living/carbon/human/N in world) H << N.zombieimage

// ============================
// HEAL DAMAGE
// ============================
/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/organ/external/E = organs[text("[]", zone)]
	if (istype(E, /datum/organ/external))
		if(E.destroyed) return
		if (E.heal_damage(brute, burn)) UpdateDamageIcon()
		else UpdateDamage()
	else return 0
	return

// ============================
// UPDATE DAMAGE ICON
// ============================
/mob/living/carbon/human/UpdateDamageIcon()
	var/list/L = list()
	for (var/t in organs)
		if (istype(organs[t], /datum/organ/external))
			L += organs[t]

	del(body_standing); body_standing = list()
	del(body_lying); body_lying = list()
	bruteloss = 0; fireloss = 0

	for (var/datum/organ/external/O in L)
		if(!O.destroyed)
			O.update_icon()
			bruteloss += O.brute_dam
			fireloss += O.burn_dam

			if(zombie) O.damage_state = "30"

			var/icon/DI = new /icon('icons/mob/dam_human.dmi', O.damage_state)
			DI.Blend(new /icon('icons/mob/dam_mask.dmi', O.icon_name), ICON_MULTIPLY)
			body_standing += DI

			DI = new /icon('icons/mob/dam_human.dmi', "[O.damage_state]-2")
			DI.Blend(new /icon('icons/mob/dam_mask.dmi', "[O.icon_name]2"), ICON_MULTIPLY)
			body_lying += DI

// ============================
// КРОВАВЫЕ СЛЕДЫ ПРИ ХОДЬБЕ
// ============================
/mob/living/carbon/human/Move()
	. = ..()
	if(.)
		if(bloodloss > 5 && prob(bloodloss * 2))
			var/turf/T = get_turf(src)
			if(T && !T.density)
				var/obj/decal/cleanable/blood/tracks/TR = new(T)
				TR.blood_DNA = dna?.unique_enzymes
				TR.blood_type = b_type

//		if(fov_enabled)
//			gurps_fov_apply()

// ============================
// СМЕРТЬ
// ============================
/mob/living/carbon/human/death(gibbed)
	..()
	if(!gibbed && loc && isturf(loc))
		var/should_bleed = FALSE
		for(var/organ_name in organs)
			var/datum/organ/external/E = organs[organ_name]
			if(istype(E))
				if(E.artery_cut || E.destroyed)
					should_bleed = TRUE
					break

		if(should_bleed)
			var/obj/decal/cleanable/blood/pool/P = locate() in loc
			if(!P)
				P = new /obj/decal/cleanable/blood/pool(loc)
				if(dna)
					P.blood_DNA = dna.unique_enzymes
				P.blood_type = b_type
			P.blood_amount += bloodloss * 0.5
			P.update_pool()
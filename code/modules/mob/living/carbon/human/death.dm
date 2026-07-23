/mob/living/carbon/human/death(gibbed)
	if(src.mholder)
		mholder:death()
	if(stat == 2)
		return

	// ===== GURPS: ПРОВЕРКА МОЖНО ЛИ УМЕРЕТЬ =====
	if(!gibbed)
		var/can_die = FALSE
		var/datum/organ/external/chest/C = organs["chest"]
		var/datum/organ/external/head/H = organs["head"]

		if(istype(C) && (C.destroyed || C.brute_dam >= C.max_damage * 0.9))
			can_die = TRUE
		if(istype(H) && (H.destroyed || H.brute_dam >= H.max_damage * 0.9))
			can_die = TRUE
		if(oxyloss >= 100 || toxloss >= 100 || bloodloss >= 50)
			can_die = TRUE
		if(vessel && vessel.get_reagent_amount("blood") <= 0)
			can_die = TRUE

		if(!can_die)
			stat = 1
			paralysis = max(paralysis, 10)
			visible_message("<span class='danger'>[src] теряет сознание от боли!</span>")
			return

	// ===== ЗВУК СМЕРТИ =====
	if(!gibbed)
		if(gender == FEMALE)
			playsound(loc, pick('sound/voice/death_female1.ogg', 'sound/voice/death_female2.ogg', 'sound/voice/death_female3.ogg'), 50, 0)
		else
			playsound(loc, pick('sound/voice/death_male1.ogg', 'sound/voice/death_male2.ogg', 'sound/voice/death_male3.ogg'), 50, 0)

		spawn(5)
			playsound(loc, 'sound/voice/final_words.ogg', 40, 0)

		spawn(0)
			for(var/i = 1 to rand(5, 10))
				pixel_x = rand(-4, 4)
				pixel_y = rand(-2, 2)
				sleep(rand(2, 5))
			pixel_x = 0
			pixel_y = 0

	if(healths)
		healths.icon_state = "health5"
	if(halloss > 0 && (!gibbed))
		halloss = 0
		oxyloss = 0
		return
	if(zombifying)
		zombify()
		return
	stat = 2
	dizziness = 0
	jitteriness = 0
	if(!suiciding)
		unlock_medal("Downsizing", 0, "You are no longer a profitable asset.", "easy")
	else
		unlock_medal("I can't take it anymore!", 0, "Kill yourself...", "easy")
	if (!gibbed)
		canmove = 0
		if(client)
			blind.layer = 0
		lying = 1
		var/h = hand
		hand = 0
		drop_item()
		hand = 1
		drop_item()
		hand = h
		if (istype(wear_suit, /obj/item/clothing/suit/armor/a_i_a_ptank))
			var/obj/item/clothing/suit/armor/a_i_a_ptank/A = wear_suit
			bombers += "[key] has detonated a suicide bomb. Temp = [A.part4.air_contents.temperature-T0C]."
			if(A.status && prob(90))
				A.part4.ignite()

	ticker.mode.check_win()

	if (ticker.mode.name == "traitor" && mind && mind.special_role == "traitor")
		message_admins("\red Traitor [key_name_admin(src)] has died.")

	return ..(gibbed)
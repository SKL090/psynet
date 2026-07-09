/mob/living/carbon/human/examine()
	set src in view()

	usr << "\blue *---------*"

	usr << "\blue [pick("Это же", "Это", "О, это ведь","Класс, это","Это, кажется,")] \icon[icon] <B>[name]</B>!"

	// crappy hack because you can't do \his[src] etc
	var/t_his = "его"
	var/t_him = "него"
	var/t_he = "оно"
	if (gender == MALE)
		t_he = "он"
		t_his = "его"
		t_him = "него"
	else if (gender == FEMALE)
		t_he = "она"
		t_his = "её"
		t_him = "неё"

	if (w_uniform)
		if (w_uniform.blood_DNA)
			usr << "\red [capitalize(t_he)] носит \icon[w_uniform] [w_uniform.name][w_uniform.blood_DNA ? " (в крови)" : ""]!"
		else
			usr << "\blue [capitalize(t_he)] носит \icon[w_uniform] [w_uniform.name]."

	if (handcuffed)
		usr << "\blue [capitalize(t_he)] \icon[handcuffed] закован!"

	if (wear_suit)
		if (wear_suit.blood_DNA)
			usr << "\red [capitalize(t_he)] носит \icon[wear_suit] [wear_suit.name][wear_suit.blood_DNA ? " (в крови)" : ""]!"
		else
			usr << "\blue [capitalize(t_he)] носит \icon[wear_suit] [wear_suit.name]."
	if(glasses)
		usr << "\blue [capitalize(t_he)] также носит \icon[glasses] [glasses.name]."
	if (ears)
		usr << "\blue [capitalize(t_he)] носит \icon[ears] [ears.name] около своего уха."

	if (wear_mask)
		if (wear_mask.blood_DNA)
			usr << "\red [capitalize(t_he)] носит \icon[wear_mask] [wear_mask.name][wear_mask.blood_DNA ? " (в крови) " : ""] на лице!"
		else
			usr << "\blue [capitalize(t_he)] носит \icon[wear_mask] [wear_mask.name] на лице."

	if (l_hand)
		if (l_hand.blood_DNA)
			usr << "\red [capitalize(t_he)] держит \icon[l_hand] [l_hand.name][l_hand.blood_DNA ? " (в крови)" : ""] в левой руке!"
		else
			usr << "\blue [capitalize(t_he)] держит \icon[l_hand] [l_hand.name] в левой руке."

	if (r_hand)
		if (r_hand.blood_DNA)
			usr << "\red [capitalize(t_he)] держит \icon[r_hand] [r_hand.name][r_hand.blood_DNA ? " (в крови)" : ""] в правой руке!"
		else
			usr << "\blue [capitalize(t_he)] держит \icon[r_hand] [r_hand.name] в правой руке."

	if (belt)
		if (belt.blood_DNA)
			usr << "\red [capitalize(t_he)] носит \icon[belt] [belt.name] на поясе!"
		else
			usr << "\blue [capitalize(t_he)] носит \icon[belt] [belt.name] на поясе."

	if (gloves)
		if (gloves.blood_DNA)
			usr << "\red [capitalize(t_he)] носит \icon[gloves] [gloves.name][gloves.blood_DNA ? " (в крови)" : ""] на руках!"
		else
			usr << "\blue [capitalize(t_he)] носит \icon[gloves] [gloves.name] на руках."
	else if (blood_DNA)
		usr << "\red [capitalize(t_his)] руки в крови!"

	if (back)
		usr << "\blue [capitalize(t_he)] носит \icon[back] [back.name] на спине."

	if (wear_id)
		if (wear_id.registered != real_name && in_range(src, usr) && prob(10))
			usr << "\red [capitalize(t_he)] носит карту \icon[wear_id] [wear_id.name], но здесь что-то не так..."
		else
			usr << "\blue [capitalize(t_he)] носит карту \icon[wear_id] [wear_id.name]."

	if (is_jittery)
		switch(jitteriness)
			if(300 to INFINITY)
				usr << "\red [src] бьётся в конвульсиях."
			if(200 to 300)
				usr << "\red [src] looks extremely jittery."
			if(100 to 200)
				usr << "\red [src] is twitching ever so slightly."

	var/distance = get_dist(usr,src)
	if(istype(usr, /mob/dead/observer) || usr.stat == 2) // ghosts can see anything
		distance = 1
	if (stat == 1 || stat == 2 || holdbreath)
		usr << "\red [name] не реагирует на происходящее вокруг [t_him], [t_his] глаза закрыты."
		if( (!isbreathing || holdbreath) && distance <= 3)
			usr << "\red [name], кажется, не дышит."
	else if (brainloss >= 60)
		usr << "\red У [t_him] туповатое выражение лица."
	if (bruteloss)
		if (bruteloss < 30)
			usr << "\red [name] выглядит слегка болезненно!"
		else
			usr << "\red <B>[name] выглядит достаточно болезненно!</B>"

	if (fireloss)
		if (fireloss < 30)
			usr << "\red [name] выглядит слегка обожженным!"
		else
			usr << "\red <B>[name] выглядит почти обгоревшим!</B>"

	if (stat == 2 || changeling_fakedeath == 1 || zombie)
		if(distance <= 1)
			if(istype(usr, /mob/living/carbon/human) && usr.stat == 0)
				for(var/mob/O in viewers(usr.loc, null))
					O.show_message("[usr] проверяет пульс [src].", 1)
			usr << "\red У [name] нет пульса!"

	for(var/datum/organ/external/temp in organs2)
		if(temp.destroyed)
			usr << "\red У [t_him] отсутствует [temp.display_name]."
		if(temp.wounds)
			for(var/datum/organ/external/wound/w in temp.wounds)
				var/size = w.wound_size
				var/sizetext
				switch(size)
					if(1)
						sizetext = "пореза"
					if(2)
						sizetext = "глубокого пореза"
					if(3)
						sizetext = "раны"
					if(4)
						sizetext = "резаной раны"
					if(5)
						sizetext = "большой резаной раны"
					if(6)
						sizetext = "прорезанной раны"
				if(w.bleeding)
					usr << "\red Из [sizetext] на [t_his] [temp.display_name] течёт кровь."
					continue
	usr << "\blue *---------*"

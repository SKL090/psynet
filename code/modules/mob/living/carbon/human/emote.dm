/mob/living/carbon/human/emote(var/act)

	if(src.stat == 2 && act != "stopbreath")
		return

	var/param = null

	if (findtext(act, " ", 1, null))
		var/t1 = findtext(act, " ", 1, null)
		param = copytext(act, t1 + 1, length(act) + 1)
		act = copytext(act, 1, t1)

	var/muzzled = istype(wear_mask, /obj/item/clothing/mask/muzzle)
	var/m_type = 1

	for (var/obj/item/weapon/implant/I in src)
		if (I.implanted)
			I.trigger(act, src)

	var/message = ""
	switch(act)
		if ("blink")
			message = "<B>[src]</B> blinks."
			m_type = 1
		if ("blink_r")
			message = "<B>[src]</B> blinks rapidly."
			m_type = 1
		if ("bow")
			if (!buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (findtext(A.name,param,1,0))
							M = A
							break
				if (!M) param = null
				if (M) message = "<B>[src]</B> bows to [M]."
				else message = "<B>[src]</B> bows."
			m_type = 1
		if ("custom")
			m_type = 0
			if(copytext(param,1,2) == "v") m_type = 1
			else if(copytext(param,1,2) == "h") m_type = 2
			else
				var/input2 = input("Is this a visible or hearable emote?") in list("Visible","Hearable")
				if (input2 == "Visible") m_type = 1
				else if (input2 == "Hearable") m_type = 2
				else
					alert("Unable to use this emote, must be either hearable or visible.")
					return
			if(m_type) param = trim(copytext(param,2))
			else param = trim(param)
			var/input
			if(param == "") input = input("Choose an emote to display.")
			else input = param
			if(input != "") message = "<B>[src]</B> [input]"
		if ("salute")
			if (!buckled)
				var/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (findtext(A.name,param,1,0))
							M = A
							break
				if (!M) param = null
				if (param) message = "<B>[src]</B> salutes to [param]."
				else message = "<B>[src]</b> salutes."
			m_type = 1
		if ("choke")
			if (!muzzled)
				message = "<B>[src]</B> chokes!"
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/strangle/strangling_1.ogg','sound/voice/strangle/strangling_2.ogg','sound/voice/strangle/strangling_3.ogg'), 50, 1)
				else
					playsound(loc, pick('sound/voice/strangle/strangle_male.ogg','sound/voice/strangle/strangle_male2.ogg','sound/voice/strangle/strangle_male3.ogg'), 50, 1)
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2
		if ("clap")
			if (!restrained())
				message = "<B>[src]</B> claps."
				m_type = 2
		if ("flap")
			if (!restrained())
				message = "<B>[src]</B> flaps his wings."
				m_type = 2
		if ("aflap")
			if (!restrained())
				message = "<B>[src]</B> flaps his wings ANGRILY!"
				m_type = 2
		if ("drool")
			message = "<B>[src]</B> drools."
			m_type = 1
		if ("eyebrow")
			message = "<B>[src]</B> raises an eyebrow."
			m_type = 1
		if ("chuckle")
			if (!muzzled)
				message = "<B>[src]</B> chuckles."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if ("twitch")
			message = "<B>[src]</B> twitches violently."
			m_type = 1
		if ("twitch_s")
			message = "<B>[src]</B> twitches."
			m_type = 1
		if ("faint")
			message = "<B>[src]</B> faints."
			sleeping = 1
			m_type = 1

		if ("cough")
			if (!muzzled)
				message = "<B>[src]</B> кашляет!"
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/cough01_woman.ogg','sound/voice/cough02_woman.ogg','sound/voice/cough03_woman.ogg','sound/voice/cough04_woman.ogg'), 50, 1)
				else
					playsound(loc, pick('sound/voice/cough01_man.ogg','sound/voice/cough02_man.ogg','sound/voice/cough03_man.ogg','sound/voice/cough04_man.ogg'), 50, 1)
			else
				message = "<B>[src]</B> makes a strong noise."
				m_type = 2


		if ("frown")
			message = "<B>[src]</B> frowns."
			m_type = 1
		if ("nod")
			message = "<B>[src]</B> nods."
			m_type = 1
		if ("blush")
			message = "<B>[src]</B> blushes."
			m_type = 1

		// ===== GASP — С ПРОВЕРКОЙ ПОЛА =====
		if ("gasp")
			if (!muzzled)
				message = "<B>[src]</B> gasps!"
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/gasp_female1.ogg', 'sound/voice/gasp_female2.ogg','sound/voice/gasp_female3.ogg','sound/voice/gasp_female4.ogg','sound/voice/gasp_female5.ogg','sound/voice/gasp_female6.ogg','sound/voice/gasp_female7.ogg'), 50, 1)
				else
					playsound(loc, pick('sound/voice/gasp_male1.ogg','sound/voice/gasp_male2.ogg','sound/voice/gasp_male3.ogg','sound/voice/gasp_male4.ogg','sound/voice/gasp_male5.ogg','sound/voice/gasp_male6.ogg','sound/voice/gasp_male7.ogg'), 50, 1)
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2

		if ("breathe")
			message = "<B>[src]</B> breathes."
			m_type = 1
			holdbreath = 0
		if ("stopbreath")
			message = "<B>[src]</B> stops breathing..."
			m_type = 1
		if ("holdbreath")
			message = "<B>[src]</B> stops breathing..."
			m_type = 1
			holdbreath = 1
		if("struckdown")
			message = "<B>[src]</B>, Station Dweller, has been struck down."
			m_type = 2
		if ("giggle")
			if (!muzzled)
				message = "<B>[src]</B> giggles."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if ("glare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M) param = null
			if (param) message = "<B>[src]</B> glares at [param]."
			else message = "<B>[src]</B> glares."
		if ("stare")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M) param = null
			if (param) message = "<B>[src]</B> stares at [param]."
			else message = "<B>[src]</B> stares."
		if ("look")
			var/M = null
			if (param)
				for (var/mob/A in view(null, null))
					if (findtext(A.name,param,1,0))
						M = A
						break
			if (!M) param = null
			if (param) message = "<B>[src]</B> looks at [param]."
			else message = "<B>[src]</B> looks."
			m_type = 1
		if ("grin")
			message = "<B>[src]</B> grins."
			m_type = 1

		// ===== CRY — С ПРОВЕРКОЙ ПОЛА =====
		if ("cry")
			if (!muzzled)
				message = "<B>[src]</B> плачет."
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/cry_woman01.ogg','sound/voice/cry_woman02.ogg','sound/voice/cry_woman03.ogg'), 50, 1)
				else
					playsound(loc, pick('sound/voice/cry_man01.ogg', 'sound/voice/cry_man02.ogg', 'sound/voice/cry_man03.ogg',), 50, 1)
			else
				message = "<B>[src]</B> makes a weak noise. \He frowns."
				m_type = 2

		if ("sigh")
			if (!muzzled)
				message = "<B>[src]</B> sighs."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2

		// ===== LAUGH — С ПРОВЕРКОЙ ПОЛА =====
		if ("laugh")
			if (!muzzled)
				message = "<B>[src]</B> смеётся."
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/laugh_female1.ogg','sound/voice/laugh_female2.ogg','sound/voice/laugh_female3.ogg'), 50, 1)
				else
					if(gurps_strength >= 13)
						playsound(loc, pick('sound/voice/stronglaugh1.ogg', 'sound/voice/stronglaugh2.ogg', 'sound/voice/stronglaugh3.ogg'), 50, 1)
					else
						playsound(loc, pick('sound/voice/laugh/harris_laugh_01.ogg','sound/voice/laugh/harris_laugh_02.ogg','sound/voice/laugh/harris_laugh_03.ogg'), 50, 1)
			else
				message = "<B>[src]</B> издаёт звук."
				m_type = 2

		if ("mumble")
			message = "<B>[src]</B> mumbles."
			m_type = 2
		if ("grumble")
			if (!muzzled)
				message = "<B>[src]</B> grumbles."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2

		// ===== GROAN — СТОН С ПРОВЕРКОЙ ПОЛА =====
		if ("groan")
			if (!muzzled)
				message = "<B>[src]</B> стонет!"
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/female_moan_wounded.ogg','sound/voice/female_moan_wounded2.ogg','sound/voice/female_moan_wounded3.ogg'), 50, 1)
				else
					playsound(loc, pick('sound/voice/male_moan_1.ogg','sound/voice/male_moan_2.ogg','sound/voice/male_moan_3.ogg'), 50, 1)
			else
				message = "<B>[src]</B> издает громкий звук."
				m_type = 2

		if ("howl")
			if (!muzzled)
				message = "<B>[src]</b> howls!"
				m_type = 2
			else
				message = "<B>[src]</B> makes a loud noise."
				m_type = 2
		if ("moan")
			message = "<B>[src]</B> moans!"
			m_type = 2
		if ("johnny")
			var/M
			if (param) M = param
			if (!M) param = null
			else
				message = "<B>[src]</B> says, \"[M], please. He had a family.\" [name] takes a drag from a cigarette and blows his name out in smoke."
				m_type = 2
		if ("point")
			if (!restrained())
				var/mob/M = null
				if (param)
					for (var/mob/A in view(null, null))
						if (findtext(A.name,param,1,0))
							M = A
							break
				if (!M) message = "<B>[src]</B> points."
				else M.point()
				if (M) message = "<B>[src]</B> points to [M]."
			m_type = 1
		if ("raise")
			if (!restrained())
				message = "<B>[src]</B> raises a hand."
			m_type = 1
		if("shake")
			message = "<B>[src]</B> shakes \his head."
			m_type = 1
		if ("shrug")
			message = "<B>[src]</B> shrugs."
			m_type = 1
		if ("signal")
			if (!restrained())
				var/t1 = round(text2num(param))
				if (isnum(t1))
					if (t1 <= 5 && (!r_hand || !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
					else if (t1 <= 10 && (!r_hand && !l_hand))
						message = "<B>[src]</B> raises [t1] finger\s."
			m_type = 1
		if ("smile")
			message = "<B>[src]</B> smiles."
			m_type = 1
		if ("shiver")
			message = "<B>[src]</B> shivers."
			m_type = 2
		if ("pale")
			message = "<B>[src]</B> goes pale for a second."
			m_type = 1
		if ("tremble")
			message = "<B>[src]</B> trembles in fear!"
			m_type = 1
		if ("sneeze")
			if (!muzzled)
				message = "<B>[src]</B> sneezes."
				m_type = 2
			else
				message = "<B>[src]</B> makes a strange noise."
				m_type = 2
		if ("sniff")
			message = "<B>[src]</B> sniffs."
			m_type = 2
		if ("snore")
			if (!muzzled)
				message = "<B>[src]</B> snores."
				m_type = 2
			else
				message = "<B>[src]</B> makes a noise."
				m_type = 2
		if ("whimper")
			if (!muzzled)
				message = "<B>[src]</B> whimpers."
				m_type = 2
			else
				message = "<B>[src]</B> makes a weak noise."
				m_type = 2
		if ("wink")
			message = "<B>[src]</B> winks."
			m_type = 1
		if ("yawn")
			if (!muzzled)
				message = "<B>[src]</B> yawns."
				m_type = 2

		// ===== SCREAM — ОБЫЧНЫЙ КРИК =====
		if ("scream")
			if (!muzzled)
				message = "<B>[src]</B> кричит!"
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/fear_woman1.ogg','sound/voice/fear_woman2.ogg'), 70, 1)
				else
					playsound(loc, pick('sound/voice/nfear_a1.ogg','sound/voice/nfear_a2.ogg','sound/voice/nfear_a3.ogg'), 70, 1)
			else
				message = "<B>[src]</B> издаёт очень громкий звук."
				m_type = 2

		// ===== AGONY — КРИК АГОНИИ =====
		if ("agony")
			if (!muzzled)
				message = "<B>[src]</B> кричит от боли!"
				m_type = 2
				if(gender == FEMALE)
					playsound(loc, pick('sound/voice/fem_scream_pain1.ogg','sound/voice/fem_scream_pain2.ogg','sound/voice/fem_scream_pain3.ogg','sound/voice/fem_scream_pain4.ogg','sound/voice/fem_scream_pain5.ogg','sound/voice/fem_scream_pain6.ogg','sound/voice/fem_scream_pain7.ogg','sound/voice/fem_scream_pain8.ogg'), 80, 1)
				else
					playsound(loc, pick('sound/voice/agony_male1.ogg','sound/voice/agony_male2.ogg','sound/voice/agony_male3.ogg','sound/voice/agony_male4.ogg','sound/voice/agony_male5.ogg','sound/voice/agony_male6.ogg','sound/voice/agony_male7.ogg','sound/voice/agony_male8.ogg','sound/voice/agony_male9.ogg','sound/voice/agony_male10.ogg','sound/voice/agony_male11.ogg','sound/voice/agony_male12.ogg','sound/voice/agony_male13.ogg'), 80, 1)
			else
				message = "<B>[src]</B> издаёт приглушённый крик боли."
				m_type = 2

		if ("hungry")
			if(prob(1)) message = "<B>Blue Elf</B> needs food Badly"
			else message = "<B>[src]'s</B> stomach growls"
		if ("thirsty")
			if(prob(1)) message = "<B>[src]</B> cancels destory station: Drinking"
			else message = "<B>[src]</B> thirsty"
		if ("vomit")
			message = vomit(1)
			m_type = 1
		if ("help")
			src << "blink, blink_r, blush, bow, choke, chuckle, clap, collapse, cough, cry, custom, drool, eyebrow, faint, frown, gasp, giggle, glare, groan, grumble, grin, handshake, howl, hug, laugh, look, moan, mumble, nod, pale, point, raise, salute, scream, shake, shiver, shrug, sigh, signal, smile, sneeze, sniff, snore, stare, tremble, twitch, twitch_s, whimper, wink, yawn"
		else
			src << "\blue Unusable emote '[act]'. Say *help for a list."

	if (isobj(src.loc))
		message = src.loc:alterMobEmote(message, act, m_type, src)
		if (message != "")
			if (m_type & 1)
				for (var/mob/O in viewers(src.loc, null))
					O.show_message(message, m_type)
			else if (m_type & 2)
				for (var/mob/O in hearers(src.loc, null))
					O.show_message(message, m_type)
	else if (message != "")
		if (m_type & 1)
			for (var/mob/O in viewers(src, null))
				O.show_message(message, m_type)
		else if (m_type & 2)
			for (var/mob/O in hearers(src, null))
				O.show_message(message, m_type)
// ============================
// neworgans.dm — ПОЛНАЯ СИСТЕМА ОРГАНОВ + ПЕРЕЛОМЫ + ОТРУБАНИЕ + РАЗРЫВ
// ============================

/datum/organ
	var/name = "organ"
	var/mob/living/owner = null

/datum/organ/proc/process()
	return

/datum/organ/proc/receive_chem(chemical as obj)
	return

// ---------- ВНЕШНИЕ ОРГАНЫ ----------
/datum/organ/external
	name = "external"
	var/icon_name = null
	var/list/wounds = list()
	var/damage_state = "00"
	var/brute_dam = 0
	var/burn_dam = 0
	var/slash_dam = 0
	var/bandaged = 0
	var/max_damage = 0
	var/wound_size = 0
	var/max_size = 0
	var/critical = 0
	var/perma_dmg = 0
	var/bleeding = 0
	var/perma_injury = 0
	var/broken = 0
	var/destroyed = 0
	var/destspawn
	var/obj/item/weapon/implant/implant = null
	var/min_broken_damage = 30
	var/datum/organ/external/parent
	var/damage_msg = "\red You feel a intense pain"
	var/open = 0
	var/display_name
	var/clean = 1
	var/stage = 0
	var/wound = 0
	var/split = 0

	var/artery_cut = 0
	var/tendon_damaged = 0

/datum/organ/external/process()
	if(destroyed && destspawn)
		droplimb()
	if(broken == 0)
		perma_dmg = 0
	if(parent && parent.destroyed)
		destroyed = 1
		if(owner) owner:update_body()
		return
	if(brute_dam > min_broken_damage && broken == 0)
		if(owner) owner << "[damage_msg] in your [display_name]"
		broken = 1
		wound = "broken"
		perma_injury = brute_dam
	if(istype(src, /datum/organ/external/chest))
		process_chest_organs(src)
	if(istype(src, /datum/organ/external/head))
		process_head_organs(src)
	if(istype(src, /datum/organ/external/neck))
		process_neck_organs(src)
	if(istype(src, /datum/organ/external/vitals))
		process_vitals_organs(src)

/datum/organ/external/proc/createwound(var/size = 1)
	if(ishuman(src.owner))
		var/datum/organ/external/wound/W = new(src)
		W.bleeding = 1
		if(src.owner) src.owner:bloodloss += 10 * size
		W.wound_size = size
		W.owner = src.owner
		src.wounds += W

/datum/organ/external/wound
	name = "wound"
	wound_size = 1
	icon_name = "wound"
	display_name = "wound"
	parent = null

/datum/organ/external/wound/proc/stopbleeding()
	if(!src.bleeding)
		return
	if(src.owner) src.owner:bloodloss -= 10 * src.wound_size
	src.bleeding = 0
	del(src)

// ---------- ВНУТРЕННИЕ ОРГАНЫ ----------
/datum/organ/internal
	var/health = 100
	var/max_health = 100
	var/status = "healthy"

/datum/organ/internal/heart
	name = "heart"

/datum/organ/internal/lungs
	name = "lungs"

/datum/organ/internal/liver
	name = "liver"

/datum/organ/internal/kidney
	name = "kidney"
	var/side = ""

/datum/organ/internal/stomach
	name = "stomach"

/datum/organ/internal/intestines
	name = "intestines"

/datum/organ/internal/brain
	name = "brain"

/datum/organ/internal/eyes
	name = "eyes"
	var/side = ""

/datum/organ/internal/ears
	name = "ears"

/datum/organ/internal/eyes/left
	name = "left eye"
	side = "left"

/datum/organ/internal/eyes/right
	name = "right eye"
	side = "right"

// ---------- ВНЕШНИЕ ОРГАНЫ ----------
/datum/organ/external/chest
	name = "chest"
	icon_name = "chest"
	max_damage = 150
	min_broken_damage = 75
	display_name = "chest"
	var/datum/organ/internal/heart
	var/datum/organ/internal/lungs
	var/datum/organ/internal/liver
/datum/organ/external/vitals
	name = "vitals"
	icon_name = "vitals"
	max_damage = 100
	min_broken_damage = 50
	display_name = "живот"
	var/datum/organ/internal/kidney_left
	var/datum/organ/internal/kidney_right
	var/datum/organ/internal/stomach
	var/datum/organ/internal/intestines

/datum/organ/external/groin
	name = "groin"
	icon_name = "groin"
	max_damage = 115
	min_broken_damage = 70
	display_name = "groin"

/datum/organ/external/head
	name = "head"
	icon_name = "head"
	max_damage = 125
	min_broken_damage = 70
	display_name = "head"
	var/datum/organ/internal/brain
	var/datum/organ/internal/eyes
	var/datum/organ/internal/eyes/left_eye
	var/datum/organ/internal/eyes/right_eye
	var/datum/organ/internal/ears

/datum/organ/external/neck
	name = "neck"
	icon_name = "neck"
	max_damage = 60
	min_broken_damage = 30
	display_name = "шея"

/datum/organ/external/l_arm
	name = "l_arm"
	icon_name = "l_arm"
	max_damage = 75
	min_broken_damage = 30
	display_name = "left arm"

/datum/organ/external/l_foot
	name = "l_foot"
	icon_name = "l_foot"
	max_damage = 40
	min_broken_damage = 15
	display_name = "left foot"

/datum/organ/external/l_hand
	name = "l_hand"
	icon_name = "l_hand"
	max_damage = 40
	min_broken_damage = 15
	display_name = "left hand"

/datum/organ/external/l_leg
	name = "l_leg"
	icon_name = "l_leg"
	max_damage = 75
	min_broken_damage = 30
	display_name = "left leg"

/datum/organ/external/r_arm
	name = "r_arm"
	icon_name = "r_arm"
	max_damage = 75
	min_broken_damage = 30
	display_name = "right arm"

/datum/organ/external/r_foot
	name = "r_foot"
	icon_name = "r_foot"
	max_damage = 40
	min_broken_damage = 15
	display_name = "right foot"

/datum/organ/external/r_hand
	name = "r_hand"
	icon_name = "r_hand"
	max_damage = 40
	min_broken_damage = 15
	display_name = "right hand"

/datum/organ/external/r_leg
	name = "r_leg"
	icon_name = "r_leg"
	max_damage = 75
	min_broken_damage = 30
	display_name = "right leg"

// ---------- ОБРАБОТКА ШЕИ ----------
/proc/process_neck_organs(datum/organ/external/neck/N)
	if(!N || !N.owner || !ishuman(N.owner)) return
	var/mob/living/carbon/human/H = N.owner
	if(N.artery_cut)
		H.bloodloss = min(100, H.bloodloss + 5)
		if(prob(5) && H.bloodloss > 50)
			H.paralysis = max(H.paralysis, 15)

// ---------- ОБРАБОТКА ВНУТРЕННИХ ОРГАНОВ ----------
/proc/process_chest_organs(datum/organ/external/chest/C)
	if(!C || !C.owner || !ishuman(C.owner)) return
	var/mob/living/carbon/human/H = C.owner
	if(istype(C.heart)) process_heart(C.heart, H)
	if(istype(C.lungs)) process_lungs(C.lungs, H)
	if(istype(C.liver)) process_liver(C.liver, H)

/proc/process_vitals_organs(datum/organ/external/vitals/V)
	if(!V || !V.owner || !ishuman(V.owner)) return
	var/mob/living/carbon/human/H = V.owner
	if(istype(V.kidney_left) && istype(V.kidney_right)) process_kidneys(V.kidney_left, V.kidney_right, H)
	if(istype(V.stomach)) process_stomach(V.stomach, H)
	if(istype(V.intestines)) process_intestines(V.intestines, H)

/proc/process_head_organs(datum/organ/external/head/HD)
	if(!HD || !HD.owner || !ishuman(HD.owner)) return
	var/mob/living/carbon/human/H = HD.owner
	if(istype(HD.brain)) process_brain(HD.brain, H)
	if(istype(HD.left_eye)) process_single_eye(HD.left_eye, H, "left")
	if(istype(HD.right_eye)) process_single_eye(HD.right_eye, H, "right")
	if(!HD.left_eye && !HD.right_eye && istype(HD.eyes)) process_eyes(HD.eyes, H)
	if(istype(HD.ears)) process_ears(HD.ears, H)

/proc/process_single_eye(datum/organ/internal/eyes/E, mob/living/carbon/human/H, side)
	switch(E.status)
		if("damaged")
			if(prob(20)) H << "\red Your [side] eye hurts and blurs your vision!"
			H.eye_blurry = max(H.eye_blurry, 3)
		if("ruptured")
			H << "\red <B>Your [side] eye is destroyed!"
			H.eye_blurry = max(H.eye_blurry, 10)
		if("destroyed")
			H << "\red <B>Your [side] eye socket is empty!</B>"
			H.eye_blind = max(H.eye_blind, 5)

/proc/process_heart(datum/organ/internal/heart/HT, mob/living/carbon/human/H)
	switch(HT.status)
		if("bruised")  if(prob(5)) H.oxyloss += 1
		if("damaged")  {H.oxyloss += 2; if(prob(10)) H.emote("gasp")}
		if("ruptured") {H.oxyloss += 5; if(prob(5)) H.death()}
		if("destroyed") H.death()

/proc/process_lungs(datum/organ/internal/lungs/L, mob/living/carbon/human/H)
	switch(L.status)
		if("bruised")  if(prob(10)) H.losebreath += 1
		if("damaged")  {H.losebreath += 3; if(prob(5)) H.cough_blood()}
		if("ruptured") {H.losebreath += 8; H.oxyloss += 3}
		if("destroyed") {H.oxyloss += 10; if(prob(15)) H.death()}

/proc/process_brain(datum/organ/internal/brain/B, mob/living/carbon/human/H)
	switch(B.status)
		if("bruised")  if(prob(10)) {H.eye_blurry=max(H.eye_blurry,3); H.confused=max(H.confused,5)}
		if("damaged")  {H.eye_blurry=max(H.eye_blurry,5); if(prob(5)) H.emote("twitch")}
		if("ruptured") {H.paralysis=max(H.paralysis,5); if(prob(10)) H.death()}
		if("destroyed") H.death()

/proc/process_liver(datum/organ/internal/liver/L, mob/living/carbon/human/H)
	switch(L.status)
		if("bruised")  if(prob(5)) H.toxloss += 1
		if("damaged")  H.toxloss += 3
		if("ruptured") {H.toxloss += 6; H.bloodloss += 2}
		if("destroyed") {H.toxloss += 10; if(prob(5)) H.death()}

/proc/process_kidneys(datum/organ/internal/kidney/KL, datum/organ/internal/kidney/KR, mob/living/carbon/human/H)
	var/total = ((KL.status=="destroyed"||KL.status=="ruptured")?1:0) + ((KR.status=="destroyed"||KR.status=="ruptured")?1:0)
	if(total==2) {H.toxloss+=8; if(prob(10)) H.death()}
	else if(total==1) H.toxloss+=3

/proc/process_stomach(datum/organ/internal/stomach/S, mob/living/carbon/human/H)
	switch(S.status)
		if("damaged")  if(prob(10)) H.nutrition = max(0, H.nutrition-10)
		if("ruptured") {H.bloodloss+=5; if(prob(10)) H.cough_blood()}
		if("destroyed") {H.bloodloss+=8; if(prob(5)) H.death()}

/proc/process_intestines(datum/organ/internal/intestines/I, mob/living/carbon/human/H)
	switch(I.status)
		if("damaged")  if(prob(10)) H.bloodloss+=1
		if("ruptured") {H.bloodloss+=5; if(prob(15)) H.cough_blood()}
		if("destroyed") {H.bloodloss+=10; if(prob(10)) H.death()}

/proc/process_eyes(datum/organ/internal/eyes/E, mob/living/carbon/human/H)
	switch(E.status)
		if("damaged")  H.eye_blurry = max(H.eye_blurry, 5)
		if("ruptured") H.blinded = 1
		if("destroyed") {H.blinded = 1; H.eye_blind = 100}

/proc/process_ears(datum/organ/internal/ears/E, mob/living/carbon/human/H)
	switch(E.status)
		if("damaged")  H.ear_damage += 10
		if("ruptured") H.ear_deaf = 1
		if("destroyed") {H.ear_deaf = 1; H.ear_damage = 100}

/mob/living/carbon/human/proc/cough_blood()
	if(stat == 2) return
	visible_message("<span class='danger'><B>[src] харкает кровью!</B></span>")
	var/obj/decal/cleanable/blood/drip/D = new(loc)
	if(dna) D.blood_DNA = dna.unique_enzymes
	D.blood_type = b_type
	if(microorganism) D.microorganism = microorganism.getcopy()
	spawn(5)
		var/obj/decal/cleanable/blood/drip/L = new(loc)
		L.icon_state = pick("6", "l1", "l2", "l3")
		if(dna) L.blood_DNA = dna.unique_enzymes
		L.blood_type = b_type
	bloodloss += 2

// ============================
// GURPS take_damage
// ============================
/datum/organ/external/proc/take_damage(brute, burn, slash = 0, dmg_type = DAMAGE_CRUSH, supbrute = 0)
	if ((brute <= 0 && burn <= 0))
		return 0
	if(destroyed)
		return 0

	if(owner && ishuman(owner))
		var/mob/living/carbon/human/H = owner
		H.pain(display_name, (brute+burn)*3, 1)

	// === ОТРУБАНИЕ КОНЕЧНОСТЕЙ (режущее) ===
	if(dmg_type == DAMAGE_CUT && brute >= 15 && !destroyed)
		var/sever_chance = brute * 0.3
		if(brute_dam > max_damage * 0.5)
			sever_chance *= 1.5
		if(brute_dam > max_damage * 0.75)
			sever_chance *= 2.0
		if(name in list("head", "neck"))
			sever_chance *= 1.5
		if(name in list("l_hand", "r_hand", "l_foot", "r_foot"))
			sever_chance *= 1.3

		if(prob(sever_chance))
			if(owner)
				for(var/mob/M in viewers(owner))
					M.show_message("\red <B>[owner.name]'s [display_name] is severed!</B>")
			destroyed = 1
			droplimb()
			return

	// === ДРОБЯЩИЙ РАЗРЫВ КОНЕЧНОСТЕЙ ===
	if(dmg_type == DAMAGE_CRUSH && brute >= 18 && !destroyed)
		var/explode_chance = (brute - 10) * 1.0
		if(brute_dam > max_damage * 0.4)
			explode_chance *= 1.5
		if(brute_dam > max_damage * 0.6)
			explode_chance *= 2.0
		if(brute_dam > max_damage * 0.8)
			explode_chance *= 2.5
		if(name in list("head"))
			explode_chance *= 3
		if(name in list("l_hand", "r_hand", "l_foot", "r_foot"))
			explode_chance *= 2.0
		if(supbrute)
			explode_chance *= 1.5

		if(prob(explode_chance))
			if(owner)
				for(var/mob/M in viewers(owner))
					M.show_message("\red <B>[owner.name]'s [display_name] explodes in a shower of gore!</B>")
			destroyed = 1
			droplimb_gib()
			return

	// ПРИМЕНЕНИЕ УРОНА
	if ((brute_dam + burn_dam + brute + burn) < max_damage)
		brute_dam += brute
		burn_dam += burn
	else
		var/can_inflict = max_damage - (brute_dam + burn_dam)
		if (can_inflict)
			if (brute > 0 && burn > 0)
				brute = can_inflict/2
				burn = can_inflict/2
				var/ratio = brute / (brute + burn)
				brute_dam += ratio * can_inflict
				burn_dam += (1 - ratio) * can_inflict
			else
				if (brute > 0)
					brute = can_inflict
					brute_dam += brute
				else
					burn = can_inflict
					burn_dam += burn
		else
			return 0

	// ===== АРТЕРИИ (режущее и колющее) =====
	if((dmg_type == DAMAGE_CUT || dmg_type == DAMAGE_PIERCE) && brute >= 8 && !artery_cut && !destroyed)
		var/artery_chance = brute * 1.5
		if(brute_dam > max_damage * 0.3)
			artery_chance *= 1.5
		if(name == "neck")
			artery_chance *= 2.0

		if(prob(artery_chance) && name in list("neck", "l_arm", "r_arm", "l_leg", "r_leg"))
			artery_cut = 1
			if(owner && ishuman(owner))
				var/mob/living/carbon/human/H = owner
				H.visible_message(
					"<span class='danger'><B>Артерия в [display_name] [H] разорвана! Кровь фонтанирует!</B></span>",
					"<span class='danger'><B>Артерия в вашей [display_name] разорвана!</B></span>"
				)
				H.bloodloss = max(H.bloodloss, 25)
				playsound(H.loc, pick('sound/trauma/blood/blood_splat.ogg'), 70, 1)
				if(name == "neck")
					playsound(H.loc, pick('sound/voice/throat.ogg', 'sound/voice/throat2.ogg', 'sound/voice/throat3.ogg'), 70, 1)
					playsound(H.loc, pick('sound/trauma/blood/blood_splat.ogg'), 70, 1)
					H.oxyloss += 5
					if(prob(30))
						H.paralysis = max(H.paralysis, 10)

	// ===== СУХОЖИЛИЯ (режущее) =====
	if(dmg_type == DAMAGE_CUT && brute >= 5 && !tendon_damaged && !destroyed)
		var/tendon_chance = brute * 2.0
		if(brute_dam > max_damage * 0.3)
			tendon_chance *= 1.5

		if(prob(tendon_chance) && name in list("l_arm", "r_arm", "l_hand", "r_hand", "l_leg", "r_leg"))
			tendon_damaged = 1
			if(owner && ishuman(owner))
				var/mob/living/carbon/human/H = owner
				H.visible_message(
					"<span class='danger'><B>Сухожилия в [display_name] [H] повреждены!</B></span>",
					"<span class='danger'><B>Сухожилия в вашей [display_name] повреждены!</B></span>"
				)
				H.pain(display_name, 45, 1)
				if(name in list("l_arm", "r_arm", "l_hand", "r_hand"))
					H.drop_item()
				if(name in list("l_leg", "r_leg"))
					H.weakened = max(H.weakened, 5)

	// ===== ПЕРЕЛОМЫ (ТОЛЬКО ДРОБЯЩЕЕ) =====
	if(owner && ishuman(owner) && !broken && !destroyed && dmg_type == DAMAGE_CRUSH && brute >= 10)
		var/mob/living/carbon/human/H = owner
		var/fracture_chance = (brute - 8) * 1.2

		if(supbrute)
			fracture_chance *= 1.3
		if(brute_dam > max_damage * 0.5)
			fracture_chance *= 1.5
		if(brute_dam > max_damage * 0.75)
			fracture_chance *= 2.0

		var/ht_bonus = (H.gurps_health - 10) * (-0.1)
		fracture_chance += fracture_chance * ht_bonus
		fracture_chance = max(1.0, fracture_chance)

		if(prob(fracture_chance))
			broken = 1
			min_broken_damage = brute_dam

			if(name == "head")
				playsound(H.loc, pick('sound/trauma/head_explodie_01.ogg', 'sound/trauma/head_explodie_02.ogg', 'sound/trauma/head_explodie_03.ogg'), 80, 1)
				H.visible_message("<span class='danger'><B>Череп [H] проломлен!</B></span>")
			else
				playsound(H.loc, pick('sound/effects/trauma1.ogg', 'sound/effects/trauma2.ogg', 'sound/effects/trauma3.ogg'), 70, 1)
				H.visible_message("<span class='danger'><B>Кость сладко хрустит!</B></span>")
			H.pain(display_name, 60, 1)

			if(name == "head")
				H.confused = max(H.confused, 20)
				H.eye_blurry = max(H.eye_blurry, 15)
				if(brute >= 25)
					H.paralysis = max(H.paralysis, 10)
					if(istype(src, /datum/organ/external/head))
						var/datum/organ/external/head/HD = src
						if(HD.brain)
							HD.brain.health = max(0, HD.brain.health - 30)
							if(HD.brain.health <= 50 && HD.brain.status == "healthy")
								HD.brain.status = "bruised"
			else if(name == "chest")
				H.weakened = max(H.weakened, 5)
				H.losebreath += 5
				if(brute >= 25 && prob(40))
					H.cough_blood()
			else if(name == "groin")
				H.weakened = max(H.weakened, 8)
				H.stunned = max(H.stunned, 5)
			else if(name in list("l_arm","r_arm"))
				H.drop_item()
				H.weakened = max(H.weakened, 3)
			else if(name in list("l_hand","r_hand"))
				H.drop_item()
			else if(name in list("l_leg","r_leg"))
				H.weakened = max(H.weakened, 8)
			else if(name in list("l_foot","r_foot"))
				H.weakened = max(H.weakened, 5)

	// ===== УДАР В ПАХ =====
	if(name == "groin" && brute >= 5 && owner && ishuman(owner) && !destroyed)
		var/mob/living/carbon/human/H = owner
		if(H.stat != 2)  // Живой
			if(H.gender == MALE)
				H.stunned = max(H.stunned, 8)
				H.weakened = max(H.weakened, 5)
				H.losebreath += 2
				H.confused = max(H.confused, 5)
				H.visible_message(
					"<span class='danger'><B>[H] сгибается от боли в паху!</B></span>",
					"<span class='danger'><B>Острая боль в паху! Вы не можете двигаться!</B></span>"
				)
				playsound(H.loc, pick('sound/voice/balls1.ogg','sound/voice/balls2.ogg'), 50, 0)
				H.pain("пах", 70, 1)

	// ===== УДАР В ЖИВОТ =====
	if(istype(src, /datum/organ/external/vitals) && brute >= 5 && owner && ishuman(owner) && !destroyed)
		var/mob/living/carbon/human/H = owner
		if(H.stat != 2)
			var/datum/organ/external/vitals/V = src
			if(V.stomach && (V.stomach.status == "healthy" || V.stomach.status == "bruised"))
				var/vomit_chance = 0
				if(dmg_type == DAMAGE_PIERCE)
					vomit_chance = brute * 8
				else if(dmg_type == DAMAGE_CUT)
					vomit_chance = brute * 3
				else if(dmg_type == DAMAGE_CRUSH)
					vomit_chance = brute * 2

				if(prob(vomit_chance))
					H.visible_message(
						"<span class='danger'><B>Удар в живот [H] вызывает рвоту!</B></span>",
						"<span class='danger'><B>Удар в живот! Вас сейчас вырвет!</B></span>"
					)
					H.losebreath += 3
					H.weakened = max(H.weakened, 3)
					spawn(5)
					if(H.stat != 2)
						H.vomit(0)
					if(prob(20) && V.stomach.status == "healthy")
						V.stomach.status = "bruised"
						V.stomach.health = max(0, V.stomach.health - 20)

	// ===== ВНУТРЕННИЕ ОРГАНЫ =====
	if(owner && ishuman(owner) && istype(src,/datum/organ/external/chest) && brute >= 10 && !destroyed)
		var/mob/living/carbon/human/H = owner
		var/datum/organ/external/chest/C = src
		if(dmg_type == DAMAGE_CUT || dmg_type == DAMAGE_PIERCE)
			var/organ_chance = brute * (dmg_type == DAMAGE_PIERCE ? 1.5 : 0.8)
			if(prob(organ_chance))
				var/list/orgs = list()
				// Органы груди
				if(istype(C.heart)) orgs += C.heart
				if(istype(C.lungs)) orgs += C.lungs
				// Органы живота из vitals
				var/datum/organ/external/vitals/V = H.organs["vitals"]
				if(V)
					if(istype(V.kidney_left)) orgs += V.kidney_left
					if(istype(V.kidney_right)) orgs += V.kidney_right
					if(istype(V.stomach)) orgs += V.stomach
					if(istype(V.intestines)) orgs += V.intestines
				if(orgs.len)
					var/datum/organ/internal/O = pick(orgs)
					O.health = max(0, O.health - brute * (dmg_type == DAMAGE_PIERCE ? 2 : 1))
					if(O.health <= 0) O.status = "destroyed"
					else if(O.health < 25) O.status = "ruptured"
					else if(O.health < 50) O.status = "damaged"
					else if(O.health < 75) O.status = "bruised"
					H.visible_message("<span class='danger'><B>Повреждён внутренний орган [H]! ([O.name])</B></span>")
					H.pain(O.name, 50, 1)

	// ===== МОЗГ =====
	if(owner && ishuman(owner) && istype(src,/datum/organ/external/head) && brute >= 10 && !destroyed)
		var/mob/living/carbon/human/H = owner
		var/datum/organ/external/head/HD = src
		var/brain_chance = 0
		if(dmg_type == DAMAGE_PIERCE) brain_chance = brute * 2.0
		else if(dmg_type == DAMAGE_CRUSH) brain_chance = brute * 1.0
		else if(dmg_type == DAMAGE_CUT) brain_chance = brute * 0.5

		if(brain_chance > 0 && prob(brain_chance) && istype(HD.brain))
			HD.brain.health = max(0, HD.brain.health - brute * 2)
			if(HD.brain.health <= 0)
				HD.brain.status = "destroyed"
				H.visible_message("<span class='danger'><B>Мозг [H] разрушен! Мгновенная смерть!</B></span>")
				H.death()
				return
			else if(HD.brain.health < 25)
				HD.brain.status = "ruptured"
				H.visible_message("<span class='danger'><B>Мозг [H] сильно повреждён! ([HD.brain.status])</B></span>")
			else if(HD.brain.health < 50)
				HD.brain.status = "damaged"
				H.visible_message("<span class='danger'><B>Мозг [H] повреждён! ([HD.brain.status])</B></span>")
			else if(HD.brain.health < 75)
				HD.brain.status = "bruised"
				H.visible_message("<span class='danger'><B>Мозг [H] ушиблен! ([HD.brain.status])</B></span>")
			H.pain("голова", 70, 1)

	// ===== КРОВОТЕЧЕНИЕ =====
	if(slash && brute >= 6 && owner && ishuman(owner) && !destroyed)
		var/mob/living/carbon/human/H = owner
		if(prob(brute * 2))
			createwound(rand(1, max(1, round(brute/5))))
		H.bloodloss = max(H.bloodloss, round(brute/4))

	if(broken && owner && !destroyed)
		owner.emote("scream")

	return update_icon()

// ---------- HEAL_DAMAGE ----------
/datum/organ/external/proc/heal_damage(brute, burn, var/internal = 0)
	brute_dam = max(0, brute_dam - brute)
	burn_dam = max(0, burn_dam - burn)
	if(internal)
		broken = 0
		perma_injury = 0
		artery_cut = 0
		tendon_damaged = 0
		for(var/datum/organ/external/wound/W in wounds)
			W.stopbleeding()
		wounds = list()
	return update_icon()

/datum/organ/external/proc/get_damage()
	return max(brute_dam + burn_dam - perma_injury, perma_injury)

/datum/organ/external/proc/get_damage_brute()
	return max(brute_dam + perma_injury, perma_injury)

/datum/organ/external/proc/get_damage_fire()
	return burn_dam

/datum/organ/external/proc/damage_state_text()
	if(open)
		return "33"
	var/tburn = 0
	var/tbrute = 0
	if(burn_dam == 0)
		tburn = 0
	else if (burn_dam < (max_damage * 0.25 / 2))
		tburn = 1
	else if (burn_dam < (max_damage * 0.75 / 2))
		tburn = 2
	else
		tburn = 3
	if (brute_dam == 0)
		tbrute = 0
	else if (brute_dam < (max_damage * 0.25 / 2))
		tbrute = 1
	else if (brute_dam < (max_damage * 0.75 / 2))
		tbrute = 2
	else
		tbrute = 3
	return "[tbrute][tburn]"

/datum/organ/external/proc/update_icon()
	var/n_is = damage_state_text()
	if (n_is != damage_state)
		damage_state = n_is
		return 1
	return 0

// ============================
// droplimb()
// ============================
/datum/organ/external/proc/droplimb()
	if(!destroyed) return
	if(!owner || !ishuman(owner)) return

	var/mob/living/carbon/human/H = owner
	playsound(H.loc, pick('sound/trauma/chop.ogg','sound/trauma/chop2.ogg','sound/trauma/chop3.ogg','sound/trauma/chop4.ogg','sound/trauma/chop5.ogg','sound/trauma/chop6.ogg'), 70, 1)

	var/obj/decal/cleanable/blood/splatter/B = new(H.loc)
	if(H.dna)
		B.blood_DNA = H.dna.unique_enzymes
	B.blood_type = H.b_type
	if(H.microorganism)
		B.microorganism = H.microorganism.getcopy()

	spawn(0)
		var/d = pick(cardinal)
		for(var/i = 1 to rand(2,4))
			sleep(1)
			var/obj/decal/cleanable/blood/splatter/S = new(get_step(H, d))
			if(H.dna)
				S.blood_DNA = H.dna.unique_enzymes
			S.blood_type = H.b_type
			d = turn(d, pick(-90, 90))

	H.bloodloss += 10

	if(name == "head")
		var/g = (H.gender == MALE) ? "m" : "f"
		var/icon/head_icon = new /icon('icons/mob/human.dmi', "head_[g]_l")

		if(H.hair_icon_state && H.hair_icon_state != "bald")
			var/icon/hair_icon = new /icon('icons/mob/human_face.dmi', "[H.hair_icon_state]_l")
			hair_icon.Blend(rgb(H.r_hair, H.g_hair, H.b_hair), ICON_ADD)
			head_icon.Blend(hair_icon, ICON_OVERLAY)

		if(H.face_icon_state && H.face_icon_state != "bald")
			var/icon/facial_icon = new /icon('icons/mob/human_face.dmi', "[H.face_icon_state]_l")
			facial_icon.Blend(rgb(H.r_facial, H.g_facial, H.b_facial), ICON_ADD)
			head_icon.Blend(facial_icon, ICON_OVERLAY)

		var/icon/eyes_icon = new /icon('icons/mob/human_face.dmi', "eyes_l")
		eyes_icon.Blend(rgb(H.r_eyes, H.g_eyes, H.b_eyes), ICON_ADD)
		head_icon.Blend(eyes_icon, ICON_OVERLAY)

		var/icon/mouth_icon = new /icon('icons/mob/human_face.dmi', "mouth_[g]_l")
		head_icon.Blend(mouth_icon, ICON_OVERLAY)

		H.h_style = "Bald"
		H.f_style = "Shaved"
		H.update_hair()
		H.update_face()
		H.update_body()
		H.update_clothing()

		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc

		var/obj/item/weapon/organ/head/H_head = new(H.loc)
		H_head.icon = head_icon
		H_head.name = "голова [H.real_name]"
		H_head.add_blood(H)
		H_head.throw_at(target_turf, 3, 2)
		H.visible_message("<span class='danger'><B>Голова [H] отрублена!</B></span>")
		spawn(5)
			H.death()
		return

	if(name == "neck")
		H.visible_message("<span class='danger'><B>Шея [H] перерезана! Кровь хлещет фонтаном!</B></span>")
		H.bloodloss = min(100, H.bloodloss + 40)
		H.losebreath += 15
		var/datum/organ/external/head = H.organs["head"]
		if(head && !head.destroyed)
			head.destroyed = 1
			head.droplimb()
		H.death()
		return

	if(name == "chest")
		H.gib()
		return

	if(name == "l_arm")
		var/has_hand = FALSE
		var/datum/organ/external/l_hand = H.organs["l_hand"]
		if(l_hand && !l_hand.destroyed)
			has_hand = TRUE
			l_hand.destroyed = 1

		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc

		var/obj/item/weapon/organ/l_arm/A = new(H.loc)
		A.icon = 'icons/mob/flesh/gore.dmi'
		A.icon_state = has_hand ? "left_arm" : "left_arm_nohand"
		A.name = has_hand ? "левая рука [H.real_name]" : "левая рука без кисти [H.real_name]"
		A.add_blood(H)
		A.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Левая рука [H] отрублена!</B></span>")
		H.drop_item()

	if(name == "r_arm")
		var/has_hand = FALSE
		var/datum/organ/external/r_hand = H.organs["r_hand"]
		if(r_hand && !r_hand.destroyed)
			has_hand = TRUE
			r_hand.destroyed = 1

		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc

		var/obj/item/weapon/organ/r_arm/A = new(H.loc)
		A.icon = 'icons/mob/flesh/gore.dmi'
		A.icon_state = has_hand ? "right_arm" : "right_arm_nohand"
		A.name = has_hand ? "правая рука [H.real_name]" : "правая рука без кисти [H.real_name]"
		A.add_blood(H)
		A.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Правая рука [H] отрублена!</B></span>")
		H.drop_item()

	if(name == "l_leg")
		var/has_foot = FALSE
		var/datum/organ/external/l_foot = H.organs["l_foot"]
		if(l_foot && !l_foot.destroyed)
			has_foot = TRUE
			l_foot.destroyed = 1

		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc

		var/obj/item/weapon/organ/l_leg/L = new(H.loc)
		L.icon = 'icons/mob/flesh/gore.dmi'
		L.icon_state = has_foot ? "left_leg" : "left_leg_nofoot"
		L.name = has_foot ? "левая нога [H.real_name]" : "левая нога без ступни [H.real_name]"
		L.add_blood(H)
		L.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Левая нога [H] отрублена!</B></span>")
		H.weakened = max(H.weakened, 10)

	if(name == "r_leg")
		var/has_foot = FALSE
		var/datum/organ/external/r_foot = H.organs["r_foot"]
		if(r_foot && !r_foot.destroyed)
			has_foot = TRUE
			r_foot.destroyed = 1

		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc

		var/obj/item/weapon/organ/r_leg/L = new(H.loc)
		L.icon = 'icons/mob/flesh/gore.dmi'
		L.icon_state = has_foot ? "right_leg" : "right_leg_nofoot"
		L.name = has_foot ? "правая нога [H.real_name]" : "правая нога без ступни [H.real_name]"
		L.add_blood(H)
		L.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Правая нога [H] отрублена!</B></span>")
		H.weakened = max(H.weakened, 10)

	if(name == "l_hand")
		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc
		var/obj/item/weapon/organ/l_hand/HD = new(H.loc)
		HD.icon = 'icons/mob/flesh/gore.dmi'
		HD.icon_state = "left_hand"
		HD.name = "левая кисть [H.real_name]"
		HD.add_blood(H)
		HD.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Левая кисть [H] отрублена!</B></span>")
		H.drop_item()

	if(name == "r_hand")
		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc
		var/obj/item/weapon/organ/r_hand/HD = new(H.loc)
		HD.icon = 'icons/mob/flesh/gore.dmi'
		HD.icon_state = "right_hand"
		HD.name = "правая кисть [H.real_name]"
		HD.add_blood(H)
		HD.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Правая кисть [H] отрублена!</B></span>")
		H.drop_item()

	if(name == "l_foot")
		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc
		var/obj/item/weapon/organ/l_foot/FT = new(H.loc)
		FT.icon = 'icons/mob/flesh/gore.dmi'
		FT.icon_state = "left_foot"
		FT.name = "левая ступня [H.real_name]"
		FT.add_blood(H)
		FT.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Левая стопа [H] отрублена!</B></span>")
		H.weakened = max(H.weakened, 5)

	if(name == "r_foot")
		var/list/free_turfs = list()
		for(var/d in cardinal)
			var/turf/T = get_step(H, d)
			if(T && !T.density)
				free_turfs += T
		var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc
		var/obj/item/weapon/organ/r_foot/FT = new(H.loc)
		FT.icon = 'icons/mob/flesh/gore.dmi'
		FT.icon_state = "right_foot"
		FT.name = "правая ступня [H.real_name]"
		FT.add_blood(H)
		FT.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Правая стопа [H] отрублена!</B></span>")
		H.weakened = max(H.weakened, 5)

	if(name == "groin")
		if(H.gender == MALE && !H.gurps_organ_status.Find("penis_removed"))
			H.gurps_organ_status["penis_removed"] = 1
			var/list/free_turfs = list()
			for(var/d in cardinal)
				var/turf/T = get_step(H, d)
				if(T && !T.density)
					free_turfs += T
			var/turf/target_turf = free_turfs.len > 0 ? pick(free_turfs) : H.loc
			var/obj/item/weapon/organ/penis/P = new(H.loc)
			P.name = "отрезанный пенис [H.real_name]"
			P.add_blood(H)
			P.throw_at(target_turf, 2, 1)
		H.visible_message("<span class='danger'><B>Пах [H] разрублен!</B></span>")
		H.bloodloss = min(100, H.bloodloss + 20)
		H.stunned = max(H.stunned, 10)
		H.weakened = max(H.weakened, 8)

	H.update_body()
	H.update_face()
	H.update_clothing()
	H.UpdateDamageIcon()
	H.updatehealth()

// ============================
// droplimb_gib()
// ============================
/datum/organ/external/proc/droplimb_gib()
	if(!destroyed) return
	if(!owner || !ishuman(owner)) return

	var/mob/living/carbon/human/H = owner
	playsound(H.loc, 'sound/effects/gore.ogg', 80, 1)

	var/obj/decal/cleanable/blood/gibs/G = new(H.loc)
	G.icon_state = pick("gib1","gib2","gib3","gib4","gib5","gib6")
	if(H.dna)
		G.blood_DNA = H.dna.unique_enzymes
	G.blood_type = H.b_type
	if(H.microorganism)
		G.microorganism = H.microorganism.getcopy()

	spawn(0)
		var/d = pick(cardinal)
		for(var/i = 1 to rand(3,5))
			sleep(1)
			var/obj/decal/cleanable/blood/splatter/S = new(get_step(H, d))
			if(H.dna)
				S.blood_DNA = H.dna.unique_enzymes
			S.blood_type = H.b_type
			d = turn(d, pick(-90, 90))

	H.bloodloss += 15

	if(name == "chest")
		H.gib()
		return

	if(name == "head")
		H.h_style = "Bald"
		H.f_style = "Shaved"
		H.update_hair()
		H.update_face()
		H.update_body()
		H.update_clothing()
		H.visible_message("<span class='danger'><B>Голова [H] разлетается на куски!</B></span>")
		spawn(5)
			H.death()
		return

	if(name == "neck")
		H.visible_message("<span class='danger'><B>Шея [H] разорвана в клочья! Обезглавливание!</B></span>")
		H.death()
		return

	if(name == "l_arm")
		if(H.organs["l_hand"] && !H.organs["l_hand"]:destroyed)
			H.organs["l_hand"].destroyed = 1
		H.visible_message("<span class='danger'><B>Левая рука [H] разлетается в клочья!</B></span>")
		H.drop_item()

	if(name == "r_arm")
		if(H.organs["r_hand"] && !H.organs["r_hand"]:destroyed)
			H.organs["r_hand"].destroyed = 1
		H.visible_message("<span class='danger'><B>Правая рука [H] разлетается в клочья!</B></span>")
		H.drop_item()

	if(name == "l_leg")
		if(H.organs["l_foot"] && !H.organs["l_foot"]:destroyed)
			H.organs["l_foot"].destroyed = 1
		H.visible_message("<span class='danger'><B>Левая нога [H] разлетается в клочья!</B></span>")
		H.weakened = max(H.weakened, 10)

	if(name == "r_leg")
		if(H.organs["r_foot"] && !H.organs["r_foot"]:destroyed)
			H.organs["r_foot"].destroyed = 1
		H.visible_message("<span class='danger'><B>Правая нога [H] разлетается в клочья!</B></span>")
		H.weakened = max(H.weakened, 10)

	if(name == "l_hand")
		H.visible_message("<span class='danger'><B>Левая кисть [H] разлетается!</B></span>")
		H.drop_item()

	if(name == "r_hand")
		H.visible_message("<span class='danger'><B>Правая кисть [H] разлетается!</B></span>")
		H.drop_item()

	if(name == "l_foot")
		H.visible_message("<span class='danger'><B>Левая ступня [H] разлетается!</B></span>")
		H.weakened = max(H.weakened, 5)

	if(name == "r_foot")
		H.visible_message("<span class='danger'><B>Правая ступня [H] разлетается!</B></span>")
		H.weakened = max(H.weakened, 5)

	if(name == "groin")
		H.visible_message("<span class='danger'><B>Пах [H] разлетается в клочья!</B></span>")
		H.bloodloss = max(H.bloodloss, 25)
		H.stunned = max(H.stunned, 10)
		H.weakened = max(H.weakened, 8)

	H.update_body()
	H.update_face()
	H.update_clothing()
	H.UpdateDamageIcon()
	H.updatehealth()

// ---------- ПРЕДМЕТЫ ОРГАНОВ ----------
obj/item/weapon/organ/
	icon = 'icons/mob/human.dmi'

obj/item/weapon/organ/head
	name = "head"
	icon_state = "head_l"

obj/item/weapon/organ/l_arm
	name = "left arm"
	icon_state = "arm_left_l"

obj/item/weapon/organ/l_foot
	name = "left foot"
	icon_state = "foot_left_l"

obj/item/weapon/organ/l_hand
	name = "left hand"
	icon_state = "hand_left_l"

obj/item/weapon/organ/l_leg
	name = "left leg"
	icon_state = "leg_left_l"

obj/item/weapon/organ/r_arm
	name = "right arm"
	icon_state = "arm_right_l"

obj/item/weapon/organ/r_foot
	name = "right foot"
	icon_state = "foot_right_l"

obj/item/weapon/organ/r_hand
	name = "right hand"
	icon_state = "hand_right_l"

obj/item/weapon/organ/r_leg
	name = "right leg"
	icon_state = "leg_right_l"

obj/item/weapon/organ/penis
	name = "пенис"
	icon = 'icons/mob/flesh/gore.dmi'
	icon_state = "penis"

obj/item/weapon/organ/balls
	name = "яйца"
	icon = 'icons/mob/flesh/gore.dmi'
	icon_state = "balls"
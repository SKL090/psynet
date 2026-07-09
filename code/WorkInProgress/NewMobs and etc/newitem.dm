/obj/item/proc/process()
	processing_items.Remove(src)
	return null

/obj/item/proc/attack_self()
	return

/obj/item/proc/talk_into(mob/M as mob, text)
	return

/obj/item/proc/security_talk_into(mob/M as mob, text)

/obj/item/proc/moved(mob/user as mob, old_loc as turf)
	return

/obj/item/proc/dropped(mob/user as mob)
	return

/obj/item/proc/pickup(mob/user)
	return

/obj/item/proc/equipped(var/mob/user, var/slot)
	return

/obj/item/proc/afterattack()
	return

/obj/item/weapon/dummy/ex_act()
	return

/obj/item/weapon/dummy/blob_act()
	return

/obj/item/ex_act(severity)
	switch(severity)
		if(1.0)
			del(src)
			return
		if(2.0)
			if (prob(50))
				del(src)
				return
		if(3.0)
			if (prob(5))
				del(src)
				return
		else
	return

/obj/item/blob_act()
	return

/obj/item/verb/move_to_top()
	set src in oview(1)
	if(!istype(src.loc, /turf) || usr.stat || usr.restrained() )
		return
	var/turf/T = src.loc
	src.loc = null
	src.loc = T

/obj/item/examine()
	set src in view()
	var/t
	switch(src.w_class)
		if(1.0) t = "tiny"
		if(2.0) t = "small"
		if(3.0) t = "normal-sized"
		if(4.0) t = "bulky"
		if(5.0) t = "huge"
		else
	if ((usr.mutations & 16) && prob(50)) t = "funny-looking"
	usr << text("This is a []\icon[][]. It is a [] item.", !src.blood_DNA ? "" : "bloody ",src, src.name, t)
	usr << src.desc
	return

/obj/item/attack_hand(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		user.u_equip(src)
	else
		if(ishuman(user) && !user:zombie)
			src.pickup(user)
	if (user.hand)
		if(ishuman(user))
			var/datum/organ/external/temp = user:organs["l_hand"]
			if(!temp.destroyed)
				user.l_hand = src
			else
				user << "\blue You pick \the [src] up with your ha- wait a minute."
				return
		else
			user.l_hand = src
	else
		if(ishuman(user))
			var/datum/organ/external/temp = user:organs["r_hand"]
			if(!temp.destroyed)
				user.r_hand = src
			else
				user << "\blue You pick \the [src] up with your ha- wait a minute."
				return
		else
			user.r_hand = src
	src.loc = user
	src.layer = 20
	add_fingerprint(user)
	user.update_clothing()
	return

/obj/item/attack_paw(mob/user as mob)
	if (istype(src.loc, /obj/item/weapon/storage))
		for(var/mob/M in range(1, src.loc))
			if (M.s_active == src.loc)
				if (M.client)
					M.client.screen -= src
	src.throwing = 0
	if (src.loc == user)
		user.u_equip(src)
	if (user.hand)
		user.l_hand = src
	else
		user.r_hand = src
	src.loc = user
	src.layer = 20
	user.update_clothing()
	return

/obj/item/var/superblunt = 0
/obj/item/var/slash = 0

/obj/item/proc/attack(mob/M as mob, mob/user as mob, def_zone)
	if (!M) return
	if (src.hitsound) playsound(src.loc, hitsound, 50, 1, -1)

	user.lastattacked = M
	M.lastattacker = user

	var/power = src.force
	if (istype(M, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = M
		if(H.zombie) power = 0

	if (!def_zone)
		var/t = user:zone_sel?.selecting
		if(t in list("eyes","mouth")) t = "head"
		def_zone = ran_zone(t ? t : "chest")

	if (istype(M, /mob/living/carbon/human) && istype(user, /mob/living/carbon/human))
		gurps_weapon_attack(user, M, src, def_zone)
		return

	// Не человек — обычный урон
	M.bruteloss += power
	M.updatehealth()
	return
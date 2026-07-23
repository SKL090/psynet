// ============================
// gurps_guns.dm — GURPS ДАЛЬНИЙ БОЙ (РЕВОЛЬВЕР С ГИЛЬЗАМИ И ПУЛЯМИ)
// ============================

// ============================================
// БАЗОВЫЙ КЛАСС GURPS-ОРУЖИЯ ДАЛЬНЕГО БОЯ
// ============================================
/obj/item/weapon/gun/gurps
	name = "gurps firearm"
	desc = "Огнестрельное оружие для GURPS-боёвки."
	icon = 'icons/obj/weapons/gun.dmi'
	icon_state = "revolver2"
	force = 5
	var/gurps_skill = "ranged"
	var/gurps_accuracy = 0
	var/gurps_min_strength = 6
	var/gurps_damage = 15
	var/gurps_damage_type = DAMAGE_PIERCE
	var/max_ammo = 6
	var/current_ammo = 0
	var/fired_ammo = 0
	var/obj/item/weapon/ammo/gurps/ammo_type = /obj/item/weapon/ammo/gurps/revolver
	var/cylinder_open = FALSE
	var/icon_state_closed = "revolver2"
	var/icon_state_open_empty = "revolver2_open0"
	var/icon_state_open_partial = "revolver2_open1"
	var/icon_state_open_full = "revolver2_open2"

/obj/item/weapon/gun/gurps/New()
	..()
	current_ammo = max_ammo
	gurps_update_icon()

/obj/item/weapon/gun/gurps/proc/gurps_update_icon()
	var/total = current_ammo + fired_ammo
	if(cylinder_open)
		if(total <= 0)
			icon_state = icon_state_open_empty
		else if(total <= 2)
			icon_state = icon_state_open_partial
		else
			icon_state = icon_state_open_full
	else
		icon_state = icon_state_closed

/obj/item/weapon/gun/gurps/attack_self(mob/user)
	cylinder_open = !cylinder_open
	if(cylinder_open)
		playsound(user, 'sound/weapons2/revolver_open.ogg', 50, 1)
		user << "\blue Вы открываете барабан [src]."
	else
		playsound(user, 'sound/weapons2/revolver_close.ogg', 50, 1)
		user << "\blue Вы закрываете барабан [src]."
	gurps_update_icon()

/obj/item/weapon/gun/gurps/proc/eject_all(mob/user)
	var/total = current_ammo + fired_ammo
	if(total <= 0) return

	var/turf/T = get_turf(user)

	for(var/i = 1 to current_ammo)
		var/obj/item/weapon/ammo/gurps/revolver/P = new /obj/item/weapon/ammo/gurps/revolver(T)
		P.amount = 1
		P.ammo_update_icon()

	for(var/i = 1 to fired_ammo)
		var/obj/item/weapon/ammo/gurps/brass/B = new /obj/item/weapon/ammo/gurps/brass(T)
		B.dir = pick(NORTH, SOUTH, EAST, WEST)
		B.amount = 1
		B.ammo_update_icon()

	user.visible_message(
		"<span class='warning'>[user] вытряхивает содержимое барабана [src]!</span>",
		"<span class='notice'>Вы вытряхиваете [current_ammo] патронов и [fired_ammo] гильз из барабана.</span>"
	)
	current_ammo = 0
	fired_ammo = 0
	gurps_update_icon()

// ============================================
// ПАТРОНЫ
// ============================================
/obj/item/weapon/ammo/gurps
	name = "gurps ammo"
	desc = "Патрон для GURPS-оружия."
	icon = 'icons/obj/weapons/newammo.dmi'
	icon_state = "n1"
	w_class = 1.0
	var/amount = 1

/obj/item/weapon/ammo/gurps/proc/ammo_update_icon()
	icon_state = "n[amount]"

/obj/item/weapon/ammo/gurps/attackby(obj/item/weapon/ammo/gurps/A, mob/user)
	if(istype(A, /obj/item/weapon/ammo/gurps))
		if(A.type == src.type && src != A)
			// Определяем какой в руке
			var/obj/item/weapon/ammo/gurps/in_hand = null
			var/obj/item/weapon/ammo/gurps/other = null

			if(src.loc == user)
				in_hand = src
				other = A
			else if(A.loc == user)
				in_hand = A
				other = src

			if(in_hand && other)
				if(in_hand.amount + other.amount <= 15)
					in_hand.amount += other.amount
					user << "\blue Вы объединили патроны. Теперь у вас [in_hand.amount] шт."
					del(other)
					in_hand.ammo_update_icon()
				else
					var/overflow = (in_hand.amount + other.amount) - 15
					in_hand.amount = 15
					other.amount = overflow
					user << "\blue Вы объединили патроны. [overflow] шт не поместилось."
					in_hand.ammo_update_icon()
					other.ammo_update_icon()
				return

/obj/item/weapon/ammo/gurps/attack_hand(mob/user)
	if(amount > 1 && src.loc == user)
		var/obj/item/weapon/ammo/gurps/single = new src.type(user)
		single.amount = 1
		single.ammo_update_icon()
		src.amount--
		ammo_update_icon()
		if(user.hand)
			user.l_hand = single
		else
			user.r_hand = single
	else
		..()

/obj/item/weapon/ammo/gurps/dropped(mob/user)
	if(amount > 1)
		var/turf/T = get_turf(src)
		var/total = amount
		for(var/i = 2 to total)
			var/obj/item/weapon/ammo/gurps/single = new src.type(T)
			single.amount = 1
			single.ammo_update_icon()
		amount = 1
		ammo_update_icon()
	..()

/obj/item/weapon/ammo/gurps/revolver
	name = "патрон .357"
	desc = "Патрон для револьвера .357 калибра."
	icon_state = "n1"

// ============================================
// ГИЛЬЗА (ОБЩАЯ ДЛЯ ВСЕХ ПУШЕК)
// ============================================
/obj/item/weapon/ammo/gurps/brass
	name = "гильза"
	desc = "Пустая стреляная гильза."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "b-casing"
	w_class = 1.0

/obj/item/weapon/ammo/gurps/brass/ammo_update_icon()
	icon_state = "b-casing"

/obj/item/weapon/ammo/gurps/brass/New()
	..()
	dir = pick(NORTH, SOUTH, EAST, WEST)

// ============================================
// ПУЛЯ GURPS
// ============================================
/obj/projectile/bullet/gurps
	name = "пуля"
	icon = 'icons/effects/projectiles.dmi'
	icon_state = "bullet"
	var/mob/living/carbon/human/shooter = null
	var/original_zone = "chest"
	var/gurps_damage = 0
	var/gurps_damage_type = DAMAGE_PIERCE
	var/is_crit = FALSE

/obj/projectile/bullet/gurps/process()
	if(!shooter)
		del(src)
		return

	var/turf/step = get_step(src, dir)
	if(step)
		loc = step
	else
		del(src)
		return

	for(var/mob/living/carbon/human/target in loc)
		if(target == shooter) continue
		hit_target(target)
		del(src)
		return

	if(loc == current)
		shooter.visible_message("<span class='warning'>Пуля пролетает мимо цели!</span>")
		del(src)
		return

/obj/projectile/bullet/gurps/proc/hit_target(mob/living/carbon/human/target)
	if(!target || !shooter) return

	var/zone = gurps_normalize_zone(original_zone)
	var/zone_name = gurps_zone_name_combat(original_zone)

	var/datum/organ/external/E = target.organs[zone]
	if(!E) E = target.organs["chest"]

	if(E && !E.destroyed)
		var/was_broken = E.broken
		var/was_artery = E.artery_cut
		var/was_tendon = E.tendon_damaged

		E.take_damage(gurps_damage, 0, 0, gurps_damage_type, is_crit)
		target.UpdateDamageIcon()
		target.updatehealth()
		target.lastattacker = shooter

		var/effect_msg = gurps_determine_effect(E, was_broken, was_artery, was_tendon, is_crit)

		var/msg_others = "<span class='danger'>В [zone_name] [target] попадает пуля!</span>"
		var/msg_self = "<span class='danger'>В вашу [zone_name] попадает пуля!</span>"

		if(effect_msg)
			msg_others += " <span class='danger'>[effect_msg]</span>"
			msg_self += " <span class='danger'>[effect_msg]</span>"
		else
			msg_others += " <span class='notice'>Заурядное попадание.</span>"
			msg_self += " <span class='notice'>Заурядное попадание.</span>"

		target.visible_message(msg_others, msg_self)
	else
		shooter.visible_message("<span class='warning'>Пуля попадает в [target], но конечность уничтожена!</span>")

// ============================================
// РЕВОЛЬВЕР
// ============================================
/obj/item/weapon/gun/gurps/revolver
	name = "Harat - 86"
	desc = "Шестизарядный револьвер .357 калибра. Надёжное оружие."
	icon_state = "revolver2"
	icon_state_closed = "revolver2"
	gurps_skill = "ranged"
	gurps_accuracy = 1
	gurps_min_strength = 8
	gurps_damage = 40
	gurps_damage_type = DAMAGE_PIERCE
	max_ammo = 6
	current_ammo = 6
	fired_ammo = 0
	ammo_type = /obj/item/weapon/ammo/gurps/revolver
	force = 8

/obj/item/weapon/gun/gurps/revolver/attackby(obj/item/weapon/ammo/gurps/A, mob/user)
	if(istype(A, /obj/item/weapon/ammo/gurps/revolver))
		if(!cylinder_open)
			user << "\red Барабан закрыт! Откройте его сначала."
			return

		if(current_ammo >= max_ammo)
			user << "\blue Револьвер уже полностью заряжен!"
			return

		current_ammo++
		user << "\blue Вы заряжаете один патрон в барабан. ([current_ammo]/[max_ammo])"
		playsound(user, pick('sound/weapons2/revolver_load1.ogg','sound/weapons2/revolver_load2.ogg'), 40, 1)

		if(A.amount > 1)
			A.amount--
			A.ammo_update_icon()
		else
			del(A)

		gurps_update_icon()
	else
		..()

/obj/item/weapon/gun/gurps/revolver/attack_self(mob/user)
	cylinder_open = !cylinder_open
	if(cylinder_open)
		playsound(user, 'sound/weapons2/revolver_open.ogg', 50, 1)
		user << "\blue Вы открываете барабан [src]."
	else
		playsound(user, 'sound/weapons2/revolver_close.ogg', 50, 1)
		user << "\blue Вы закрываете барабан [src]."
	gurps_update_icon()

/obj/item/weapon/gun/gurps/revolver/MouseDrop(atom/over_object)
	if(usr && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.l_hand == src || H.r_hand == src)
			if(current_ammo > 0 || fired_ammo > 0)
				cylinder_open = TRUE
				eject_all(H)
				cylinder_open = FALSE
				gurps_update_icon()
	..()

/obj/item/weapon/gun/gurps/revolver/afterattack(atom/target, mob/user, flag)
	if(flag) return

	if(cylinder_open)
		user << "\red Барабан открыт! Закройте его перед выстрелом."
		return

	if(current_ammo <= 0)
		user << "\red *click* *click*"
		playsound(user, 'sound/weapons2/dryfire.ogg', 50, 1)
		return

	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = user

	if(H.gurps_strength < gurps_min_strength)
		user << "\red Вам не хватает силы чтобы точно стрелять из [src]!"

	var/skill = H.gurps_get_skill(gurps_skill)
	skill += gurps_accuracy

	var/list/attack = gurps_skill_check(skill)

	current_ammo--
	fired_ammo++
	gurps_update_icon()

	playsound(user, 'sound/weapons/Gunshot.ogg', 100, 1)

	user.visible_message(
		"<span class='danger'>[user] стреляет в [target] из [src]!</span>",
		"<span class='danger'>Вы стреляете в [target] из [src]!</span>"
	)

	if(!attack["success"])
		spawn(3)
			user.visible_message("<span class='warning'>Пуля пролетает мимо [target]!</span>")
		return

	var/obj/projectile/bullet/gurps/bullet = new /obj/projectile/bullet/gurps(user.loc)
	bullet.shooter = H
	bullet.gurps_damage = gurps_damage + (H.gurps_strength - 10) / 2
	bullet.gurps_damage_type = gurps_damage_type
	bullet.is_crit = attack["crit"]

	if(H.zone_sel && istype(H.zone_sel, /obj/screen/zone_sel))
		bullet.original_zone = H.zone_sel.selecting
	else
		bullet.original_zone = "chest"

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
	if(U && T)
		bullet.current = U
		bullet.yo = U.y - T.y
		bullet.xo = U.x - T.x
		bullet.process()
	else
		del(bullet)

/obj/item/weapon/gun/gurps/revolver/attack(mob/M, mob/user)
	if(current_ammo > 0 && !cylinder_open)
		afterattack(M, user, 0)
	else
		..()

/obj/item/weapon/gun/gurps/revolver/examine()
	set src in usr
	usr << "Револьвер .357 калибра. Патронов: [current_ammo]/[max_ammo]. Гильз в барабане: [fired_ammo]. Барабан [cylinder_open ? "открыт" : "закрыт"]."
	..()


// ============================================
// ПИСТОЛЕТ С МАГАЗИНОМ (РОДИТЕЛЬСКИЙ КЛАСС)
// ============================================

// ============================================
// МАГАЗИН
// ============================================
/obj/item/weapon/ammo/gurps/magazine
	name = "магазин"
	desc = "Магазин для пистолета."
	icon = 'icons/obj/weapons/ammo.dmi'
	icon_state = "mother0"
	w_class = 2.0
	var/max_rounds = 12
	var/current_rounds = 12
	var/caliber = ".45 ACP"
	var/icon_state_loaded = "mother1"
	var/icon_state_empty = "mother0"

/obj/item/weapon/ammo/gurps/magazine/New()
	..()
	current_rounds = max_rounds
	update_magazine_icon()

/obj/item/weapon/ammo/gurps/magazine/proc/update_magazine_icon()
	if(current_rounds > 0)
		icon_state = icon_state_loaded
	else
		icon_state = icon_state_empty

/obj/item/weapon/ammo/gurps/magazine/proc/unload_round(mob/user)
	if(current_rounds <= 0)
		return FALSE

	current_rounds--
	update_magazine_icon()
	return TRUE

/obj/item/weapon/ammo/gurps/magazine/examine()
	set src in usr
	usr << "Магазин [caliber]. Патронов: [current_rounds]/[max_rounds]."
	..()

// ============================================
// МАГАЗИН ПИСТОЛЕТА .45
// ============================================
/obj/item/weapon/ammo/gurps/magazine/pistol
	name = "магазин пистолета"
	desc = "Магазин для пистолета .45 калибра."
	caliber = ".45 ACP"
	max_rounds = 12
	current_rounds = 12
	icon_state = "mother1"
	icon_state_loaded = "mother1"
	icon_state_empty = "mother0"

// ============================================
// ПАТРОНЫ .45 ACP
// ============================================
/obj/item/weapon/ammo/gurps/pistol
	name = "патрон .45 ACP"
	desc = "Пистолетный патрон .45 калибра."
	icon = 'icons/obj/weapons/newammo.dmi'
	icon_state = "th1"
	w_class = 1.0

/obj/item/weapon/ammo/gurps/pistol/ammo_update_icon()
	icon_state = "th[amount]"

/obj/item/weapon/ammo/gurps/pistol/attackby(obj/item/weapon/ammo/gurps/pistol/A, mob/user)
	if(istype(A, /obj/item/weapon/ammo/gurps/pistol))
		if(A.type == src.type && src != A)
			var/obj/item/weapon/ammo/gurps/pistol/in_hand = null
			var/obj/item/weapon/ammo/gurps/pistol/other = null

			if(src.loc == user)
				in_hand = src
				other = A
			else if(A.loc == user)
				in_hand = A
				other = src

			if(in_hand && other)
				if(in_hand.amount + other.amount <= 15)
					in_hand.amount += other.amount
					user << "\blue Вы объединили патроны. Теперь у вас [in_hand.amount] шт."
					del(other)
					in_hand.ammo_update_icon()
				else
					var/overflow = (in_hand.amount + other.amount) - 15
					in_hand.amount = 15
					other.amount = overflow
					user << "\blue Вы объединили патроны. [overflow] шт не поместилось."
					in_hand.ammo_update_icon()
					other.ammo_update_icon()
				return

/obj/item/weapon/ammo/gurps/pistol/attack_hand(mob/user)
	if(amount > 1 && src.loc == user)
		var/obj/item/weapon/ammo/gurps/pistol/single = new src.type(user)
		single.amount = 1
		single.ammo_update_icon()
		src.amount--
		ammo_update_icon()
		if(user.hand)
			user.l_hand = single
		else
			user.r_hand = single
	else
		..()

/obj/item/weapon/ammo/gurps/pistol/dropped(mob/user)
	if(amount > 1)
		var/turf/T = get_turf(src)
		var/total = amount
		for(var/i = 2 to total)
			var/obj/item/weapon/ammo/gurps/pistol/single = new src.type(T)
			single.amount = 1
			single.ammo_update_icon()
		amount = 1
		ammo_update_icon()
	..()
// ============================================
// ПИСТОЛЕТ С МАГАЗИНОМ (С ЗАТВОРОМ)
// ============================================
/obj/item/weapon/gun/gurps/pistol
	name = "Пистолет"
	desc = "Самозарядный пистолет .45 калибра с магазинным питанием."
	icon = 'icons/obj/weapons/gun.dmi'
	icon_state = "mother1"
	var/icon_state_safety_on = "mother0"
	var/icon_state_safety_off = "mother1"
	var/icon_state_no_magazine = "mother_empty"
	var/safety_on = FALSE
	var/obj/item/weapon/ammo/gurps/magazine/magazine = null
	var/magazine_type = /obj/item/weapon/ammo/gurps/magazine/pistol
	var/caliber = ".45 ACP"
	var/chambered = FALSE  // Есть ли патрон в патроннике
	var/slide_locked = FALSE  // Затвор заблокирован (пустой магазин)

/obj/item/weapon/gun/gurps/pistol/New()
	..()
	magazine = new magazine_type(src)
	// При первой зарядке — передёргиваем затвор
	if(magazine && magazine.current_rounds > 0)
		magazine.unload_round()
		chambered = TRUE
	update_pistol_icon()

/obj/item/weapon/gun/gurps/pistol/proc/update_pistol_icon()
	if(!magazine)
		icon_state = icon_state_no_magazine
	else if(safety_on)
		icon_state = icon_state_safety_on
	else
		icon_state = icon_state_safety_off

// Передёрнуть затвор (ЛКМ когда в руке)
/obj/item/weapon/gun/gurps/pistol/attack_self(mob/user)
	if(src.loc == user)
		if(slide_locked)
			user << "\red Затвор заблокирован. Вставьте новый магазин."
			return

		if(chambered)
			// Извлекаем патрон из патронника
			var/obj/item/weapon/ammo/gurps/pistol/ejected = new /obj/item/weapon/ammo/gurps/pistol(get_turf(user))
			ejected.amount = 1
			ejected.ammo_update_icon()
			chambered = FALSE
			user.visible_message(
				"<span class='warning'>[user] передёргивает затвор [src], извлекая патрон из патронника!</span>",
				"<span class='notice'>Вы передёргиваете затвор. Патрон извлечён из патронника.</span>"
			)
			playsound(user, 'sound/weapons2/rifle_cock.ogg', 50, 1)

		// Если патронник пуст — досылаем новый патрон из магазина
		if(!chambered && magazine && magazine.current_rounds > 0)
			magazine.unload_round()
			magazine.update_magazine_icon()
			chambered = TRUE
			user.visible_message(
				"<span class='warning'>[user] досылает патрон в патронник [src]!</span>",
				"<span class='notice'>Вы досылаете патрон в патронник.</span>"
			)
			playsound(user, 'sound/weapons2/rifle_cock.ogg', 50, 1)

		// Если магазин пуст — блокируем затвор
		if(!chambered && (!magazine || magazine.current_rounds <= 0))
			slide_locked = TRUE
			user << "\red Затвор заблокирован. Магазин пуст."

		update_pistol_icon()
	else
		..()

// Предохранитель (клавиша E)
/obj/item/weapon/gun/gurps/pistol/attack_hand(mob/user)
	if(src.loc == user)
		safety_on = !safety_on
		if(safety_on)
			playsound(user, 'sound/weapons2/safety.ogg', 30, 1)
			user << "\blue Вы включаете предохранитель [src]."
		else
			playsound(user, 'sound/weapons2/safety.ogg', 30, 1)
			user << "\blue Вы выключаете предохранитель [src]."
		update_pistol_icon()
	else
		..()

// Вставить магазин
/obj/item/weapon/gun/gurps/pistol/attackby(obj/item/weapon/ammo/gurps/magazine/M, mob/user)
	if(istype(M, /obj/item/weapon/ammo/gurps/magazine/pistol))
		if(magazine)
			user << "\red Магазин уже вставлен! Сначала извлеките его."
			return

		user << "\blue Вы вставляете магазин в [src]."
		playsound(user, 'sound/weapons2/bigpistol_reload.ogg', 50, 1)
		user.u_equip(M)
		M.loc = src
		magazine = M
		slide_locked = FALSE  // Разблокируем затвор при вставке нового магазина
		update_pistol_icon()
	else
		..()

// Извлечение магазина (перетягивание вниз)
/obj/item/weapon/gun/gurps/pistol/MouseDrop(atom/over_object)
	if(usr && ishuman(usr))
		var/mob/living/carbon/human/H = usr
		if(H.l_hand == src || H.r_hand == src)
			if(magazine)
				var/obj/item/weapon/ammo/gurps/magazine/M = magazine
				magazine = null
				M.loc = get_turf(H)
				H.visible_message(
					"<span class='warning'>[H] извлекает магазин из [src]!</span>",
					"<span class='notice'>Вы извлекаете магазин из [src]. ([M.current_rounds]/[M.max_rounds])</span>"
				)
				playsound(H, 'sound/weapons2/bigpistol_unload.ogg', 50, 1)
				update_pistol_icon()
	..()

// Выстрел
/obj/item/weapon/gun/gurps/pistol/afterattack(atom/target, mob/user, flag)
	if(flag) return

	if(safety_on)
		user << "\red Предохранитель включён! Выключите его перед выстрелом."
		return

	if(!chambered)
		user << "\red Патронник пуст! Передёрните затвор."
		playsound(user, 'sound/weapons2/dryfire.ogg', 50, 1)
		return

	if(!istype(user, /mob/living/carbon/human))
		return

	var/mob/living/carbon/human/H = user

	if(H.gurps_strength < gurps_min_strength)
		user << "\red Вам не хватает силы чтобы точно стрелять из [src]!"

	var/skill = H.gurps_get_skill(gurps_skill)
	skill += gurps_accuracy

	var/list/attack = gurps_skill_check(skill)

	// Выстрел — тратим патрон из патронника
	chambered = FALSE

	// Автоматически досылаем новый патрон из магазина
	if(magazine && magazine.current_rounds > 0)
		magazine.unload_round()
		magazine.update_magazine_icon()
		chambered = TRUE
	else
		slide_locked = TRUE

	update_pistol_icon()

	playsound(user, 'sound/weapons2/p45.ogg', 100, 1)

	user.visible_message(
		"<span class='danger'>[user] стреляет в [target] из [src]!</span>",
		"<span class='danger'>Вы стреляете в [target] из [src]!</span>"
	)

	if(!attack["success"])
		spawn(3)
			user.visible_message("<span class='warning'>Пуля пролетает мимо [target]!</span>")
		return

	var/obj/projectile/bullet/gurps/bullet = new /obj/projectile/bullet/gurps(user.loc)
	bullet.shooter = H
	bullet.gurps_damage = gurps_damage + (H.gurps_strength - 10) / 2
	bullet.gurps_damage_type = gurps_damage_type
	bullet.is_crit = attack["crit"]

	if(H.zone_sel && istype(H.zone_sel, /obj/screen/zone_sel))
		bullet.original_zone = H.zone_sel.selecting
	else
		bullet.original_zone = "chest"

	var/turf/T = user.loc
	var/turf/U = (istype(target, /atom/movable) ? target.loc : target)
	if(U && T)
		bullet.current = U
		bullet.yo = U.y - T.y
		bullet.xo = U.x - T.x
		bullet.process()
	else
		del(bullet)

// Удар пистолетом
/obj/item/weapon/gun/gurps/pistol/attack(mob/M, mob/user)
	if(chambered && !safety_on)
		afterattack(M, user, 0)
	else
		..()

// Осмотр пистолета
/obj/item/weapon/gun/gurps/pistol/examine()
	set src in usr
	usr << "Пистолет [caliber]."
	if(magazine)
		usr << "Патронов в магазине: [magazine.current_rounds]/[magazine.max_rounds]."
	else
		usr << "Магазин отсутствует."
	usr << "Патрон в патроннике: [chambered ? "есть" : "нет"]."
	usr << "Предохранитель [safety_on ? "включён" : "выключен"]."
	usr << "Затвор [slide_locked ? "заблокирован" : "свободен"]."
	..()
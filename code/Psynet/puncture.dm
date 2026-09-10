// ============================
// puncture.dm - КОЛОТЫЕ РАНЫ (WoundsPlus)
// Трекинг колотых ран с привязкой к зонам bodymask из woundsplus.dmi.
// 1bullet_* - средняя колотая рана, 2bullet_* - глубокая (по урону).
// bullet_* - лёгкая колотая рана.
// obullet_* - рана без кровотечения (кончилась кровь или смерть). НЕ трогать.
// ВНИМАНИЕ: суффикс south/north/east/west — это направление, ОТКУДА
// пришёл удар, а не направление взгляда пострадавшего. Каждая рана хранит
// своё направление; при повороте персонажа оно не должно меняться.
// ============================

#define PUNCTURE_LIGHT 1
#define PUNCTURE_MEDIUM 2
#define PUNCTURE_DEEP 3
#define PUNCTURE_MEDIUM_DAMAGE 5	// brute >= этого = средняя колотая рана
#define PUNCTURE_DEEP_DAMAGE 10	// brute >= этого = глубокая колотая рана

// Уровень раны (puncture_level) -> префикс стейта в woundsplus.dmi.
// bullet - лёгкая, 1bullet - средняя, 2bullet - глубокая.
var/list/puncture_state_prefix = list("bullet", "1bullet", "2bullet")

var/puncture_dmi = 'icons/mob/woundsplus.dmi'

// Зона органа -> цвет зоны в bodymask (HEX без #).
// Шея в маске не закрашена: её раны показываем на груди. Vitals -> пах.
var/list/puncture_zone_colors = list(
	"head" = "FFFFFF",
	"chest" = "000000",
	"groin" = "03BEB5",
	"vitals" = "03BEB5",
	"neck" = "000000",
	"r_arm" = "0000FF",
	"l_arm" = "FFE600",
	"r_hand" = "A0B629",
	"l_hand" = "1187CE",
	"r_leg" = "4D4D4D",
	"l_leg" = "999999",
	"r_foot" = "C758DA",
	"l_foot" = "B6292D")

// "[bodymask_state]/[dir]/[zone]" -> list(ax, ay), координаты иконки BYOND (1..32, y снизу).
var/list/puncture_anchors = null
var/puncture_building = 0
// Пиксель-ранка внутри арта раны (ищем #970004 в 1bullet_south, fallback ниже).
var/puncture_art_ax = 2
var/puncture_art_ay = 7

/datum/organ/external/wound
	var/puncture_level = 0	// 0 - не колотая, 1 - лёгкая, 2 - средняя, 3 - глубокая
	var/puncture_dir = 0	// направление, откуда пришёл именно этот удар
	var/puncture_jx = 0	// разброс оверлея, чтобы раны в одной зоне не слипались
	var/puncture_jy = 0

/mob/living/carbon/human/var/list/puncture_overlay_objects = list()

// Animated DMI states do not play reliably when used as atom overlays.
// A vis_contents object is a real atom, so BYOND can advance its animation
// without update_clothing() restarting it.
/obj/effects/puncture_overlay
	name = "puncture wound"
	icon = 'icons/mob/woundsplus.dmi'
	anchored = 1
	density = 0
	mouse_opacity = 0
	var/datum/organ/external/wound/puncture_wound
	var/puncture_visual_key

// ---------- ПОСТРОЕНИЕ ТАБЛИЦЫ ЯКОРЕЙ ----------
// Один раз сканируем bodymask каждого типа тела и направления,
// якорь зоны = центр пикселей её цвета. Вызывается лениво в spawn,
// чтобы не подвешивать тик (около 17к GetPixel).
/proc/puncture_ensure_anchors()
	if(puncture_anchors || puncture_building)
		return
	puncture_building = 1
	spawn(0)
		puncture_build_anchors_sync()
		puncture_building = 0
		// The first wound can be created while the table is being built.
		// Rebuild those overlays after the asynchronous scan finishes;
		// otherwise the first update leaves the wound invisible until some
		// unrelated clothing change happens.
		for(var/mob/living/carbon/human/H in world)
			if(H)
				H.update_puncture_overlays()

/proc/puncture_find_art_anchor()
	var/icon/art = new /icon(puncture_dmi, "1bullet_south", SOUTH, 1)
	for(var/x = 1 to 32)
		for(var/y = 1 to 32)
			if(uppertext(art.GetPixel(x, y)) == "#970004")
				puncture_art_ax = x
				puncture_art_ay = y
				del(art)
				return
	del(art)

/proc/puncture_build_anchors_sync()
	var/list/acc = list()
	puncture_find_art_anchor()
	for(var/st in list("bodymask", "bodymask_female", "bodymask_fat", "bodymask_child"))
		for(var/d in list(SOUTH, NORTH, EAST, WEST))
			var/icon/m = new /icon(puncture_dmi, st, d)
			var/list/sx = list()
			var/list/sy = list()
			var/list/n = list()
			for(var/x = 1 to 32)
				for(var/y = 1 to 32)
					var/c = uppertext(m.GetPixel(x, y))
					if(c == "#676767")
						continue
					if(isnull(sx[c]))
						sx[c] = 0
						sy[c] = 0
						n[c] = 0
					sx[c] += x
					sy[c] += y
					n[c] += 1
			del(m)
			for(var/zone in puncture_zone_colors)
				var/want = "#" + puncture_zone_colors[zone]
				if(n[want])
					acc["[st]/[d]/[zone]"] = list(round(sx[want] / n[want]), round(sy[want] / n[want]))
	puncture_anchors = acc

// ---------- ХЕЛПЕРЫ ----------
/proc/puncture_cardinal_dir(facing)
	if(facing == NORTH || facing == SOUTH || facing == EAST || facing == WEST)
		return facing
	if(facing == NORTHEAST || facing == NORTHWEST)
		return NORTH
	if(facing == SOUTHEAST || facing == SOUTHWEST)
		return SOUTH
	return SOUTH

/proc/puncture_dir_text(facing)
	switch(puncture_cardinal_dir(facing))
		if(NORTH)
			return "north"
		if(EAST)
			return "east"
		if(WEST)
			return "west"
	return "south"

/mob/living/carbon/human/proc/puncture_bodymask_state()
	if(gender == FEMALE)
		return "bodymask_female"
	return "bodymask"

/mob/living/carbon/human/proc/puncture_no_blood()
	if(stat == 2)
		return 1
	if(!vessel)
		return 1
	return vessel.get_reagent_amount("blood") <= 0

/proc/puncture_anchor(state, facing, zone, is_lying)
	if(!puncture_anchors)
		return null
	if(is_lying)
		// У bodymask нет лежачих кадров. Лежачее тело в human.dmi -
		// это SOUTH, повёрнутое на 90 (голова справа) со сдвигом вниз.
		// Сверено с частями тела: lying_ax = south_ay, lying_ay = 27 - south_ax.
		var/list/s = puncture_anchors["[state]/[SOUTH]/[zone]"]
		if(!s || s.len < 2)
			return null
		return list(s[2], 27 - s[1])
	return puncture_anchors["[state]/[facing]/[zone]"]

// ---------- СОЗДАНИЕ РАНЫ ----------
/datum/organ/external/proc/create_puncture(brute, hit_dir = 0)
	if(!owner || !ishuman(owner))
		return
	if(destroyed)
		return
	var/datum/organ/external/wound/W = new(src)
	W.bleeding = 1
	// hit_dir is the direction from the victim towards the attacker/projectile
	// source. Keep it on the wound: later turns must not rewrite old wounds.
	if(hit_dir)
		W.puncture_dir = puncture_cardinal_dir(hit_dir)
	else
		W.puncture_dir = puncture_cardinal_dir(owner.dir)
	if(brute >= PUNCTURE_DEEP_DAMAGE)
		W.puncture_level = PUNCTURE_DEEP
	else if(brute >= PUNCTURE_MEDIUM_DAMAGE)
		W.puncture_level = PUNCTURE_MEDIUM
	else
		W.puncture_level = PUNCTURE_LIGHT
	W.wound_size = max(1, round(brute / 5))
	W.owner = owner
	W.puncture_jx = rand(-3, 3)
	W.puncture_jy = rand(-3, 3)
	var/mob/living/carbon/human/H = owner
	H.bloodloss += 10 * W.wound_size
	src.wounds += W
	H.update_puncture_overlays()

// ---------- ОТРИСОВКА ----------
// Безопасно вызывать отдельно и в конце update_clothing().
// Визуальные объекты заменяются только при изменении самой раны или её
// DMI-состояния; обычное обновление одежды и поворот лишь меняют положение
// уже существующего объекта, поэтому его native DMI-анимация не сбивается.
/mob/living/carbon/human/proc/remove_puncture_overlay(obj/effects/puncture_overlay/I)
	if(!I)
		return
	vis_contents -= I
	puncture_overlay_objects -= I
	del(I)

/mob/living/carbon/human/proc/update_puncture_overlays()
	puncture_ensure_anchors()
	if(!puncture_anchors)
		return
	var/state = puncture_bodymask_state()
	// The body anchor follows the victim's current pose/facing. The wound
	// sprite direction below is deliberately independent and belongs to W.
	var/body_dir = puncture_cardinal_dir(dir)
	var/no_blood = puncture_no_blood()
	var/is_lying = lying ? 1 : 0
	var/base_layer = is_lying ? (MOB_LAYER - 1) : MOB_LAYER

	// Remove only wounds which no longer exist. Existing wound objects remain
	// in vis_contents, so update_clothing() cannot restart their animation.
	var/list/active_wounds = list()
	for(var/zone in organs)
		var/datum/organ/external/O = organs[zone]
		if(!istype(O) || O.destroyed || !O.wounds || !O.wounds.len)
			continue
		if(!(zone in puncture_zone_colors))
			continue
		for(var/datum/organ/external/wound/W in O.wounds)
			if(W.puncture_level)
				active_wounds += W
	for(var/obj/effects/puncture_overlay/existing in puncture_overlay_objects.Copy())
		if(!(existing.puncture_wound in active_wounds))
			remove_puncture_overlay(existing)

	for(var/zone in organs)
		var/datum/organ/external/O = organs[zone]
		if(!istype(O) || O.destroyed || !O.wounds || !O.wounds.len)
			continue
		if(!(zone in puncture_zone_colors))
			continue
		var/list/a = puncture_anchor(state, body_dir, zone, is_lying)
		for(var/datum/organ/external/wound/W in O.wounds)
			if(!W.puncture_level)
				continue
			var/prefix = puncture_state_prefix[W.puncture_level]
			if(!prefix)
				continue
			var/obj/effects/puncture_overlay/I
			if(!a || a.len < 2)
				// The old object must not remain at the previous body position if
				// this body type has no anchor for the zone.
				for(var/obj/effects/puncture_overlay/candidate in puncture_overlay_objects)
					if(candidate.puncture_wound == W)
						remove_puncture_overlay(candidate)
						break
				continue
			// Do not replace this with body_dir: two wounds on one body part
			// may have arrived from different sides and must keep their own art.
			var/hit_dir = W.puncture_dir ? puncture_cardinal_dir(W.puncture_dir) : body_dir
			var/hit_dtext = puncture_dir_text(hit_dir)
			var/wstate
			if(is_lying)
				// У лежачего тела один общий стейт, направление ему не нужно.
				// Стейта obullet_lying в DMI нет: даже у лежачих без крови
				// показываем обычный lying-стейт, чтобы рана не пропадала.
				wstate = "[prefix]_lying"
			else if(no_blood)
				// Направление obullet также принадлежит этой конкретной ране.
				wstate = "obullet_[hit_dtext]"
			else
				wstate = "[prefix]_[hit_dtext]"
			var/visual_key = "[wstate]/[hit_dir]"
			for(var/obj/effects/puncture_overlay/candidate in puncture_overlay_objects)
				if(candidate.puncture_wound == W)
					I = candidate
					break
			// A state change replaces only this wound's object. That starts the
			// new native animation without resetting unrelated wound animations.
			if(I && I.puncture_visual_key != visual_key)
				remove_puncture_overlay(I)
				I = null
			if(!I)
				I = new /obj/effects/puncture_overlay
				I.icon = puncture_dmi
				I.icon_state = wstate
				I.dir = hit_dir
				I.puncture_wound = W
				I.puncture_visual_key = visual_key
				vis_contents += I
				puncture_overlay_objects += I
			// Changing position/layer on the existing atom does not recreate its
			// appearance, so victim turns and clothing updates leave animation on
			// its current native frame.
			I.layer = base_layer + 0.7
			I.pixel_x = a[1] - puncture_art_ax + W.puncture_jx
			I.pixel_y = a[2] - puncture_art_ay + W.puncture_jy

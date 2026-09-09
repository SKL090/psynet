// ============================
// puncture.dm - КОЛОТЫЕ РАНЫ (WoundsPlus)
// Трекинг колотых ран с привязкой к зонам bodymask из woundsplus.dmi.
// 1bullet_* - лёгкая колотая рана, 2bullet_* - глубокая (по урону).
// obullet_* - рана без кровотечения (кончилась кровь или смерть).
// Стейт bullet_ БЕЗ цифры не используется.
// ============================

#define PUNCTURE_LIGHT 1
#define PUNCTURE_DEEP 2
#define PUNCTURE_DEEP_DAMAGE 10	// brute >= этого = глубокая колотая рана

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
	var/puncture_level = 0	// 0 - не колотая, 1 - лёгкая, 2 - глубокая
	var/puncture_jx = 0	// разброс оверлея, чтобы раны в одной зоне не слипались
	var/puncture_jy = 0

/mob/living/carbon/human/var/list/puncture_images = list()

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
/datum/organ/external/proc/create_puncture(brute)
	if(!owner || !ishuman(owner))
		return
	if(destroyed)
		return
	var/datum/organ/external/wound/W = new(src)
	W.bleeding = 1
	if(brute >= PUNCTURE_DEEP_DAMAGE)
		W.puncture_level = PUNCTURE_DEEP
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
// Старые оверлеи снимаются, новые строятся из предрассчитанных якорей.
/mob/living/carbon/human/proc/update_puncture_overlays()
	if(puncture_images && puncture_images.len)
		overlays -= puncture_images
		puncture_images.Cut()
	puncture_ensure_anchors()
	if(!puncture_anchors)
		return
	var/state = puncture_bodymask_state()
	var/d = puncture_cardinal_dir(dir)
	var/dtext = puncture_dir_text(d)
	var/no_blood = puncture_no_blood()
	var/is_lying = lying ? 1 : 0
	var/base_layer = is_lying ? (MOB_LAYER - 1) : MOB_LAYER
	for(var/zone in organs)
		var/datum/organ/external/O = organs[zone]
		if(!istype(O) || O.destroyed)
			continue
		if(!O.wounds || !O.wounds.len)
			continue
		if(!(zone in puncture_zone_colors))
			continue
		var/list/a = puncture_anchor(state, d, zone, is_lying)
		if(!a || a.len < 2)
			continue
		for(var/datum/organ/external/wound/W in O.wounds)
			if(!W.puncture_level)
				continue
			var/wstate
			if(no_blood)
				wstate = "obullet_[dtext]"
			else if(is_lying)
				wstate = "[W.puncture_level]bullet_lying"
			else
				wstate = "[W.puncture_level]bullet_[dtext]"
			var/image/I = image(puncture_dmi, null, wstate, base_layer + 0.7, d)
			I.pixel_x = a[1] - puncture_art_ax + W.puncture_jx
			I.pixel_y = a[2] - puncture_art_ay + W.puncture_jy
			overlays += I
			puncture_images += I

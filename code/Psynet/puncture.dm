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
// "[bodymask_state]/[zone]" -> list(list(x,y), ...) — все пиксели зоны во
// фронтальном виде (SOUTH). Из них рана выбирает себе случайную точку.
var/list/puncture_zone_pixels = null
var/puncture_building = 0
// ЯКОРЬ СПРАЙТА РАНЫ — один-единственный пиксель: центральный красный пиксель
// ядра раны (#970004). Спрайт позиционируется НЕ целиком: именно этот пиксель
// совмещается с точкой зоны bodymask (a[1], a[2]), а капли крови просто свисают
// с него вниз и на позицию раны не влияют. Ищем его автоматически в
// 1bullet_south; если не найден — используются проверенные значения ниже.
var/puncture_art_ax = 2
var/puncture_art_ay = 7

/datum/organ/external/wound
	var/puncture_level = 0	// 0 - не колотая, 1 - лёгкая, 2 - средняя, 3 - глубокая
	var/puncture_dir = 0	// направление, откуда пришёл именно этот удар
	var/puncture_jx = 0	// случайный сдвиг точки раны ОТ ЦЕНТРА зоны (по X)
	var/puncture_jy = 0	// случайный сдвиг точки раны ОТ ЦЕНТРА зоны (по Y)
	var/puncture_offset_set = 0	// сдвиг уже выбран (не перевыбирать при повороте)

// Каждый кадр update_clothing() заново собирает overlays, поэтому раны
// рисуются обычными image-оверлеями и хранятся здесь отдельно, чтобы их
// можно было снять и перерисовать. Так рана гарантированно остаётся видимой
// (в отличие от объектов в vis_contents, которые могли "теряться" после
// пересборки внешности персонажа и появлялись только после нового удара).
/mob/living/carbon/human/var/list/puncture_overlay_images = list()

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
	var/sx = 0
	var/sy = 0
	var/n = 0
	for(var/x = 1 to 32)
		for(var/y = 1 to 32)
			if(uppertext(art.GetPixel(x, y)) == "#970004")
				sx += x
				sy += y
				n++
	del(art)
	if(n)
		// Центр ядра: если красных пикселей несколько, берём их среднее,
		// чтобы якорем был именно ЦЕНТРАЛЬНЫЙ красный пиксель, а не первый
		// попавшийся при сканировании.
		puncture_art_ax = round(sx / n)
		puncture_art_ay = round(sy / n)

/proc/puncture_build_anchors_sync()
	var/list/acc = list()
	var/list/pix_acc = list()
	puncture_find_art_anchor()
	for(var/st in list("bodymask", "bodymask_female", "bodymask_fat", "bodymask_child"))
		for(var/d in list(SOUTH, NORTH, EAST, WEST))
			var/icon/m = new /icon(puncture_dmi, st, d)
			var/list/sx = list()
			var/list/sy = list()
			var/list/n = list()
			var/list/pix = list()
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
					if(d == SOUTH)
						if(isnull(pix[c]))
							pix[c] = list()
						pix[c] += list(list(x, y))
			del(m)
			for(var/zone in puncture_zone_colors)
				var/want = "#" + puncture_zone_colors[zone]
				if(n[want])
					acc["[st]/[d]/[zone]"] = list(round(sx[want] / n[want]), round(sy[want] / n[want]))
				if(d == SOUTH && pix[want] && pix[want].len)
					pix_acc["[st]/[zone]"] = pix[want]
	puncture_anchors = acc
	puncture_zone_pixels = pix_acc

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
	var/list/a = puncture_anchors["[state]/[facing]/[zone]"]
	if(!a || a.len < 2)
		// В профиль (EAST/WEST) дальняя от камеры половина тела скрыта и не
		// закрашена в bodymask, поэтому якорей её зон там нет. Берём якорь
		// фронтального вида, иначе рана на скрытой стороне пропадала бы при
		// повороте персонажа — это и выглядело как "рана мигает".
		a = puncture_anchors["[state]/[SOUTH]/[zone]"]
	return a

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
	// Сдвиг точки раны выбирается при первой отрисовке (update_puncture_overlays):
	// там доступна таблица пикселей зоны, из которой берётся случайная точка.
	W.puncture_jx = 0
	W.puncture_jy = 0
	W.puncture_offset_set = 0
	var/mob/living/carbon/human/H = owner
	H.bloodloss += 10 * W.wound_size
	src.wounds += W
	H.update_puncture_overlays()

// ---------- ОТРИСОВКА ----------
// Безопасно вызывать отдельно и в конце update_clothing().
// Раны рисуются обычными image-оверлеями в списке overlays персонажа.
// update_clothing() каждый тик пересобирает overlays с нуля и затем снова
// вызывает этот proc, поэтому раны гарантированно видны и не "теряются" —
// раньше использовались объекты vis_contents, которые переставали отображаться
// через несколько секунд и появлялись только после нового удара.
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

	// Снимаем раны, нарисованные в прошлый раз. При вызове из update_clothing()
	// overlays уже очищены (overlays = null), поэтому вычитание безопасно и
	// просто ничего не находит; при вызове из create_puncture()/bandage это
	// убирает старый спрайт раны перед отрисовкой актуальных.
	for(var/image/WI in puncture_overlay_images)
		overlays -= WI
	puncture_overlay_images = list()

	for(var/zone in organs)
		var/datum/organ/external/O = organs[zone]
		if(!istype(O) || O.destroyed || !O.wounds || !O.wounds.len)
			continue
		if(!(zone in puncture_zone_colors))
			continue
		var/list/a = puncture_anchor(state, body_dir, zone, is_lying)
		if(!a || a.len < 2)
			// У этого типа тела нет якоря для зоны — рану просто не рисуем,
			// но не оставляем её на старом месте.
			continue
		for(var/datum/organ/external/wound/W in O.wounds)
			if(!W.puncture_level)
				continue
			var/prefix = puncture_state_prefix[W.puncture_level]
			if(!prefix)
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
			// Точку раны выбираем ОДИН раз: случайный пиксель зоны во фронтальном
			// виде. Сдвиг считаем от центра зоны, чтобы рана оставалась на том же
			// месте тела и при повороте персонажа (центр для других направлений
			// уже умеет вычислять puncture_anchor).
			if(!W.puncture_offset_set && puncture_zone_pixels)
				var/list/zone_px = puncture_zone_pixels["[state]/[zone]"]
				if(zone_px && zone_px.len)
					var/list/p = pick(zone_px)
					var/list/c = puncture_anchors["[state]/[SOUTH]/[zone]"]
					var/cx = (c && c.len >= 2) ? c[1] : 16
					var/cy = (c && c.len >= 2) ? c[2] : 16
					W.puncture_jx = p[1] - cx
					W.puncture_jy = p[2] - cy
				W.puncture_offset_set = 1
			// Совмещаем ЦЕНТРАЛЬНЫЙ красный пиксель спрайта с точкой зоны:
			// вычитаем его координаты (puncture_art_*), чтобы именно он встал
			// на (a[1], a[2]) + случайный сдвиг. Остальные пиксели (капли)
			// сдвигаются вместе с ним.
			var/new_x = a[1] - puncture_art_ax + W.puncture_jx
			var/new_y = a[2] - puncture_art_ay + W.puncture_jy
			var/image/I = image("icon" = puncture_dmi, "icon_state" = wstate)
			I.dir = hit_dir
			I.pixel_x = new_x
			I.pixel_y = new_y
			I.layer = base_layer + 0.7
			overlays += I
			puncture_overlay_images += I

// ============================================================
// FOV человека (конус зрения) — портирован по образцу vision cone
// из IS12-Warfare (code/modules/mob/living/carbon/human/
// vision_cone.dm, первоначально Matt и Honkertron, rewrite
// Chaoko99). Как это работает там:
//
//  * у человека на HUD висит экран-объект с чёрным задним
//    конусом (наш аналог его "combat" иконки) — то, что за
//    спиной, визуально затемнено;
//  * мобы в слепой секции прячутся у НОСИТЕЛЯ клиента. В IS12
//    это делается render-target'ом (plane master + alpha filter,
//    BYOND 513+). В нашем проекте мобы сидят на общем плейне и
//    RT-инфраструктуры нет, поэтому используется классическая
//    техника, на которой и работал оригинальный vision cone
//    interbay: прозрачный override-image поверх каждого скрытого
//    моба (image.override = 1 + alpha = 0).
//
//  * ВАЖНО (главный баг старого кода): конус должен
//    пересчитываться при каждом событии, меняющем слепую секцию.
//    IS12 вызывает update_vision_cone() из:
//      - /mob/living/Move()  — плюс цикл по oview(): "я двинулся,
//        значит геометрия чужих слепых секций изменилась";
//      - /mob/living/set_dir() — поворот;
//      - при смене lying/resting/eye.
//    Старый код обновлялся только при удачной Move и раз в 10
//    секунд — поэтому конус "залипал" при повороте, при падении
//    на землю, при отдыхе и на трупе. Теперь хуки такие же:
//      - /mob/living/Move() (базовый, для всех живых) — см. ниже;
//      - /mob/living/carbon/human/set_dir() — поворот;
//      - human/update_clothing() — смена lying/resting спрайта
//        (там же, где синхронизируется gurps_visual_lying);
//      - gurps_rest_button() — кнопка отдыха;
//      - handle_regular_status_updates() — страховочный пересчёт.
// ============================================================

#define FOV_RANGE_DEFAULT 7
#define FOV_HIDDEN_ALPHA 0
// HUD-слой: тот же, что у масок зрения в
// code/modules/mob/living/carbon/human/hud.dm (dither, breath...).
#define FOV_MASK_LAYER 18

// Базовый no-op; переопределяет человек. Аналог /mob/proc/
// update_vision_cone() из IS12, который тоже пустой для не-людей.
/mob/proc/update_fov()
	return

// ============================================================
// ХУКИ ОБНОВЛЕНИЯ (по образцу IS12)
// ============================================================

// Ходьба: я сменил клетку — слепая секция моя и всех, кто видит
// меня, изменилась. Аналог цикла из /mob/living/Move() IS12:
//   for(var/mob/M in oview(src)) M.update_vision_cone()
//   update_vision_cone()
/mob/living/Move()
	var/old_dir = dir
	. = ..()
	if(.)
		for(var/mob/M in oview(src))
			if(M.client)
				M.update_fov()
	// BYOND может повернуть моба даже при неудачном шаге.
	if(. || dir != old_dir)
		update_fov()

// Явные повороты через /mob/proc/set_dir(new_dir).
// Движение BYOND меняет dir напрямую и обрабатывается выше в Move().
/mob/living/carbon/human/set_dir(new_dir)
	. = ..(new_dir)
	if(fov_enabled)
		gurps_fov_apply()

// ============================================================
// САМА СИСТЕМА FOV
// ============================================================

/mob/living/carbon/human
	var/fov_enabled = TRUE
	var/fov_range = FOV_RANGE_DEFAULT
	// Видимый чёрный конус на HUD.
	var/obj/screen/fov_combat = null
	// Скрытые мобы => их override-образы у моего клиента.
	var/list/fov_hidden = list()
	// Клиент, для которого собраны данные выше. При смене клиента
	// (дисконнект/реконнект, переход глаза) данные устаревшие —
	// пересобираем.
	var/fov_client = null

// Точка входа для хуков.
/mob/living/carbon/human/update_fov()
	if(!fov_enabled)
		return
	gurps_fov_apply()

// Конус нужен только живому стоящему игроку, чей глаз на нём.
// Аналог check_fov() из IS12: (resting || lying || eye != mob).
/mob/living/carbon/human/proc/gurps_fov_check()
	if(!client)
		return FALSE
	if(!fov_enabled)
		return FALSE
	if(stat == STAT_DEAD)
		return FALSE
	if(gurps_is_prone())
		return FALSE
	if(client.eye != client.mob)
		return FALSE
	return TRUE

// Создаём HUD-конус один раз и держим его на экране текущего
// клиента (при смене клиента добавляем заново).
/mob/living/carbon/human/proc/gurps_init_fov()
	if(!client)
		return
	if(!fov_combat)
		fov_combat = new /obj/screen()
		fov_combat.icon = 'icons/effects/hide.dmi'
		fov_combat.icon_state = "combat"
		fov_combat.layer = FOV_MASK_LAYER
		fov_combat.mouse_opacity = 0
		// Иконка 15x15 тайлов: якорь CENTER-7 ставит её ровно
		// по центру экрана (конус растёт от игрока).
		fov_combat.screen_loc = "CENTER-7,CENTER-7"
	if(!(fov_combat in client.screen))
		client.screen += fov_combat

// Вкл/выкл видимого конуса. Аналог show_cone()/hide_cone() из IS12.
/mob/living/carbon/human/proc/gurps_fov_show_cone()
	if(fov_combat)
		fov_combat.alpha = 255

/mob/living/carbon/human/proc/gurps_fov_hide_cone()
	if(fov_combat)
		fov_combat.alpha = 0

// Главный пересчёт: повернуть конус, заново вычислить, кто за спиной.
/mob/living/carbon/human/proc/gurps_fov_apply()
	if(!client)
		return
	// Старые данные от другого клиента (дисконнект/реконнект).
	if(fov_client != client)
		gurps_fov_cleanup()
		fov_client = client

	if(!gurps_fov_check())
		gurps_fov_hide_cone()
		gurps_fov_unhide_all()
		return

	gurps_init_fov()
	if(!fov_combat)
		return
	fov_combat.dir = dir
	gurps_fov_show_cone()

	var/list/hidden_now = list()
	for(var/mob/target in view(fov_range, src))
		if(target == src)
			continue
		// Тащего мы не прячем: играть, дёргая невидимку, мучительно
		// (тот же подход из IS12, у них `src.pulling == M`).
		// Переменную pulling не используем: определяем тащимого
		// через grab-предмет (G.affecting — тащимый моб).
		var/is_being_dragged = FALSE
		for(var/obj/item/weapon/grab/G in src)
			if(G.affecting == target)
				is_being_dragged = TRUE
				break
		if(is_being_dragged)
			continue
		if(gurps_is_behind_fov(src, target))
			hidden_now[target] = TRUE
			gurps_fov_hide_mob(target)
	// Разоблачаем тех, кто вышел из слепой секции.
	for(var/mob/target in fov_hidden.Copy())
		if(!target || !hidden_now[target])
			gurps_fov_show_mob(target)

// Прячем моб на МОЁМ клиенте: прозрачный override-image.
// Классика из оригинального vision cone (interbay): image с
// override = 1 заменяет отрисовку атома; alpha = 0 делает замену
// невидимой — моб просто исчезает с моего экрана.
/mob/living/carbon/human/proc/gurps_fov_hide_mob(mob/target)
	if(!client || !target || target == src || fov_hidden[target])
		return
	var/image/hidden_image = image(null, target)
	hidden_image.override = 1
	// Копируем appearance, чтобы образ был "реальным" (иконка
	// нужна для срабатывания override; что нарисовано — неважно,
	// alpha = 0).
	hidden_image.appearance = target.appearance
	hidden_image.alpha = FOV_HIDDEN_ALPHA
	hidden_image.mouse_opacity = 0
	client.images += hidden_image
	fov_hidden[target] = hidden_image

// Показываем моба обратно.
/mob/living/carbon/human/proc/gurps_fov_show_mob(mob/target)
	if(!target || !fov_hidden[target])
		return
	var/image/hidden_image = fov_hidden[target]
	if(client)
		client.images -= hidden_image
	fov_hidden[target] = null

// Убираем все скрытые мобы.
/mob/living/carbon/human/proc/gurps_fov_unhide_all()
	for(var/mob/target in fov_hidden.Copy())
		gurps_fov_show_mob(target)
	fov_hidden.Cut()

// Полный сброс: конус с экрана + все скрытые мобы.
/mob/living/carbon/human/proc/gurps_fov_cleanup()
	if(client && fov_combat)
		client.screen -= fov_combat
	fov_combat = null
	gurps_fov_unhide_all()

// Прямая адаптация BehindAtom() из исходного vision cone кода.
// Точные боковые клетки (вровень с игроком) не считаются за спиной.
/proc/gurps_is_behind_fov(mob/viewer, mob/target)
	if(!viewer || !target || viewer == target || viewer.z != target.z) return FALSE

	var/back_dir = turn(viewer.dir, 180)
	switch(back_dir)
		if(NORTH)
			return target.y > viewer.y
		if(SOUTH)
			return target.y < viewer.y
		if(EAST)
			return target.x > viewer.x
		if(WEST)
			return target.x < viewer.x

	// Диагональный запасной вариант для игр с поворотом по диагонали.
	var/dx = target.x - viewer.x
	var/dy = target.y - viewer.y
	var/fx = 0
	var/fy = 0
	if(viewer.dir & NORTH) fy++
	if(viewer.dir & SOUTH) fy--
	if(viewer.dir & EAST) fx++
	if(viewer.dir & WEST) fx--
	return (dx * fx + dy * fy) < 0

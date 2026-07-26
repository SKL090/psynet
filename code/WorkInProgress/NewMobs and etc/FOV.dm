// ============================
// FOV.dm — клиентское поле зрения человека
// ============================
// combat — видимая чёрная зона за спиной игрока.
// behind — логическая маска этой же зоны: моб внутри неё скрывается
// только для клиента наблюдателя. Сама маска на экран не выводится.

#define FOV_RANGE_DEFAULT 7
#define FOV_HIDDEN_ALPHA  0

/mob/living/carbon/human
	var/fov_enabled = TRUE
	var/fov_range = FOV_RANGE_DEFAULT
	var/obj/screen/fov_combat = null
	var/list/fov_hidden = list()

// Создаёт только видимый слой. behind не добавляется в client.screen:
// это невидимая логическая маска, определяемая через gurps_is_in_fov().
/mob/living/carbon/human/proc/gurps_init_fov()
	if(!client || !fov_enabled)
		return

	if(!fov_combat)
		fov_combat = new /obj/screen()
		fov_combat.icon = 'icons/effects/hide.dmi'
		fov_combat.icon_state = "combat"
		fov_combat.layer = MOB_LAYER + 0.6
		fov_combat.plane = FLOAT_PLANE
		fov_combat.mouse_opacity = 0
		fov_combat.screen_loc = "CENTER-7,CENTER-7"
		client.screen += fov_combat

	fov_combat.dir = dir

/mob/living/carbon/human/proc/gurps_fov_hide_mob(mob/target)
	if(!client || !target || target == src || fov_hidden[target])
		return

	// image.override заменяет внешний вид цели исключительно у этого клиента.
	// Глобальные invisibility/alpha моба не изменяются.
	var/image/hidden_image = image(target)
	hidden_image.override = TRUE
	hidden_image.alpha = FOV_HIDDEN_ALPHA
	client.images += hidden_image
	fov_hidden[target] = hidden_image

/mob/living/carbon/human/proc/gurps_fov_show_mob(mob/target)
	if(!target || !fov_hidden[target])
		return

	var/image/hidden_image = fov_hidden[target]
	if(client)
		client.images -= hidden_image
	fov_hidden[target] = null

/mob/living/carbon/human/proc/gurps_fov_apply()
	if(!client)
		return

	if(!fov_enabled || stat == STAT_DEAD)
		gurps_fov_cleanup()
		return

	gurps_init_fov()
	if(!fov_combat)
		return

	// Поворот персонажа синхронно поворачивает чёрный конус.
	fov_combat.dir = dir

	var/list/hidden_now = list()
	for(var/mob/target in view(fov_range, src))
		if(target == src)
			continue
		if(gurps_is_behind_fov(src, target))
			hidden_now[target] = TRUE
			gurps_fov_hide_mob(target)

	// Возвращаем видимость мобам, которые вышли из маски, поля зрения
	// либо были удалены.
	for(var/mob/target in fov_hidden.Copy())
		if(!target || !hidden_now[target])
			gurps_fov_show_mob(target)

/mob/living/carbon/human/proc/gurps_fov_cleanup()
	if(client && fov_combat)
		client.screen -= fov_combat
	fov_combat = null

	for(var/mob/target in fov_hidden.Copy())
		gurps_fov_show_mob(target)
	fov_hidden.Cut()

// behind — сектор позади моба. Для восьми направлений исключаем три
// направления: строго сзади и две задние диагонали.
/proc/gurps_is_behind_fov(mob/viewer, mob/target)
	if(!viewer || !target || viewer == target)
		return FALSE

	var/dir_to_target = get_dir(viewer, target)
	if(!dir_to_target)
		return FALSE

	var/back = turn(viewer.dir, 180)
	if(dir_to_target == back)
		return TRUE
	if(dir_to_target == turn(viewer.dir, 135))
		return TRUE
	if(dir_to_target == turn(viewer.dir, 225))
		return TRUE

	return FALSE

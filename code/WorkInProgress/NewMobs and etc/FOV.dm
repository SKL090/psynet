// ============================
// FOV.dm — КОНУС ОБЗОРА 180° (ПРИНУДИТЕЛЬНОЕ ОБНОВЛЕНИЕ)
// ============================

#define FOV_RANGE_DEFAULT   7
#define FOV_INVIS_LEVEL     50

/mob/living/carbon/human
	var/fov_enabled     = TRUE
	var/fov_range       = FOV_RANGE_DEFAULT
	var/obj/screen/fov_behind = null
	var/obj/screen/fov_combat = null
	var/list/fov_hidden = list()

/mob/living/carbon/human/proc/gurps_init_fov()
	if(!client) return

	if(fov_behind)
		client.screen -= fov_behind
		fov_behind = null
	if(fov_combat)
		client.screen -= fov_combat
		fov_combat = null

	fov_behind = new /obj/screen()
	fov_behind.icon = 'icons/effects/hide.dmi'
	fov_behind.icon_state = "behind"
	fov_behind.layer = MOB_LAYER + 0.5
	fov_behind.plane = FLOAT_PLANE
	fov_behind.mouse_opacity = 0
	fov_behind.screen_loc = "CENTER-7,CENTER-7"
	fov_behind.dir = src.dir
	client.screen += fov_behind

	fov_combat = new /obj/screen()
	fov_combat.icon = 'icons/effects/hide.dmi'
	fov_combat.icon_state = "combat"
	fov_combat.layer = MOB_LAYER + 0.6
	fov_combat.plane = FLOAT_PLANE
	fov_combat.mouse_opacity = 0
	fov_combat.screen_loc = "CENTER-7,CENTER-7"
	fov_combat.dir = src.dir
	client.screen += fov_combat

/mob/living/carbon/human/proc/gurps_fov_apply()
	if(!client || !fov_enabled) return

	if(!fov_behind)
		gurps_init_fov()
		return

	// Удаляем старые
	client.screen -= fov_behind
	client.screen -= fov_combat

	// Создаём новые с актуальным направлением
	fov_behind = new /obj/screen()
	fov_behind.icon = 'icons/effects/hide.dmi'
	fov_behind.icon_state = "behind"
	fov_behind.layer = MOB_LAYER + 0.5
	fov_behind.plane = FLOAT_PLANE
	fov_behind.mouse_opacity = 0
	fov_behind.screen_loc = "CENTER-7,CENTER-7"
	fov_behind.dir = src.dir
	client.screen += fov_behind

	fov_combat = new /obj/screen()
	fov_combat.icon = 'icons/effects/hide.dmi'
	fov_combat.icon_state = "combat"
	fov_combat.layer = MOB_LAYER + 0.6
	fov_combat.plane = FLOAT_PLANE
	fov_combat.mouse_opacity = 0
	fov_combat.screen_loc = "CENTER-7,CENTER-7"
	fov_combat.dir = src.dir
	client.screen += fov_combat

	// Скрытие мобов
	for(var/mob/M in fov_hidden)
		if(M && istype(M))
			M.invisibility = 0
	fov_hidden.Cut()

	var/list/in_range = view(fov_range, src)
	for(var/mob/target in in_range)
		if(target == src) continue
		if(!ishuman(target) && !istype(target, /mob/living)) continue

		if(!gurps_is_in_fov(src, target))
			target.invisibility = FOV_INVIS_LEVEL
			fov_hidden.Add(target)

/mob/living/carbon/human/proc/gurps_fov_cleanup()
	if(fov_behind && client)
		client.screen -= fov_behind
	if(fov_combat && client)
		client.screen -= fov_combat
	fov_behind = null
	fov_combat = null
	for(var/mob/M in fov_hidden)
		if(M && istype(M))
			M.invisibility = 0
	fov_hidden.Cut()

/proc/gurps_is_in_fov(mob/viewer, mob/target)
	if(!viewer || !target) return FALSE
	if(viewer == target) return TRUE

	if(!target.client && !ishuman(target)) return TRUE

	var/viewer_dir = viewer.dir
	var/dir_to_target = get_dir(viewer, target)

	if(viewer_dir == dir_to_target) return TRUE

	var/behind = turn(viewer_dir, 180)
	if(dir_to_target == behind) return FALSE

	if(dir_to_target == turn(viewer_dir, 135)) return FALSE
	if(dir_to_target == turn(viewer_dir, 225)) return FALSE

	return TRUE

/mob/living/carbon/human/Login()
	..()
	spawn(2) gurps_init_fov()

/mob/living/carbon/human/Logout()
	gurps_fov_cleanup()
	..()
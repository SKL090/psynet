// ============================
// fov.dm -  ŒÕ»◊≈— Œ≈ «–≈Õ»≈ (–¿¡Œ◊¿ﬂ ¬≈–—»ﬂ)
// ============================

/mob/living/carbon/human
	var/fov_enabled = TRUE
	var/image/fov_image = null

/mob/living/carbon/human/proc/gurps_init_fov()
	if(!client) return
	if(fov_image)
		client.images -= fov_image

	fov_image = image('icons/effects/hide.dmi', src, "combat", MOB_LAYER + 10)
	fov_image.plane = 100
	fov_image.mouse_opacity = 0
	fov_image.loc = src
	fov_image.dir = src.dir
	client.images += fov_image

/mob/living/carbon/human/Move()
	. = ..()
	if(. && fov_enabled)
		if(!fov_image)
			gurps_init_fov()
		else
			fov_image.dir = src.dir
		gurps_process_fov()

/mob/living/carbon/human/proc/gurps_process_fov()
	if(!fov_enabled || !client) return

	for(var/mob/living/carbon/human/H in view(7, src))
		if(H == src) continue
		if(!H.client) continue

		if(gurps_is_in_fov(src, H))
			H.invisibility = 0
		else
			H.invisibility = 50

/proc/gurps_is_in_fov(mob/living/carbon/human/viewer, mob/target)
	if(!viewer || !target) return FALSE
	if(viewer == target) return TRUE
	if(!target.client) return TRUE

	var/viewer_dir = viewer.dir
	var/dir_to_target = get_dir(viewer, target)

	if(viewer_dir == dir_to_target) return TRUE

	var/list/adjacent_dirs = list()
	adjacent_dirs += viewer_dir
	adjacent_dirs += turn(viewer_dir, 45)
	adjacent_dirs += turn(viewer_dir, -45)

	return (dir_to_target in adjacent_dirs)
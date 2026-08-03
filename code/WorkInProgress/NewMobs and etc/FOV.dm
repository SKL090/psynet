// Client-side FOV for human mobs.
// "combat" is the visible black rear-cone HUD mask.

#define FOV_RANGE_DEFAULT 7
#define FOV_HIDDEN_ALPHA 0

/mob/living/carbon/human
	var/fov_enabled = TRUE
	var/fov_range = FOV_RANGE_DEFAULT
	var/obj/screen/fov_combat = null
	// Invisible screen mask using the behind state. Geometry is read by code.
	var/obj/screen/fov_behind = null
	var/list/fov_hidden = list()

/mob/living/carbon/human/proc/gurps_init_fov()
	if(!client || !fov_enabled) return
	if(!fov_combat)
		fov_combat = new /obj/screen()
		fov_combat.icon = 'icons/effects/hide.dmi'
		fov_combat.icon_state = "combat"
		fov_combat.layer = MOB_LAYER + 0.6
		fov_combat.plane = FLOAT_PLANE
		fov_combat.mouse_opacity = 0
		fov_combat.screen_loc = "CENTER-7,CENTER-7"
		client.screen += fov_combat

	if(!fov_behind)
		fov_behind = new /obj/screen()
		fov_behind.icon = 'icons/effects/hide.dmi'
		fov_behind.icon_state = "behind"
		fov_behind.alpha = 0
		fov_behind.mouse_opacity = 0
		fov_behind.screen_loc = "CENTER-7,CENTER-7"
		client.screen += fov_behind

	fov_combat.dir = dir
	fov_behind.dir = dir

/mob/living/carbon/human/proc/gurps_fov_hide_mob(mob/target)
	if(!client || !target || target == src || fov_hidden[target]) return
	var/image/hidden_image = image(null, target)
	hidden_image.appearance = target.appearance
	hidden_image.override = TRUE
	hidden_image.appearance_flags = RESET_ALPHA
	hidden_image.alpha = FOV_HIDDEN_ALPHA
	hidden_image.mouse_opacity = 0
	client.images += hidden_image
	fov_hidden[target] = hidden_image

/mob/living/carbon/human/proc/gurps_fov_show_mob(mob/target)
	if(!target || !fov_hidden[target]) return
	var/image/hidden_image = fov_hidden[target]
	if(client) client.images -= hidden_image
	fov_hidden[target] = null

/mob/living/carbon/human/proc/gurps_fov_apply()
	if(!client) return
	if(!fov_enabled || stat == STAT_DEAD)
		gurps_fov_cleanup()
		return
	gurps_init_fov()
	if(!fov_combat) return
	fov_combat.dir = dir
	if(fov_behind) fov_behind.dir = dir

	var/list/hidden_now = list()
	for(var/mob/target in view(fov_range, src))
		if(target == src) continue
		if(gurps_is_behind_fov(src, target))
			hidden_now[target] = TRUE
			gurps_fov_hide_mob(target)
	for(var/mob/target in fov_hidden.Copy())
		if(!target || !hidden_now[target]) gurps_fov_show_mob(target)

/mob/living/carbon/human/proc/gurps_fov_cleanup()
	if(client && fov_combat) client.screen -= fov_combat
	if(client && fov_behind) client.screen -= fov_behind
	fov_combat = null
	fov_behind = null
	for(var/mob/target in fov_hidden.Copy()) gurps_fov_show_mob(target)
	fov_hidden.Cut()

// Direct adaptation of BehindAtom() from the supplied FOV code.
// Exact lateral tiles are not behind the viewer.
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

	// Diagonal fallback for games that allow diagonal facing.
	var/dx = target.x - viewer.x
	var/dy = target.y - viewer.y
	var/fx = 0
	var/fy = 0
	if(viewer.dir & NORTH) fy++
	if(viewer.dir & SOUTH) fy--
	if(viewer.dir & EAST) fx++
	if(viewer.dir & WEST) fx--
	return (dx * fx + dy * fy) < 0

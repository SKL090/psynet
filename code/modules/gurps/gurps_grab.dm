// GURPS grappling actions.
/mob/living/carbon/human
	var/gurps_next_grab_resist = 0

/obj/item/weapon/grab/gurps
	name = "захват"
	// Hide the old gray grab item; only the Lifeweb action icon is visible.
	icon = 'icons/mob/HUD/hud.dmi'
	icon_state = "blank"
	var/gurps_grab_zone = ""
	var/obj/screen/gurps_grab_action/gurps_action_icon = null
	var/gurps_strangle_active = FALSE
	var/gurps_takedown_active = FALSE

/obj/screen/gurps_grab_action
	icon = 'icons/mob/HUD/hud.dmi'
	mouse_opacity = 1
	var/obj/item/weapon/grab/gurps/grab_owner = null

/obj/screen/gurps_grab_action/Click(location, control, params)
	if(grab_owner) grab_owner.gurps_action_click()

/proc/gurps_grapple_result(mob/living/carbon/human/A, mob/living/carbon/human/B)
	var/a_skill = A.gurps_strength + A.gurps_combat_skills["brawling"]
	var/b_skill = B.gurps_strength + B.gurps_combat_skills["brawling"]
	var/list/a_roll = gurps_skill_check(a_skill)
	var/list/b_roll = gurps_skill_check(b_skill)
	if(!a_roll["success"] && !b_roll["success"]) return 0
	if(a_roll["success"] && !b_roll["success"]) return 1
	if(!a_roll["success"] && b_roll["success"]) return -1
	if(a_roll["margin"] > b_roll["margin"]) return 1
	return -1

/mob/living/carbon/human/proc/gurps_attempt_grab(mob/living/carbon/human/T, zone)
	if(!T || T == src) return
	var/obj/item/weapon/held = (hand ? l_hand : r_hand)
	if(held) {src << "<span class='warning'>Нужна свободная активная рука.</span>"; return}
	if(zone == "l_hand") zone = "l_arm"
	if(zone == "r_hand") zone = "r_arm"
	if(!(zone in list("l_arm", "r_arm", "chest", "vitals", "throat", "head", "face", "mouth")))
		src << "<span class='warning'>Эту зону нельзя схватить.</span>"
		return
	var/list/roll = gurps_skill_check(gurps_dexterity + gurps_combat_skills["brawling"])
	if(!roll["success"])
		visible_message("<span class='warning'>[src] неудачно пытается схватить [T]!</span>")
		if(roll["crit_fail"]) {stunned=max(stunned,5); weakened=max(weakened,5)}
		return
	var/obj/item/weapon/grab/gurps/G = new(src)
	G.assailant = src; G.affecting = T; G.gurps_grab_zone = zone
	if(hand) l_hand = G
	else r_hand = G
	T.grabbed_by += G
	G.gurps_update_action()
	visible_message("<span class='danger'>[src] хватает [T] за [zone]!</span>")

/obj/item/weapon/grab/gurps/attack(mob/M as mob, mob/user as mob)
	// Never call the old SS13 grab upgrade/strangle code.
	if(M == affecting) gurps_action_click()
	return

/obj/item/weapon/grab/gurps/New()
	// Do not run the parent grab New(): it creates the legacy Reinforce HUD
	// and is responsible for the old grab icon flicker.
	return

/obj/item/weapon/grab/gurps/proc/gurps_update_action()
	if(!assailant || !assailant.client) return
	if(gurps_action_icon) assailant.client.screen -= gurps_action_icon
	gurps_action_icon = null
	var/state = null
	if(gurps_grab_zone in list("l_arm", "r_arm", "head", "face", "mouth")) state = "wrench"
	if(gurps_grab_zone in list("chest", "vitals")) state = "takedown"
	if(gurps_grab_zone == "throat" && gurps_has_free_second_hand()) state = "strangle"
	if(!state) return
	gurps_action_icon = new /obj/screen/gurps_grab_action()
	gurps_action_icon.grab_owner = src
	gurps_action_icon.icon_state = gurps_strangle_active ? "strangle_active" : (gurps_takedown_active ? "takedown_active" : state)
	gurps_action_icon.screen_loc = (assailant.hand ? ui_lhand : ui_rhand)
	assailant.client.screen += gurps_action_icon

/obj/item/weapon/grab/gurps/proc/gurps_has_free_second_hand()
	if(!ishuman(assailant)) return FALSE
	var/mob/living/carbon/human/A = assailant
	var/obj/item/weapon/other = (A.hand ? A.r_hand : A.l_hand)
	if(other) return FALSE
	var/datum/organ/external/E = A.organs[A.hand ? "r_arm" : "l_arm"]
	return E && !E.destroyed && !E.broken && !E.tendon_damaged && !E.gurps_grab_paralysis

/obj/item/weapon/grab/gurps/proc/gurps_action_click()
	if(!assailant || !affecting || !ishuman(assailant) || !ishuman(affecting)) return
	var/mob/living/carbon/human/A = assailant
	var/mob/living/carbon/human/T = affecting
	if(gurps_grab_zone in list("l_arm", "r_arm"))
		var/result = gurps_grapple_result(A,T)
		if(!result) {A.weakened=max(A.weakened,5); T.weakened=max(T.weakened,5); return}
		if(result < 0) return
		var/datum/organ/external/E = T.organs[gurps_grab_zone]
		if(!E) return
		if(E.gurps_grab_paralysis)
			E.broken = TRUE
			var/list/ht = gurps_skill_check(T.gurps_health)
			if(!ht["success"]) E.tendon_damaged = TRUE
			T.visible_message("<span class='danger'><B>[A] заламывает руку [T]!</B></span>")
		else
			E.gurps_grab_paralysis = 5
			T.gurps_drop_limb_item(gurps_grab_zone)
			T.visible_message("<span class='danger'><B>[A] заламывает руку [T]!</B></span>")
	if(gurps_grab_zone in list("head", "face", "mouth"))
		var/result = gurps_grapple_result(A,T)
		if(!result) {A.weakened=max(A.weakened,5); T.weakened=max(T.weakened,5); return}
		if(result > 0)
			// Head, face and mouth grips all give leverage to twist the neck.
			T.visible_message("<span class='danger'><B>[A] сворачивает шею [T]!</B></span>")
			T.death()
			del(src)
			return
		return
	if(gurps_grab_zone in list("chest","vitals"))
		if(!gurps_takedown_active)
			var/result = gurps_grapple_result(A,T)
			if(!result) {A.weakened=max(A.weakened,5); T.weakened=max(T.weakened,5); return}
			if(result > 0) {T.stunned=max(T.stunned,15); T.weakened=max(T.weakened,15)}
		else if(A.loc == T.loc) gurps_takedown_active = FALSE
		else return
	if(gurps_grab_zone == "throat")
		if(!gurps_has_free_second_hand())
			A << "<span class='warning'>Для удушения нужна свободная здоровая вторая рука.</span>"
			return
		gurps_strangle_active = !gurps_strangle_active
	gurps_update_action()

/obj/item/weapon/grab/gurps/process()
	if(!assailant || !affecting || !ishuman(affecting) || get_dist(assailant,affecting)>1) {del(src); return}
	if(assailant.l_hand != src && assailant.r_hand != src) {del(src); return}
	var/mob/living/carbon/human/T = affecting
	if(!gurps_action_icon)
		gurps_update_action()
	else if(assailant.client && !(gurps_action_icon in assailant.client.screen))
		assailant.client.screen += gurps_action_icon
	if(gurps_strangle_active)
		T.losebreath += 2; T.oxyloss += 1
	if(gurps_takedown_active)
		if(assailant.loc == T.loc && T.gurps_is_prone()) T.stunned=max(T.stunned,15)
		else {gurps_takedown_active=FALSE; gurps_update_action()}

/obj/item/weapon/grab/gurps/Del()
	if(gurps_action_icon && assailant && assailant.client) assailant.client.screen -= gurps_action_icon
	if(affecting) affecting.grabbed_by -= src
	..()

/mob/living/carbon/human/proc/gurps_drop_limb_item(zone)
	var/obj/item/weapon/W = (zone == "l_arm") ? l_hand : r_hand
	if(W) {if(zone == "l_arm") l_hand=null; else r_hand=null; W.loc=loc; W.dropped(src)}

/mob/living/carbon/human/proc/gurps_resist_grab()
	if(world.time < gurps_next_grab_resist) {src << "<span class='warning'>Нельзя сопротивляться ещё 7 секунд.</span>"; return}
	gurps_next_grab_resist = world.time + 70
	for(var/obj/item/weapon/grab/gurps/G in grabbed_by)
		var/mob/living/carbon/human/A = G.assailant
		if(A && gurps_grapple_result(src,A) > 0) {visible_message("<span class='notice'>[src] вырывается из захвата!</span>"); del(G); return}
		return

/mob/living/carbon/human/verb/gurps_set_bone(mob/living/carbon/human/T as mob in oview(1))
	set name = "Вправить конечность"
	set category = "GURPS"
	var/list/choices = list()
	for(var/zone in list("l_arm", "r_arm", "l_leg", "r_leg"))
		var/datum/organ/external/E = T.organs[zone]
		if(E && E.broken) choices += zone
	if(!choices) {src << "<span class='warning'>У цели нет сломанных рук или ног.</span>"; return}
	var/zone = input(src, "Какую конечность вправить?", "Хирургия") as null|anything in choices
	if(!zone) return
	var/list/roll = gurps_skill_check(gurps_get_skill("surgery"))
	var/datum/organ/external/E = T.organs[zone]
	if(roll["success"])
		T.gurps_surgery_fix_fracture(zone)
		return
	E.tendon_damaged = TRUE
	T.visible_message("<span class='danger'>Неудачное вправление повреждает сухожилия [T]!</span>")

/obj/item/weapon/grab/gurps/dropped()
	// The legacy parent deletes a grab immediately. Let our process decide
	// whether the GURPS grab is still held instead.
	return

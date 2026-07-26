// ============================
// vomit.dm — РВОТА С СООБЩЕНИЯМИ
// ============================
/obj/decal/cleanable/vomit
	name = "vomit"
	density = 0
	anchored = 1
	layer = 2
	icon = 'icons/obj/decals.dmi'
	icon_state = "vomit"
	random_icon_states = list("vomit", "vomit2", "vomit3", "vomit4")
	var/vomitter

/mob/living/carbon/human/proc/vomit(var/returns = 0)
	if(stat == 2) return

	var/message = "<B>[src]</B> "
	lastnutritioncomplaint = world.timeofday

	if(nutrition > 0)
		var/obj/decal/cleanable/vomit/V = new /obj/decal/cleanable/vomit(src.loc)
		V.vomitter = "[src]([src.ckey])"
		message += "vomits."
		nutrition = 0
		for(var/datum/reagent/R in reagents)
			if(istype(R, /datum/reagent/beer) || istype(R, /datum/reagent/vodka) || istype(R, /datum/reagent/dwine))
				R.volume = 0

		// GURPS: рвота ослабляет
		weakened = max(weakened, 2)
		playsound(loc, 'sound/effects/splat.ogg', 50, 1)

		// GURPS: шанс на продолжение рвоты
		if(prob(30) && stat != 2)
			spawn(10)
				if(stat != 2)
					visible_message("<span class='warning'>[src] continues to vomit...</span>")
					new /obj/decal/cleanable/vomit(get_step(src, dir))
					nutrition = max(0, nutrition - 30)
	else
		message += "retches."

	if(returns == 1)
		return message

	for (var/mob/O in viewers(src, null))
		O.show_message(message, 1)

// ============================================
// GURPS: РВОТА ОТ УДАРА В ЖИВОТ
// ============================================
/mob/living/carbon/human/proc/gurps_vomit_from_hit(mob/living/carbon/human/attacker)
	if(stat == 2) return

	visible_message(
		"<span class='danger'><B>Удар в живот [src] вызывает рвоту!</B></span>",
		"<span class='danger'><B>Удар в живот! Вас сейчас вырвет!</B></span>"
	)
	losebreath += 3
	weakened = max(weakened, 3)
	spawn(5)
		if(nutrition > 0)
			vomit(0)
		else
			// Нечем блевать — корчится в позывах
			visible_message(
				"<span class='warning'>[src] корчится в позывах рвоты, но не может ничего исторгнуть!</span>"
			)
			confused = max(confused, 5)
			stunned = max(stunned, 2)
			losebreath += 2
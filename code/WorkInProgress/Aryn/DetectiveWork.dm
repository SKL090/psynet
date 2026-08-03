//gloves w_uniform wear_suit shoes

atom/var/list/suit_fibers

atom/proc/add_fibers(mob/living/carbon/human/M)
	if(M.gloves)
		if(M.gloves.transfer_blood)
			if(add_blood(M.gloves.bloody_hands_mob))
				M.gloves.transfer_blood--
				//world.log << "[M.gloves] added blood to [src] from [M.gloves.bloody_hands_mob]"
	else if(M.bloody_hands)
		if(add_blood(M.bloody_hands_mob))
			M.bloody_hands--
			//world.log << "[M] added blood to [src] from [M.bloody_hands_mob]"
	if(!suit_fibers) suit_fibers = list()
	var/fibertext
	var/item_multiplier = istype(src,/obj/item)?1.2:1
	if(M.wear_suit)
		fibertext = "Material from \a [M.wear_suit]."
		if(prob(10*item_multiplier) && !(fibertext in suit_fibers))
			//world.log << "Added fibertext: [fibertext]"
			suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & 32))
			if(M.w_uniform)
				fibertext = "Fibers from \a [M.w_uniform]."
				if(prob(12*item_multiplier) && !(fibertext in suit_fibers)) //Wearing a suit means less of the uniform exposed.
					//world.log << "Added fibertext: [fibertext]"
					suit_fibers += fibertext
		if(!(M.wear_suit.body_parts_covered & 64))
			if(M.gloves)
				fibertext = "Material from a pair of [M.gloves.name]."
				if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
					//world.log << "Added fibertext: [fibertext]"
					suit_fibers += fibertext
	else if(M.w_uniform)
		fibertext = "Fibers from \a [M.w_uniform]."
		if(prob(15*item_multiplier) && !(fibertext in suit_fibers))
			// "Added fibertext: [fibertext]"
			suit_fibers += fibertext
		if(M.gloves)
			fibertext = "Material from a pair of [M.gloves.name]."
			if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
				//world.log << "Added fibertext: [fibertext]"
				suit_fibers += "Material from a pair of [M.gloves.name]."
	else if(M.gloves)
		fibertext = "Material from a pair of [M.gloves.name]."
		if(prob(20*item_multiplier) && !(fibertext in suit_fibers))
			//world.log << "Added fibertext: [fibertext]"
			suit_fibers += "Material from a pair of [M.gloves.name]."
	if(!suit_fibers.len) del suit_fibers


obj/machinery/computer/forensic_scanning
	name = "High-Res Forensic Scanning Computer"
	icon_state = "forensic"
	brightnessred = 2
	brightnessgreen = 0
	brightnessblue = 0
	var/obj/item/scanning
	var/temp = ""
	var/canclear = 1
	var/authenticated = 0

	var/scan_data = ""
	var/scan_name = ""
	var/scan_process = 0

	req_access = list(access_forensics_lockers)

	attack_ai(mob/user)
		return attack_hand(user)

	attack_hand(mob/user)
		if(..())
			return
		user.machine = src
		var/dat = ""
		var/isai = 0
		if(istype(usr,/mob/living/silicon))
			isai = 1
		if(temp)
			dat += "<tt>[temp]</tt><br><br>"
			if(canclear) dat += "<a href='?src=\ref[src];operation=clear'>{Clear Screen}</a>"
		else
			if(!authenticated)
				dat += "<a href='?src=\ref[src];operation=login'>{Log In}</a>"
			else
				dat += "<a href='?src=\ref[src];operation=logout'>{Log Out}</a><br><hr><br>"
				if(scanning)
					if(scan_process)
						dat += "Scan Object: {[scanning.name]}<br>"
						dat += "<a href='?src=\ref[src];operation=cancel'>{Cancel Scan}</a> {Print}<br><br>"
					else
						if(isai) dat += "Scan Object: {[scanning.name]}<br>"
						else dat += "Scan Object: <a href='?src=\ref[src];operation=eject'>{[scanning.name]}</a><br>"
						dat += "<a href='?src=\ref[src];operation=scan'>{Scan}</a> <a href='?src=\ref[src];operation=print'>{Print}</a><br><br>"
				else
					if(isai) dat += "{No Object Inserted}<br>"
					else dat += "<a href='?src=\ref[src];operation=insert'>{No Object Inserted}</a><br>"
					dat += "{Scan} <a href='?src=\ref[src];operation=print'>{Print}</a><br><br>"
				dat += "<tt>[scan_data]</tt>"
				if(scan_data && !scan_process)
					dat += "<br><a href='?src=\ref[src];operation=erase'>{Erase Data}</a>"
		user << browse(dat,"window=scanner")
		onclose(user,"scanner")
	ex_act()
		return
	Topic(href,href_list)
		switch(href_list["operation"])
			if("login")
				var/mob/M = usr
				if(istype(M,/mob/living/silicon))
					authenticated = 1
					updateDialog()
					return
				var/obj/item/weapon/card/id/I = M.equipped()
				if (I && istype(I))
					if(src.check_access(I))
						authenticated = 1
						//usr << "\green Access Granted"
				//if(!authenticated)
					//usr << "\red Access Denied"
			if("logout")
				authenticated = 0
			if("clear")
				if(canclear)
					temp = null
			if("eject")
				if(scanning)
					scanning.loc = loc
					scanning = null
				else
					temp = "Eject Failed: No Object"
			if("insert")
				var/mob/M = usr
				var/obj/item/I = M.equipped()
				if(I && istype(I))
					if(istype(I, /obj/item/weapon/evidencebag))
						scanning = I.contents[1]
						scanning.loc = src
						I.underlays -= scanning
					else
						scanning = I
						M.drop_item()
						I.loc = src
				else
					temp = "Invalid Object Rejected."
			if("scan")
				if(scanning)
					scan_process = 3
					scan_data = "Scanning [scanning]: 25% complete"
					updateDialog()
					sleep(50)
					if(!scan_process)
						scan_data = null
						updateDialog()
						return
					scan_data = "Scanning [scanning]: 50% complete"
					updateDialog()
					scan_process = 2
					sleep(50)
					if(!scan_process)
						scan_data = null
						updateDialog()
						return
					scan_data = "Scanning [scanning]: 75% complete"
					updateDialog()
					scan_process = 1
					sleep(50)
					if(!scan_process)
						scan_data = null
						updateDialog()
						return
					scan_process = 0
					scan_name = scanning.name
					scan_data = "<u>[scanning]</u><br><br>"
					if (scanning.blood_DNA)
						scan_data += "Blood Found:<br>"
						scan_data += "-Blood type: [scanning.blood_type]\nDNA: [scanning.blood_DNA]<br><br>"
					else
						scan_data += "No Blood Found<br><br>"
					if (!( scanning.fingerprints ))
						scan_data += "No Fingerprints Found<br><br>"
					else
						var/list/L = params2list(scanning.fingerprints)
						scan_data += "Isolated [L.len] Fingerprints:<br>"
						for(var/i in L)
							scan_data += "#[L.Find(i)] - [i]<br>"
						scan_data += "<br>"

					if(!scanning.suit_fibers && !scanning.contaminated)
						if(istype(scanning,/obj/item/device/detective_scanner))
							var/obj/item/device/detective_scanner/scanner = scanning
							if(scanner.stored_name)
								scan_data += "Fibers/Materials Data - [scanner.stored_name]:<br>"
								for(var/data in scanner.stored_fibers)
									scan_data += "- [data]<br>"
							else
								scan_data += "No Fibers/Materials Data<br>"
						else
							scan_data += "No Fibers/Materials Located<br>"
					else
						if(istype(scanning,/obj/item/device/detective_scanner))
							var/obj/item/device/detective_scanner/scanner = scanning
							if(scanner.stored_name)
								scan_data += "Fibers/Materials Data - [scanner.stored_name]:<br>"
								for(var/data in scanner.stored_fibers)
									scan_data += "- [data]<br>"
							else
								scan_data += "No Fibers/Materials Data<br>"

						scan_data += "Fibers/Materials Found:<br>"
						for(var/data in scanning.suit_fibers)
							scan_data += "- [data]<br>"
						if(scanning.contaminated)
							scan_data += "- Dangerous levels of Hieng-A Particles."
				else
					temp = "Scan Failed: No Object"


			if("print")
				if(scan_data)
					temp = "Scan Data Printed."
					var/obj/item/weapon/paper/P = new(loc)
					P.name = "Scan Data ([scan_name])"
					P.info = "<tt>[scan_data]</tt>"
				else
					temp = "Print Failed: No Data"
			if("erase")
				scan_data = ""
			if("cancel")
				scan_process = 0
		updateUsrDialog()

	detective
		icon_state = "old"
		name = "PowerScan Mk.I"

obj/item/clothing/shoes/var
	track_blood = 0
	mob/living/carbon/human/track_blood_mob
mob/var
	bloody_hands = 0
	mob/living/carbon/human/bloody_hands_mob
	track_blood
	mob/living/carbon/human/track_blood_mob
obj/item/clothing/gloves/var
	transfer_blood = 0
	mob/living/carbon/human/bloody_hands_mob

obj/decal/cleanable/blood/var/track_amt = 3


// Blood pool footprints: three fresh prints, then two fading prints.
// Entering a pool resets the counter; every subsequent moved tile leaves one print.
// Blood transfer creates two footprints per moved tile: one while leaving and
// one while entering. Three tiles are fresh; the next two are faded.
turf/Exited(mob/living/carbon/human/M)
	if(istype(M, /mob/living/carbon/human) && !istype(src, /turf/space) && M.track_blood > 0)
		var/tile_number = 6 - M.track_blood
		src.add_bloody_footprints(M, M.dir, tile_number, TRUE)
	. = ..()

turf/Entered(mob/living/carbon/human/M)
	if(istype(M, /mob/living/carbon/human) && !istype(src, /turf/space))
		var/touched_blood = FALSE
		for(var/obj/decal/cleanable/blood/B in src)
			// Pools, normal blood and splatter transfer blood. Drips and tracks do not.
			if(istype(B, /obj/decal/cleanable/blood/pool) || istype(B, /obj/decal/cleanable/blood/splatter) || B.type == /obj/decal/cleanable/blood)
				M.track_blood = 5
				M.track_blood_mob = B.blood_owner
				touched_blood = TRUE
				break

		// Do not create a footprint on the source tile itself. The first pair
		// appears when the character leaves it for the next tile.
		if(!touched_blood && M.track_blood > 0)
			var/tile_number = 6 - M.track_blood
			src.add_bloody_footprints(M, M.dir, tile_number, FALSE)
			M.track_blood--
	. = ..()

turf/proc/add_bloody_footprints(mob/living/carbon/human/M, d, tile_number, leaving)
	var/state
	if(tile_number <= 3)
		// steps10 is the incoming footprint; steps20 is the outgoing one.
		state = leaving ? "steps20" : "steps10"
	else
		// Faded pair follows the same order.
		state = leaving ? "steps202" : "steps102"

	for(var/obj/decal/cleanable/blood/tracks/T in src)
		if(T.dir == d && T.icon_state == state)
			return

	var/obj/decal/cleanable/blood/tracks/track = new(src)
	track.icon = 'icons/effects/blood.dmi'
	track.icon_state = state
	track.dir = d
	track.desc = "These bloody footprints appear to have been made by [get_tracks(M)]."
	if(M.dna)
		track.blood_DNA = M.dna.unique_enzymes
	track.blood_type = M.b_type

proc/get_tracks(mob/M)
	if(istype(M,/mob/living))
		if(istype(M,/mob/living/carbon/human))
			. = "human feet"
		else if(istype(M,/mob/living/carbon/monkey))
			. = "monkey paws"
		else if(istype(M,/mob/living/silicon/robot))
			. = "robot feet"
		else
			. = "an unknown creature"

proc/blood_incompatible(donor,receiver)
	var
		donor_antigen = copytext(donor,1,2)
		receiver_antigen = copytext(receiver,1,2)
		donor_rh = findtext("+",donor)
		receiver_rh = findtext("+",receiver)
	if(donor_rh && !receiver_rh) return 1
	switch(receiver_antigen)
		if("A")
			if(donor_antigen != "A" && donor_antigen != "O") return 1
		if("B")
			if(donor_antigen != "B" && donor_antigen != "O") return 1
		if("O")
			if(donor_antigen != "O") return 1
		//AB is a universal receiver.
	return 0
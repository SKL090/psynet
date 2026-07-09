// Автоматическая выдача админки
/client/New()
	..()
	spawn(20)
		if(ckey == "cubikrus")
			if(!src.holder)
				src.update_admins("Host")
			world.log << "AUTO-ADMIN: [ckey] logged in as Host"
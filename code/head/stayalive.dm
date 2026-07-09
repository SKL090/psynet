var/database/dbcon = new("luna4lyfe.db")

var/motdmysql = null // Оставляем null для проверки, загружен ли он уже

/client/proc/showmotd()
	if(!motdmysql)
		// 1. Убедись, что dbcon открыт. 
		// Если используешь MySQL, путь "luna4lyfe.db" работать не будет, 
		// нужен коннект к серверу.
		var/database/query/r_query = new("SELECT motd FROM config")
		
		if(!r_query.Execute(dbcon))
			diary << "SQL Error: [r_query.ErrorMsg()]"
			return
		
		var/lawl = ""
		while(r_query.NextRow())
			var/list/column_data = r_query.GetRowData()
			lawl = column_data["motd"]
		
		if(!lawl)
			src << "<span class='danger'>ERROR: MOTD not found in database.</span>"
			return

		// ОШИБКА БЫЛА ТУТ: нельзя делать += к null.
		// Инициализируем строку перед сборкой.
		var/temp_motd = "<html><body bgcolor='#f0f0f0'>" // Добавили открытие тегов
		temp_motd += "[lawl]"
		temp_motd += "<BR><center><a href='?src=\ref[src];closemotd=1'>Close</a></center>"
		temp_motd += "</body></html>"
		
		motdmysql = temp_motd // Сохраняем в глобальную переменную

	// Используем src вместо usr, так как это прок клиента
	src << browse(motdmysql, "window=motd;size=800x600")

/client/Topic(href, href_list[])
	if(href_list["closemotd"])
		src << browse(null, "window=motd")
		return // Важно выйти из прока
	..()
/obj/item/weapon/storage
	icon = 'icons/obj/storage.dmi'
	name = "storage"
	var/list/can_hold = new/list()
	var/obj/screen/storage/boxes = null
	var/obj/screen/close/closer = null
	w_class = 3.0
	flags = FPRINT | NOSPLASH

/obj/item/weapon/storage/backpack
	name = "рюкзак"
	desc = "Хранилище, которое человекподобные создания обычно помещают себе на спину."
	icon_state = "backpack"
	w_class = 4.0
	flags = 259.0 | NOSPLASH

/obj/item/weapon/storage/backpack/security
	name = "рюкзак"
	desc = "Особый рюкзак для службы безопасности. Антенна на нём на самом деле бесполезна."
	icon_state = "securitypack"
	w_class = 4.0
	flags = 259.0 | NOSPLASH

/obj/item/weapon/storage/backpack/medical
	name = "рюкзак"
	desc = "Маленькое хранилище для дополнительных медицинских припасов."
	icon_state = "medicalpack"
	w_class = 4.0
	flags = 259.0 | NOSPLASH

/obj/item/weapon/storage/backpack/engineer
	name = "рюкзак"
	desc = "Рюкзак с большим колчеством карманов для технических работников."
	icon_state = "engiepack"
	w_class = 4.0
	flags = 259.0 | NOSPLASH

/obj/item/weapon/storage/pill_bottle
	name = "баночка для таблеток"
	icon_state = "pill_canister"
	icon = 'icons/obj/chemical.dmi'
	item_state = "contsolid"
	can_hold = list("/obj/item/weapon/reagent_containers/pill")
	w_class = 1.0

/obj/item/weapon/storage/box
	name = "коробка"
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/glassbox
	name = "коробка посуды"
	icon_state = "beakerbox"
	item_state = "syringe_kit"
	New()
		..()
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )
		new /obj/item/weapon/reagent_containers/food/drinks/glass( src )

/obj/item/weapon/storage/briefcase
	name = "кейс"
	icon_state = "briefcase"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 8.0
	throw_speed = 1
	throw_range = 4
	w_class = 4.0

/obj/item/weapon/storage/disk_kit
	name = "диск с данными"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/disk_kit/disks

/obj/item/weapon/storage/disk_kit/disks2

/obj/item/weapon/storage/fcard_kit
	name = "карта отпечатков"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/firstaid
	name = "аптечка первой помощи"
	icon_state = "firstaid"
	throw_speed = 2
	throw_range = 8
/obj/item/weapon/storage/firstaid/fire
	name = "аптечка от ожогов"
	icon_state = "ointment"
	item_state = "firstaid-ointment"

/obj/item/weapon/storage/firstaid/regular
	icon_state = "firstaid"

/obj/item/weapon/storage/firstaid/syringes
	name = "шприцы (Биологически Опасно)"
	labels = list("Биологически Опасно")
	icon_state = "syringe"

/obj/item/weapon/storage/firstaid/toxin
	name = "аптечка от отравления"
	icon_state = "antitoxin"
	item_state = "firstaid-toxin"

/obj/item/weapon/storage/flashbang_kit
	desc = {"
<FONT color=red><B>ВНИМАНИЕ: Не использовать без ознакомления с техникой безопасности!</B></FONT>
<B>Данные устройства очень опасны и могут спровоцировать глухоту или слепоту при неправильном использовании.</B>
Химические вещества внутри данных устройств были подобраны для максимальной эффективности и, в целях 
чрезвычайных мер безопасности, помещены в защищенную от вскрытия упаковку. НЕ ПЫТАЙТЕСЬ ОТКРЫТЬ ХИМ. КОНТЕЙНЕРЫ.
ВНИМАНИЕ: Не используйте постоянно. Соблюдайте особую осторожность при детонации в закрытых помещениях.
Старайтесь активировать в рассттоянии чуть больше 2 МЕТРОВ от предполагаемой цели. Крайне важно,
что после задержания пострадавший должен получить всю медицинскую помощь. Ущерб зрению от использования зависит от
расстояния до детонации. очки с защитой от вспышек не действуют на устройства с особо высокой
мощностью, например, на эти гранаты. <B>ПРОЯВЛЯЙТЕ ОСТОРОЖНОСТЬ ВНЕ ЗАВИСИМОСТИ ОТ ОБСТОЯТЕЛЬСТВ</B>
ПРЕДУПРЕЖДЕНИЕ О ЗВУКЕ: Не используйте постоянно. Посетите медицинского специалиста, если замечаете проблемы со слухом.
Присутствует малый шанс остаться глухим. Проявляйте осторожность и сдержанность.
ПРЕДУПРЕЖДЕНИЕ О КОНТУЗИИ: Если предполагаемая или непреднамеренная цель находится слишком близко к месту детонации, возникающий звук 
и вспышка будут сильнее, в результате чего может возникнуть контузия. <B>НЕ ИСПОЛЬЗУЙТЕ ПОСТОЯННО</B>
Инструкция:
1. Выдерните чеку. <B>КАК ТОЛЬКО ЧЕКА ВЫЙДЕТ, ГРАНАТА НЕ МОЖЕТ БЫТЬ ОБЕЗВРЕЖЕНА!</B>
2. Бросьте гранату. <B>НИКОГДА НЕ ДЕРЖИТЕ ВЗВЕДЕННУЮ ГРАНАТУ</B>
3. Граната сдетонирует через 10 секунд после взведения. <B>СОБЛЮДАЙТЕ ОСТОРОЖНОСТь</B>
<B>Никогда не взводите вторую гранату, пока первая не сдетонировала.</B>
Заметка: Использование этого устройства без аутефикации и должной причины
приведет к заслуженному наказанию вплоть до <B>10 лет в тюрьме за 1 использование</B>.
Стандартом задан 3-секундный интервал между взведением и детонацией. Отверткой можно имзенить этот интервал вплоть до 10 секунд.
Торговый знак NanoTrasen Industries- Military Armnaments Division
Это устройство было создано членами NanoTrasen Labs ассоциации Expert Advisor Corporation"}
	name = "упаковка светошумовых (ОПАСНО)"
	labels = list("ОПАСНО")
	icon_state = "flashbang"
	item_state = "syringe_kit"

/obj/item/weapon/storage/emp_kit
	desc = "Коробка с чем-то боевым."
	name = "упаковка ЭМИ-гранат"
	icon_state = "flashbang"
	item_state = "syringe_kit"

/obj/item/weapon/storage/gl_kit
	name = "очки по рецепту"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/handcuff_kit
	name = "запасные наручники"
	icon_state = "handcuff"
	item_state = "syringe_kit"

/obj/item/weapon/storage/id_kit
	name = "запасные ID-карты"
	icon_state = "id"
	item_state = "syringe_kit"

/obj/item/weapon/storage/lglo_kit
	name = "латексные перчатки"
	icon_state = "latex"
	item_state = "syringe_kit"

/obj/item/weapon/storage/injectbox
	name = "инъектор ДНК"
	icon_state = "box"
	item_state = "syringe_kit"

/obj/item/weapon/storage/stma_kit
	name = "стерильная маска"
	icon_state = "mask"
	item_state = "syringe_kit"

/obj/item/weapon/storage/trackimp_kit
	name = "набор имплантов трекинга"
	icon_state = "implant"
	item_state = "syringe_kit"


/obj/item/weapon/storage/daimp_kit
	name = "набор имплантов оповещения о смерти"
	icon_state = "implant"
	item_state = "syringe_kit"


/obj/item/weapon/storage/toolbox
	name = "тулбокс"
	icon = 'icons/obj/storage.dmi'
	icon_state = "red"
	item_state = "toolbox_red"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 10.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 7
	w_class = 4.0

/obj/item/weapon/storage/toolbox/emergency
	name = "экстренный тулбокс"
	icon_state = "red"
	item_state = "toolbox_red"

/obj/item/weapon/storage/toolbox/mechanical
	name = "механический тулбокс"
	icon_state = "blue"
	item_state = "toolbox_blue"

/obj/item/weapon/storage/toolbox/electrical
	name = "электрический тулбокс"
	icon_state = "yellow"
	item_state = "toolbox_yellow"

/obj/item/weapon/storage/bible
	name = "библия"
	icon_state ="bible"
	throw_speed = 1
	throw_range = 5
	w_class = 3.0
	flags = FPRINT | TABLEPASS
	var/mob/affecting = null

/obj/item/weapon/storage/mousetraps
	name = "Pest-B-Gon Mousetraps"
	desc = "WARNING: Keep out of reach of children."
	icon_state = "mousetraps"
	item_state = "syringe_kit"

/obj/item/weapon/storage/donkpocket_kit
	name = "Donk-Pockets"
	desc = "Remember to fully heat prior to serving.  Product will cool if not eaten within seven minutes."
	icon_state = "donk_kit"
	item_state = "syringe_kit"
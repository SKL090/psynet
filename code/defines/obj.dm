/obj
	//var/datum/module/mod		//not used
	var/m_amt = 0	// metal
	var/g_amt = 0	// glass
	var/w_amt = 0	// waster amounts
	var/global/tagcnum = 0
	var/explosionstrength = 0
	var/spawnchance = null 	//If this is defined, this is the percent chance that this object will spawn.  Checked in New().  Intended to be defined on the map, for some randomness in item placement.

	var/list/NetworkNumber = list( )
	var/list/Networks = list( )

	animate_movement = 2

	proc
		handle_internal_lifeform(mob/lifeform_inside_me, breath_request)
			//Return: (NONSTANDARD)
			//		null if object handles breathing logic for lifeform
			//		datum/air_group to tell lifeform to process using that breath return
			//DEFAULT: Take air from turf to give to have mob process
			if(breath_request>0)
				return remove_air(breath_request)
			else
				return null

		initialize()

	New()
		src.tag = "obj[++tagcnum]"
		if(spawnchance)
			if(prob(100-spawnchance))
				del src





/obj/item/policetaperoll
	name = "катушка полицейской ленты"
	desc = "Катушка полицейской ленты, используемной для оцепления мест преступлений от случайных зевак."
	icon = 'icons/policetape.dmi'
	icon_state = "rollstart"
	flags = FPRINT
	var/tapestartx = 0
	var/tapestarty = 0
	var/tapestartz = 0
	var/tapeendx = 0
	var/tapeendy = 0
	var/tapeendz = 0

/obj/item/policetape
	name = "полицейская лента"
	desc = "Полицейская лентаа. Не переходи."
	icon = 'icons/policetape.dmi'
	anchored = 1
	density = 1
	throwpass = 1
	req_access = list(access_security)

/obj/blob
	icon = 'icons/mob/blob.dmi'
	icon_state = "bloba0"
	var/health = 30
	density = 1
	opacity = 0
	anchored = 1

/obj/blob/idle
	name = "НЕЧТО"
	desc = "Оно... живое."
	icon_state = "blobidle0"

/obj/mark
	var/mark = ""
	icon = 'icons/misc/mark.dmi'
	icon_state = "blank"
	anchored = 1
	layer = 99
	mouse_opacity = 0

/obj/admins
	name = "admins"
	var/rank = null
	var/owner = null
	var/state = 1
	//state = 1 for playing : default
	//state = 2 for observing

/obj/bhole
	name = "черная дыра"
	icon = 'icons/obj/objects.dmi'
	desc = "Это, мать его, черная дыра."
	icon_state = "bhole2"
	opacity = 0
	density = 0
	anchored = 1
	var/datum/effects/system/harmless_smoke_spread/smoke



/obj/bedsheetbin
	name = "ящик для белья"
	desc = "Ящик с постельный бельем."
	icon = 'icons/obj/items.dmi'
	icon_state = "bedbin"
	var/amount = 23.0
	anchored = 1.0

/obj/begin
	name = "begin"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "begin"
	anchored = 1.0

/obj/datacore
	name = "datacore"
	var/list/medical = list(  )
	var/list/general = list(  )
	var/list/security = list(  )

/obj/equip_e
	name = "equip e"
	var/mob/source = null
	var/s_loc = null
	var/t_loc = null
	var/obj/item/item = null
	var/place = null

/obj/equip_e/human
	name = "human"
	var/mob/living/carbon/human/target = null

/obj/equip_e/monkey
	name = "monkey"
	var/mob/living/carbon/monkey/target = null

/obj/grille
	desc = "Металлическая деталь с равномерно расположенными сетчатыми отверстиями. Блокирует крупные объекты, но пропускает мелкие предметы, газ или энергетические лучи."
	name = "решетка"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	density = 1
	layer = 2.9
	var/health = 10.0
	var/destroyed = 0.0
	anchored = 1.0
	flags = FPRINT | CONDUCT
	pressure_resistance = 5*ONE_ATMOSPHERE

/obj/item
	name = "item"
	icon = 'icons/obj/items.dmi'
	var/icon_old = null
	var/abstract = 0.0
	var/force = null
	var/item_state = null
	var/damtype = "brute"
	var/throwforce = 10
	var/r_speed = 1.0
	var/health = null
	var/burn_point = null
	var/burning = null
	var/hitsound = null
	var/w_class = 3.0
	var/captured_by_securitron = 0
	flags = FPRINT | TABLEPASS
	pressure_resistance = 50
	var/obj/item/master = null

/obj/item/device
	icon = 'icons/obj/device.dmi'

/obj/item/device/detective_scanner
	name = "сканер"
	desc = "Используется для сканирования информации в духе отпечатков пальца или ДНК."
	icon_state = "forensic0"
	var/amount = 20.0
	var/printing = 0.0
	var/list/stored_fibers = null
	var/stored_name = null
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | USEDELAY

/obj/item/device/antibody_scanner
	name = "сканер"
	desc = "Используется для проверки живых существ на наличие антител."
	icon_state = "antibody"
	w_class = 2.0
	item_state = "electronic"
	flags = FPRINT | TABLEPASS | ONBELT | CONDUCT | USEDELAY


/obj/item/device/flash
	name = "флешка"
	icon_state = "flash"
	var/l_time = 1.0
	var/shots = 5.0
	throwforce = 5
	w_class = 1.0
	throw_speed = 4
	throw_range = 10
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	var/status = 1

/obj/item/device/flashlight
	name = "фонарик"
	desc = "Ручной фонарик для чрезвычайных ситуаций."
	icon_state = "flight0"
	var/on = 0
	w_class = 2
	item_state = "flight"
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	m_amt = 50
	g_amt = 20

/obj/item/device/healthanalyzer
	name = "анализатор здоровья"
	icon_state = "health"
	item_state = "analyzer"
	desc = "Ручной сканер тела, способный определять жизненные показатели человека."
	flags = FPRINT | ONBELT | TABLEPASS | CONDUCT
	throwforce = 3
	w_class = 1.0
	throw_speed = 5
	throw_range = 10
	m_amt = 200

/obj/item/device/igniter
	name = "воспламенитель"
	desc = "Маленькое электронное устройство, способное создать небольшое пламя."
	icon_state = "igniter"
	var/status = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 100
	throwforce = 5
	w_class = 1.0
	throw_speed = 3
	throw_range = 10


/obj/item/device/infra
	name = "инфракрасный луч безопасности"
	desc = "Излучает видимый или невидимый луч и срабатывает при его прерывании."
	icon_state = "infrared0"
	var/obj/beam/i_beam/first = null
	var/state = 0.0
	var/visible = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 150

/obj/item/device/infra_sensor
	name = "инфракрасный сенсор"
	desc = "Проверяет наличие инфракрасных лучей в окрестностях."
	icon_state = "infra_sensor"
	var/passive = 1.0
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"
	m_amt = 150

/obj/item/device/t_scanner
	name = "т-лучевой сканер"
	desc = "Излучатель терагерцового излучения и сканер, используемый для обнаружения объектов под полом, таких как кабели и трубы."
	icon_state = "t-ray0"
	var/on = 0
	flags = FPRINT|ONBELT|TABLEPASS
	w_class = 2
	item_state = "electronic"
	m_amt = 150

/obj/item/device/multitool
	name = "мультитул"
	icon_state = "multitool"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "Это можно использовать для взлома шлюзов или АПЦ без перерезания проводов."
	m_amt = 50
	g_amt = 20

// So far, its functionality is found only in code/game/machinery/doors/airlock.dm
/obj/item/device/hacktool
	name = "инструмент для взлома"
	icon_state = "hacktool"
	flags = FPRINT | TABLEPASS | CONDUCT
	var/in_use = 0
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_range = 15
	throw_speed = 3
	desc = "Предмет сомнительного происхождения, из которого торчат провода и антенны."
	m_amt = 60
	g_amt = 20

/obj/item/device/prox_sensor
	name = "сенсор движения"
	icon_state = "motion0"
	var/state = 0.0
	var/timing = 0.0
	var/time = null
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	item_state = "electronic"
	m_amt = 300


/obj/item/device/timer
	name = "таймер"
	icon_state = "timer0"
	item_state = "electronic"
	var/timing = 0.0
	var/time = null
	flags = FPRINT | TABLEPASS| CONDUCT
	w_class = 2.0
	m_amt = 100


/obj/landmark
	name = "landmark"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0




/*/obj/landmark/ptarget
	name = "portal target"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x2"
	anchored = 1.0
	var/t_id*/

/obj/landmark/derelict
	name = "заброшенный информационный узел"

	nodamage
		icon_state = "blocked"

	noblast
		icon_state = "blocked"

	o2crate
	o2canister
	metal
	glass


/obj/landmark/alterations
	name = "alterations"
	nopath
		invisibility = 101
		name = "Bot No-Path"

/obj/laser
	name = "лазер"
	icon = 'icons/obj/projectiles.dmi'
	var/damage = 0.0
	var/range = 10.0

/obj/lattice
	desc = "Легкая опорная решетка."
	name = "решетка"
	icon = 'icons/obj/structures.dmi'
	icon_state = "lattice"
	density = 0
	anchored = 1.0
	layer = 2.5
	//	flags = 64.0

/obj/list_container
	name = "list container"

/obj/list_container/mobl
	name = "mobl"
	var/master = null

	var/list/container = list(  )

/obj/m_tray
	name = "ячейка морга"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morguet"
	density = 1
	layer = 2.0
	var/obj/morgue/connected = null
	anchored = 1.0

/obj/c_tray
	name = "ячейка крематория"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "cremat"
	density = 1
	layer = 2.0
	var/obj/crematorium/connected = null
	anchored = 1.0

/obj/manifest
	name = "manifest"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"

/obj/morgue
	name = "морг"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "morgue1"
	density = 1
	var/obj/m_tray/connected = null
	anchored = 1.0

/obj/crematorium
	name = "крематорий"
	desc = "Сжигатель людей."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "crema1"
	density = 1
	var/obj/c_tray/connected = null
	anchored = 1.0
	var/cremating = 0
	var/id = 1
	var/locked = 0

/obj/mine
	name = "мина"
	desc = "Лучше держаться подальше."
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/mine/dnascramble
	name = "радиационная мина"
	icon_state = "uglymine"
	triggerproc = "triggerrad"

/obj/mine/plasma
	name = "плазменная мина"
	icon_state = "uglymine"
	triggerproc = "triggerplasma"

/obj/mine/kick
	name = "ударная мина"
	icon_state = "uglymine"
	triggerproc = "triggerkick"

/obj/mine/n2o
	name = "оксидо-нитрогеновая мина"
	icon_state = "uglymine"
	triggerproc = "triggern2o"

/obj/mine/stun
	name = "оглушающая мина"
	icon_state = "uglymine"
	triggerproc = "triggerstun"

/obj/overlay
	name = "overlays"

/obj/projection
	name = "проекция"
	anchored = 1.0

/obj/rack
	name = "стойка"
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	density = 1
	flags = FPRINT
	anchored = 1.0

/obj/screen
	name = "screen"
	icon = 'icons/mob/screen1.dmi'
	layer = 20.0
	var/id = 0.0
	var/obj/master

/obj/screen/close
	name = "close"
	master = null

/obj/screen/grab
	name = "grab"
	master = null

/obj/screen/storage
	name = "storage"
	master = null

/obj/screen/zone_sel
	name = "Зона выбора"
	icon = 'icons/mob/HUD/zone_sel.dmi'
	icon_state = "polovina"
	var/selecting = "chest"
	screen_loc = "EAST+1,NORTH"

/obj/screen/zone_sel/New()
	..()
	var/image/bottom = image("icon" = 'icons/mob/HUD/zone_sel2.dmi', "icon_state" = "polovina2", "layer" = layer - 0.1)
	bottom.pixel_y = -32
	overlays += bottom

/obj/shut_controller
	name = "контроллер штор"
	var/moving = null
	var/list/parts = list(  )

/obj/landmark/start
	name = "start"
	icon = 'icons/mob/screen1.dmi'
	icon_state = "x"
	anchored = 1.0

/obj/stool
	name = "табурет"
	icon = 'icons/obj/objects.dmi'
	icon_state = "stool"
	flags = FPRINT
	anchored = 1.0
	pressure_resistance = 3*ONE_ATMOSPHERE

/obj/stool/barstool
	name = "барный стул"
	icon_state = "barstool"

/obj/stool/bed
	name = "кровать"
	desc = "На ней лежат."
	icon_state = "bed"
	anchored = 1.0
	var/list/buckled_mobs = list(  )

/obj/stool/bed/prison
	name = "тюремная койка"
	desc = "Кровать выглядит не такой комфортной, какой она должна быть, чтобы ты остался лежать на ней весь оставшийся срок."

/obj/stool/chair
	name = "стул"
	desc = "Ты на нём сидишь. насильно или по собственному желанию."
	icon_state = "chair"
	var/status = 0.0
	anchored = 1.0
	var/list/buckled_mobs = list(  )

/obj/stool/chair/e_chair
	name = "электрический стул"
	icon_state = "e_chair0"
	var/atom/movable/overlay/overl = null
	var/on = 0.0
	var/obj/item/assembly/shock_kit/part1 = null
	var/last_time = 1.0

/obj/stool/chair/comfy
	name = "кресло"
	desc = "Выглядит очень удобно."

/obj/stool/chair/comfy/brown
	icon_state = "comfychair_brown"

/obj/stool/chair/comfy/beige
	icon_state = "comfychair_beige"

/obj/stool/chair/comfy/teal
	icon_state = "comfychair_teal"

/obj/stool/chair/comfy/black
	icon_state = "comfychair_black"

/obj/stool/chair/comfy/lime
	icon_state = "comfychair_lime"

/obj/table
	name = "стол"
	icon = 'icons/obj/structures.dmi'
	icon_state = "table"
	density = 1
	anchored = 1.0
	flags = FPRINT | NOSPLASH

/obj/table/reinforced
	name = "крепкий стол"
	icon_state = "reinf_table"
	var/status = 2

/obj/table/woodentable
	name = "деревянный стол"
	icon_state = "woodentable"

/obj/mopbucket
	desc = "Наполни его водой."
	name = "комплексное ведро"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = 1
	flags = FPRINT
	pressure_resistance = ONE_ATMOSPHERE
	flags = FPRINT | TABLEPASS | OPENCONTAINER

/obj/kitchenspike
	name = "мясной крюк"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "spike"
	desc = "Крюк для насаживания умертвленных кусков мяса."
	density = 1
	anchored = 1
	var/meat = 0
	var/occupied = 0

/obj/displaycase
	name = "витрина"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "glassbox1"
	desc = "Витрина для самых выделяющихся объектов."
	density = 1
	anchored = 1
	var/health = 30
	var/occupied = 1
	var/destroyed = 0

obj/item/brain
	name = "мозги"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "brain2"
	flags = TABLEPASS
	force = 1.0
	w_class = 1.0
	throwforce = 1.0
	throw_speed = 3
	throw_range = 5

	var/mob/living/carbon/human/owner = null

/obj/item/brain/New()
	..()
	spawn(5)
		if(src.owner)
			src.name = "мозги [src.owner]"

/obj/noticeboard
	name = "доска заметок"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "nboard00"
	flags = FPRINT
	desc = "Доска для прикрепления важных уведомлений и замечаний."
	density = 0
	anchored = 1
	var/notices = 0

/obj/deskclutter
	name = "мусор"
	icon = 'icons/obj/items.dmi'
	icon_state = "deskclutter"
	desc = "Куча бесполезных предметов скопилась здесь за многие годы..."
	anchored = 1



/obj/item/mouse_drag_pointer = MOUSE_ACTIVE_POINTER


/obj/item/weapon/ore
	name = "камень"
	icon = 'icons/obj/rubble.dmi'
	icon_state = "ore"
	var/amt = 1
	var/cook = 0
	var/cook_temp = 1000
	var/cook_time = 30
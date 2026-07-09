/obj/closet
	desc = "Это шкаф! В нём можно скрыться самостоятельно или хранить разные вещи."
	name = "шкаф"
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	var/icon_closed = "closed"
	var/icon_opened = "open"
	var/bang_time = 0
	var/opened = 0
	var/welded = 0
	flags = FPRINT | NOSPLASH



/obj/closet/portal
	desc = "Это шкаф! В нём можно скрыться самостоятельно или хранить разные вещи."
	name = "шкаф"
	icon = 'icons/obj/closet.dmi'
	icon_state = "closed"
	density = 1
	anchored = 1
	var/id
	var/t_id
	var/locked = 1
	var/turf/target = null
	var/obj/closet/portal/link = null
	req_access = list(access_captain)
	flags = FPRINT


/obj/spresent
	desc = "Это-о-о-о... подарок?"
	name = "странный подарок"
	icon = 'icons/obj/items.dmi'
	icon_state = "strangepresent"
	density = 1
	anchored = 0

/obj/closet/gmcloset
	desc = "Болшой, но весьма мобильный шкаф с формальной одеждой."
	name = "формальный шкаф"

/obj/closet/emcloset
	desc = "Вместительный (но мобильный) шкаф. Поставляется с противогазом и кислородным баллоном на случай чрезвычайных ситуаций."
	name = "экстренный шкафчик"
	icon_state = "emergency"
	icon_closed = "emergency"
	icon_opened = "emergencyopen"

/obj/closet/jcloset
	desc = "Громоздкий (но мобильный) шкаф. В комплекте одежда уборщика и средства защиты от биологического оружия."
	name = "шкаф с био-принадлежностями"

/obj/closet/lawcloset
	desc = "Громоздкий (но мобильный) шкаф. В комплект входят одежда и аксессуары для юристов."
	name = "юридический шкаф"

/obj/closet/coffin
	desc = "Нечто для погребения усопших."
	name = "гроб"
	icon_state = "coffin"
	icon_closed = "coffin"
	icon_opened = "coffin_open"

/obj/closet/l3closet
	desc = "Содержит внутри био-хим костюм третьего класса защиты."
	name = "био-костюм 3-го уровня"
	icon_state = "bio"
	icon_closed = "bio"
	icon_opened = "bioopen"

/obj/closet/syndicate
	desc = "Подготовительный шкаф синдиката."
	name = "шкаф с вооружением"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/closet/syndicate/personal
	desc = "Шкаф с подготовленным снаряжением."

/obj/closet/syndicate/nuclear
	desc = "Шкаф для ядерной подготовки."

/obj/closet/thunderdome
	desc = "Всё, что вам нужно!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	desc = "Thunderdome closet."
	anchored = 1

/obj/closet/thunderdome/tdred
	desc = "Всё, что вам нужно!"
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"
	desc = "Thunderdome closet."

/obj/closet/thunderdome/tdgreen
	desc = "Всё, что вам нужно!"
	icon_state = "syndicate1"
	icon_closed = "syndicate1"
	icon_opened = "syndicate1open"
	desc = "Thunderdome closet."

/obj/closet/malf/suits
	desc = "Шкаф для снаряжения."
	icon_state = "syndicate"
	icon_closed = "syndicate"
	icon_opened = "syndicateopen"

/obj/closet/wardrobe
	desc = "Вместительный (но мобильный) гардеробный шкаф. Внутри 6 комплектов одежды."
	name = "шкаф"
	icon_state = "blue"
	icon_closed = "blue"

/obj/closet/wardrobe/black
	name = "черный шкаф"
	icon_state = "black"
	icon_closed = "black"

/obj/closet/wardrobe/Counselor_black
	name = "гардероб консультанта"
	icon_state = "black"
	icon_closed = "black"

/obj/closet/wardrobe/green
	name = "зеленый шкаф"
	icon_state = "green"
	icon_closed = "green"

/obj/closet/wardrobe/mixed
	name = "гардероб"
	icon_state = "mixed"
	icon_closed = "mixed"

/obj/closet/wardrobe/orange
	name = "шкаф заключенного"
	icon_state = "orange"
	icon_closed = "orange"

/obj/closet/wardrobe/pink
	name = "розовый шкаф"
	icon_state = "pink"
	icon_closed = "pink"

/obj/closet/wardrobe/quartermasters
	name = "шкаф завхоза"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/closet/wardrobe/red
	name = "красный шкаф"
	icon_state = "red"
	icon_closed = "red"

/obj/closet/wardrobe/forensics_red
	name = "судмедицинский шкаф"
	icon_state = "red"
	icon_closed = "red"


/obj/closet/wardrobe/white
	name = "медицинский шкаф"
	icon_state = "white"
	icon_closed = "white"

/obj/closet/wardrobe/chemistry_white
	name = "химический шкаф"
	icon_state = "white"
	icon_closed = "white"

/obj/closet/wardrobe/toxins_white
	name = "шкаф токсинов"
	icon_state = "white"
	icon_closed = "white"

/obj/closet/wardrobe/robotics_white
	name = "робототехнический шкаф"
	icon_state = "white"
	icon_closed = "white"

/obj/closet/wardrobe/genetics_white
	name = "генетический шкаф"
	icon_state = "white"
	icon_closed = "white"


/obj/closet/wardrobe/yellow
	name = "желтый шкаф"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/closet/wardrobe/engineering_yellow
	name = "инженерный шкаф"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/closet/wardrobe/atmospherics_yellow
	name = "инженерный шкаф"
	icon_state = "yellow"
	icon_closed = "yellow"

/obj/closet/wardrobe/hydroponics
	name = "гидропонический шкаф"
	icon_state = "green"
	icon_closed = "green"

/obj/closet/wardrobe/grey
	name = "серый шкаф"
	icon_state = "grey"
	icon_closed = "grey"

/obj/closet/wardrobe/bar
	name = "барный шкаф"
	icon_state = "black"
	icon_closed = "black"


/obj/secure_closet
	desc = "Неподвижный шкаф с замком, открывающимся по карте."
	name = "защищенный шкаф"
	icon = 'icons/obj/closet.dmi'
	icon_state = "secure1"
	density = 1
	flags = FPRINT | NOSPLASH
	var/opened = 0
	var/locked = 1
	var/bang_time = 0
	var/broken = 0
	var/large = 1
	var/icon_closed = "secure"
	var/icon_locked = "secure1"
	var/icon_opened = "secureopen"
	var/icon_broken = "securebroken"
	var/icon_off = "secureoff"

/obj/secure_closet/courtroom
	name = "судебный шкаф"
	req_access = list(access_heads)

/obj/secure_closet/animal
	name = "животный контроль"
	req_access = list(access_medical)

/obj/secure_closet/brig
	name = "шкафчик брига"
	req_access = list(access_brig)
	var/id = null

/obj/secure_closet/highsec
	name = "шкаф главы персонала"
	req_access = list(access_heads)

/obj/secure_closet/hos
	name = "шкаф главы СБ"
	req_access = list(access_heads)

/obj/secure_closet/captains
	name = "шкаф капитана"
	req_access = list(access_captain)


/obj/secure_closet/medical	//Empty medical closet
	name = "медицинский шкафчик"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)

/obj/secure_closet/medical1
	name = "медицинский шкафчик"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)
/obj/secure_closet/medical3
	name = "холодильник с кровью"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)
/obj/secure_closet/chemical
	name = "хим-шкафчик"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)

/obj/secure_closet/medical2
	name = "анестетик"
	icon_state = "medical1"
	icon_closed = "medical"
	icon_locked = "medical1"
	icon_opened = "medicalopen"
	icon_broken = "medicalbroken"
	icon_off = "medical1"
	req_access = list(access_medical)

/obj/secure_closet/personal
	desc = "Владельцем является тот, кто первым проведет картой по считывателю."
	name = "персональный шкафчик"


/obj/secure_closet/security1
	name = "оборудование СБ"
	req_access = list(access_security)

/obj/secure_closet/security2
	name = "криминалистический шкафчик"
	req_access = list(access_forensics_lockers)

/obj/secure_closet/scientist
	name = "шкаф ученого"

	req_access = list(access_tox_storage)
/obj/secure_closet/chemtoxin
	name = "хим-шкафчик"

	req_access = list(access_medical)
/obj/secure_closet/bar
	name = "бухало"
	req_access = list(access_bar)

/obj/secure_closet/kitchen
	name = "кухонный шкаф"
	req_access = list(access_kitchen)

/obj/secure_closet/meat
	name = "мясной шкафчик"

/obj/secure_closet/fridge
	name = "холодильник"
	icon_state = "fridge1"
	icon_closed = "fridge"
	icon_locked = "fridge1"
	icon_opened = "fridgeopen"
	icon_broken = "fridgebroken"
	icon_off = "fridge1"

/obj/secure_closet/wall
	name = "настенный шкафчик"
	req_access = list(access_security)
	icon_state = "wall-locker1"
	density = 1
	icon_closed = "wall-locker"
	icon_locked = "wall-locker1"
	icon_opened = "wall-lockeropen"
	icon_broken = "wall-lockerbroken"
	icon_off = "wall-lockeroff"

	//too small to put a man in
	large = 0
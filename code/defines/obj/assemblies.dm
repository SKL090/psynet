/obj/item/assembly
	name = "конструктор"
	icon = 'icons/obj/assemblies.dmi'
	item_state = "assembly"
	var/status = 0.0
	throwforce = 10
	w_class = 3.0
	throw_speed = 4
	throw_range = 10

/obj/item/assembly/a_i_a
	name = "устройство а-б-п"
	desc = "Устройство из анализатора здоровья, брони и поджигателя."
	icon_state = "armor-igniter-analyzer"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/clothing/suit/armor/vest/part3 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/m_i_ptank
	desc = "Очень сложный электрический узел, включающий воспламенитель и датчик приближения, установленный на верхней части плазменного резервуара."
	name = "устройство m-p-i"
	icon_state = "prox-igniter-tank0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/prox_ignite
	name = "блок бесконтактного воспламенителя"
	desc = "Устройство зажигания с активацией при приближении."
	icon_state = "prox-igniter0"
	var/obj/item/device/prox_sensor/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/r_i_ptank
	desc = "Очень сложный электрический узел зажигания и сигнализации, установленный на верхней части плазменного резервуара."
	name = "радиоуправляемый блок бесконтактного воспламенителя"
	icon_state = "radio-igniter-tank"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/anal_ignite
	name = "узел анализатора состояния и поджигателя"
	desc = "Устройство зажигания анализатора состояния."
	icon_state = "timer-igniter0"
	var/obj/item/device/healthanalyzer/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	item_state = "electronic"

/obj/item/assembly/time_ignite
	name = "зажигатель по таймеру"
	desc = "Устройство зажигания, активируемое таймером."
	icon_state = "timer-igniter0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/init = 0
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/t_i_ptank
	desc = "Очень сложный узел зажигания и таймера, установленный на верхней части плазменного резервуара."
	name = "сборка т-з-п"
	icon_state = "timer-igniter-tank0"
	var/obj/item/device/timer/part1 = null
	var/obj/item/device/igniter/part2 = null
	var/obj/item/weapon/tank/plasma/part3 = null
	status = 0.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_ignite
	name = "радио-воспламеняемый узел"
	desc = "Радиоактивируемый воспламенитель."
	icon_state = "radio-igniter"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/igniter/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_infra
	name = "сигнальный инфракрасный модуль"
	desc = "An infrared-activated radio signaller"
	icon_state = "infrared-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/infra/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_prox
	name = "блок сигнального датчика"
	desc = "Радиосигнализатор, активируемый при приближении."
	icon_state = "prox-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/prox_sensor/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/rad_time
	name = "сигнальный таймер"
	desc = "Радиосигнализатор, активируемый таймером обратного отсчета."
	icon_state = "timer-radio0"
	var/obj/item/device/radio/signaler/part1 = null
	var/obj/item/device/timer/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/shock_kit
	name = "шоковый набор"
	icon_state = "shock_kit"
	var/obj/item/clothing/head/helmet/part1 = null
	var/obj/item/device/radio/electropack/part2 = null
	status = 0.0
	w_class = 5.0
	flags = FPRINT | TABLEPASS| CONDUCT

/obj/item/assembly/weld_rod
	desc = "Сварка с присоединенными металлическими стержнями."
	name = "улучшенная сварка"
	icon_state = "welder-rods"
	item_state = "welder"
	var/obj/item/weapon/weldingtool/part1 = null
	var/obj/item/weapon/rods/part2 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0

/obj/item/assembly/w_r_ignite
	desc = "Комбинация поджигателя и сварочного аппарата."
	name = "ручная сварка"
	icon_state = "welder-rods-igniter"
	item_state = "welder"
	var/obj/item/weapon/weldingtool/part1 = null
	var/obj/item/weapon/rods/part2 = null
	var/obj/item/device/igniter/part3 = null
	status = null
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 3.0
	throwforce = 5.0
	throw_speed = 1
	throw_range = 5
	w_class = 2.0
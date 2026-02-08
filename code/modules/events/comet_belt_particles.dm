
/particles/comet_stars
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "star"
	width = 800
	height = 650
	count = 150
	spawning = 0
	lifespan = 130
	fade = 50
	fadein = 5
	scale = generator("num", 0.6, 1.5)
	position = generator("box", list(380, -300, 0), list(520, 300, 0))
	velocity = generator("vector", list(-6, -2, 0), list(-3, -0.5, 0))
	drift = generator("vector", list(-0.05, -0.03, 0), list(0.05, 0.03, 0))
	color = "#70B8E8"

/particles/comet_dust
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "ion"
	width = 640
	height = 480
	count = 50
	spawning = 5
	lifespan = 40
	fade = 20
	fadein = 10
	grow = -0.01
	scale = generator("num", 0.4, 1.2)
	position = generator("box", list(-300, -230, 0), list(300, 230, 0))
	velocity = generator("vector", list(-0.8, -0.3, 0), list(0.3, 0.5, 0))
	drift = generator("vector", list(-0.1, -0.05, 0), list(0.1, 0.05, 0))
	color = "#BBCCEE"

/particles/comet_belt_stream
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "dust"
	width = 700
	height = 550
	count = 100
	spawning = 5
	lifespan = 70
	fade = 20
	fadein = 10
	grow = -0.005
	scale = generator("num", 0.3, 0.9)
	// Пояс
	position = generator("box", list(380, -80, 0), list(500, 80, 0))
	velocity = generator("vector", list(-3.5, -1.2, 0), list(-1.8, -0.3, 0))
	drift = generator("vector", list(-0.03, -0.02, 0), list(0.03, 0.02, 0))
	color = "#99AACC"

// ═══════════════════ ЭКРАННЫЕ ОВЕРЛЕИ ═══════════════════

/atom/movable/screen/comet_overlay
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "star"
	alpha = 0
	screen_loc = "CENTER,CENTER"
	plane = PLANE_SPACE_PARALLAX
	layer = 10
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM

/atom/movable/screen/comet_overlay/Initialize(mapload)
	. = ..()
	particles = new /particles/comet_stars

/atom/movable/screen/comet_overlay/Destroy()
	QDEL_NULL(particles)
	return ..()

/atom/movable/screen/comet_overlay/proc/fade_in(time = 20)
	animate(src, alpha = 255, time = time)

/atom/movable/screen/comet_overlay/proc/fade_out(time = 60)
	if(particles)
		particles.spawning = 0
	animate(src, alpha = 0, time = time)

/atom/movable/screen/comet_dust_overlay
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "ion"
	alpha = 0
	screen_loc = "CENTER,CENTER"
	plane = PLANE_SPACE_PARALLAX
	layer = 40
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM

/atom/movable/screen/comet_dust_overlay/Initialize(mapload)
	. = ..()
	particles = new /particles/comet_dust

/atom/movable/screen/comet_dust_overlay/Destroy()
	QDEL_NULL(particles)
	return ..()

/atom/movable/screen/comet_dust_overlay/proc/fade_in(time = 30)
	animate(src, alpha = 240, time = time)

/atom/movable/screen/comet_dust_overlay/proc/fade_out(time = 80)
	if(particles)
		particles.spawning = 0
	animate(src, alpha = 0, time = time)

// ═══════ ПЫЛЕВОЙ ПОЯС (за планетой, задний план) ═══════

/atom/movable/screen/comet_belt_stream_overlay
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "dust"
	alpha = 0
	screen_loc = "CENTER,CENTER"
	plane = PLANE_SPACE_PARALLAX
	layer = 40
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM

/atom/movable/screen/comet_belt_stream_overlay/Initialize(mapload)
	. = ..()
	particles = new /particles/comet_belt_stream

/atom/movable/screen/comet_belt_stream_overlay/Destroy()
	QDEL_NULL(particles)
	return ..()

/atom/movable/screen/comet_belt_stream_overlay/proc/fade_in(time = 40)
	animate(src, alpha = 200, time = time)

/atom/movable/screen/comet_belt_stream_overlay/proc/fade_out(time = 80)
	if(particles)
		particles.spawning = 0
	animate(src, alpha = 0, time = time)

/atom/movable/screen/comet_flash
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "flash"
	alpha = 0
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	plane = PLANE_SPACE_PARALLAX
	layer = 45
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	color = "#FFFFEE"

/atom/movable/screen/comet_flash/proc/do_flash()
	animate(src, alpha = 200, time = 2)
	animate(alpha = 180, time = 8)
	animate(alpha = 0, time = 30, easing = EASE_OUT)

// ═══════ ПОДСВЕТКА КОСМОСА  ═══════

/atom/movable/screen/comet_space_glow
	icon = 'icons/mob/screen_gen.dmi'
	icon_state = "flash"
	alpha = 0
	screen_loc = "WEST,SOUTH to EAST,NORTH"
	plane = PLANE_SPACE_PARALLAX
	layer = 5
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	color = "#000000"

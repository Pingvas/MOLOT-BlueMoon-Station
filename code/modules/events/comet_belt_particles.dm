
/particles/comet_stars
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "star"
	width = 700
	height = 550
	count = 150
	spawning = 0
	lifespan = 80
	fade = 20
	fadein = 3
	scale = generator("num", 0.6, 1.5)
	position = generator("box", list(350, -280, 0), list(500, 280, 0))
	velocity = generator("vector", list(-8, -2.5, 0), list(-4, -0.8, 0))
	drift = generator("vector", list(-0.05, -0.03, 0), list(0.05, 0.03, 0))
	color = "#DDEEFF"

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

// ═══════════════════ ЭКРАННЫЕ ОВЕРЛЕИ ═══════════════════

/atom/movable/screen/comet_overlay
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "star"
	alpha = 0
	screen_loc = "CENTER,CENTER"
	plane = PLANE_SPACE_PARALLAX
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

/atom/movable/screen/comet_flash
	icon = 'modular_bluemoon/icons/misc/ion.dmi'
	icon_state = "ion"
	alpha = 0
	screen_loc = "CENTER,CENTER"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	appearance_flags = PIXEL_SCALE | RESET_TRANSFORM
	color = "#FFFFFF"
	transform = matrix(20, 0, 0, 0, 20, 0)

/atom/movable/screen/comet_flash/proc/do_flash()
	animate(src, alpha = 255, time = 1)
	animate(alpha = 255, time = 5)
	animate(alpha = 0, time = 25, easing = EASE_OUT)

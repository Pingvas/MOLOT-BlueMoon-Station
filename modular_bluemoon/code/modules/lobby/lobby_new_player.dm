/mob/dead/new_player
	var/bm_lobby_ready = FALSE
	var/bm_bg_slot = 0
	COOLDOWN_DECLARE(bm_ready_cd)
	var/bm_lobby_music_path = ""
	var/bm_lobby_track_name = ""

/mob/dead/new_player/Login()
	. = ..()
	bm_show_lobby()

/mob/dead/new_player/proc/bm_show_lobby()
	if(!client)
		return
	if(spawning || new_character)
		return

	winset(client, "map", "is-visible=false")
	winset(client, "status_bar", "is-visible=false")
	winset(client, "bm_lobby_browser", "is-disabled=false;is-visible=false")
	var/datum/asset/simple/bm_lobby/lobby_asset = get_asset_datum(/datum/asset/simple/bm_lobby)
	lobby_asset.send(src)

	if(!SStitle_bm?.initialized && (!SSticker || SSticker.current_state <= GAME_STATE_STARTUP))
		if(fexists(BM_LOBBY_LOADING_GIF))
			src << browse(fcopy_rsc(BM_LOBBY_LOADING_GIF), "file=loading_screen.gif;display=0")
		src << browse(_bm_build_loading_stub(), "window=bm_lobby_browser")
		winset(client, "bm_lobby_browser", "is-visible=true")
		return

	var/img_to_send
	if(SStitle_bm?.initialized)
		var/show_nsfw = client?.prefs?.bm_lobby_show_nsfw || FALSE
		img_to_send = SStitle_bm.get_image_for_player(show_nsfw)
	else
		if(fexists(BM_LOBBY_LOADING_GIF))
			img_to_send = fcopy_rsc(BM_LOBBY_LOADING_GIF)
	if(img_to_send)
		src << browse(img_to_send, "file=loading_screen.gif;display=0")
	src << browse(_bm_build_html(), "window=bm_lobby_browser")
	winset(client, "bm_lobby_browser", "is-visible=true")

/mob/dead/new_player/proc/bm_update_lobby_html()
	if(!client)
		return

	var/img_to_send
	if(SStitle_bm?.initialized)
		var/show_nsfw = client?.prefs?.bm_lobby_show_nsfw || FALSE
		img_to_send = SStitle_bm.get_image_for_player(show_nsfw)
	else
		if(fexists(BM_LOBBY_LOADING_GIF))
			img_to_send = fcopy_rsc(BM_LOBBY_LOADING_GIF)
	if(img_to_send)
		src << browse(img_to_send, "file=loading_screen.gif;display=0")
	src << browse(_bm_build_html(), "window=bm_lobby_browser")

/mob/dead/new_player/proc/bm_hide_lobby()
	if(!client)
		return
	bm_lobby_ready = FALSE
	winset(client, "bm_lobby_browser", "is-disabled=true;is-visible=false")
	winset(client, "map", "is-visible=true")
	client << browse(null, "window=bm_lobby_browser")
	winset(client, "status_bar", "is-visible=true")

/mob/dead/new_player/proc/bm_push_background()
	if(!client || !bm_lobby_ready)
		return
	if(SStitle_bm?.current_video_payload)
		client << output(SStitle_bm.current_video_payload, "bm_lobby_browser:bm_set_background")
		return
	var/show_nsfw = client.prefs?.bm_lobby_show_nsfw || FALSE
	var/img_to_send = SStitle_bm?.get_image_for_player(show_nsfw)
	if(!img_to_send)
		return
	bm_bg_slot = bm_bg_slot ? 0 : 1
	var/filename = "bm_bg_[bm_bg_slot].gif"
	src << browse(img_to_send, "file=[filename];display=0")
	client << output(filename, "bm_lobby_browser:bm_set_background")

/mob/dead/new_player/proc/bm_push_player_count()
	if(!client || !bm_lobby_ready)
		return
	SStitle_bm?.push_player_count_to(src)

/mob/dead/new_player/proc/_bm_build_loading_stub()
	return {"<!DOCTYPE html><html><head><meta charset='UTF-8'>
<style>
*{box-sizing:border-box;margin:0;padding:0;}
body,html{width:100%;height:100%;overflow:hidden;background:#000;font-family:'Courier New',monospace;color:#4af;}
.bg{position:fixed;top:0;left:0;width:100%;height:100%;object-fit:cover;z-index:0;}
.overlay{position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,10,0.6);z-index:1;}
.wrap{position:fixed;top:0;left:0;width:100%;height:100%;z-index:2;display:flex;flex-direction:column;align-items:center;}
.top{flex:1;display:flex;flex-direction:column;align-items:center;justify-content:center;padding-bottom:6vmin;}
.title{font-size:clamp(18px,4.5vmin,42px);letter-spacing:6px;text-shadow:0 0 18px rgba(80,180,255,0.9);margin-bottom:1.2vmin;}
.sub{font-size:clamp(9px,1.6vmin,15px);letter-spacing:3px;color:rgba(80,140,220,0.7);}
.bottom{width:100%;padding:0 8vmin 4vmin;}
.bar-label{font-size:clamp(8px,1.2vmin,12px);letter-spacing:2px;color:rgba(80,140,220,0.55);margin-bottom:1.2vmin;}
.bar-track{width:100%;height:3px;background:rgba(40,100,255,0.12);border-radius:2px;overflow:hidden;}
.bar-fill{height:100%;position:relative;}
.bar-fill::before{content:'';position:absolute;top:0;bottom:0;width:40%;left:0;background:linear-gradient(90deg,transparent,#4af,transparent);animation:bm-ray 1.6s ease-in-out infinite;}
.bar-fill::after{content:'';position:absolute;top:0;bottom:0;width:20%;left:0;background:linear-gradient(90deg,transparent,#adf,transparent);animation:bm-ray 1.6s ease-in-out 0.5s infinite;}
@keyframes bm-ray{from{transform:translateX(-100%)}to{transform:translateX(350%)}}
</style></head>
<body>
<img class='bg' src='loading_screen.gif' alt=''>
<div class='overlay'></div>
<div class='wrap'>
  <div class='top'>
    <div class='title'>BLUEMOON STATION</div>
    <div class='sub'>SPACE STATION 13</div>
  </div>
  <div class='bottom'>
    <div class='bar-label'>LOADING<span id='d'></span></div>
    <div class='bar-track'><div class='bar-fill' id='bar'></div></div>
  </div>
</div>
<script>
var _i=0;setInterval(function(){var s=_i%4;document.getElementById('d').textContent=s===1?' .':s===2?'..':s===3?'...':'';_i++;},400);
</script>
</body></html>"}

/mob/dead/new_player/proc/_bm_build_html()
	var/R = REF(src)
	var/list/parts = list()

	parts += SStitle_bm?.lobby_html || BM_DEFAULT_LOBBY_HTML_PREAMBLE

	// статические части (bg, overlay, toasts, toggle-btn) из кеша подсистемы
	if(SStitle_bm?.cached_static_html != "")
		parts += SStitle_bm.cached_static_html
	else
		parts += {"<img id="bm-bg" class="bg" src="loading_screen.gif" alt=\"\">"}
		parts += {"<div id=\"bm-overlay\"></div>"}
		parts += {"<div id=\"bm-toasts\"></div>"}
		parts += {"<div id=\"bm-toggle-btn\" onclick=\"bmToggleSidebar()\" title=\"Свернуть/развернуть меню\">&#9664;</div>"}
		parts += {"<div id=\"bm-terminal\"></div>"}
		parts += {"<div id=\"bm-progress-wrap\"><div id=\"bm-progress-bar\"></div></div>"}

	// динамическая часть
	parts += {"<div id=\"bm-sidebar\">"}
	parts += {"<div id=\"bm-logo\">
  <div class=\"bm-title-text\">BLUEMOON<br>STATION</div>
  <div class=\"bm-subtitle-text\">SPACE STATION 13</div>
  <button id=\"bm-settings-btn\" onclick=\"bmToggleSettings()\">&#9881; НАСТРОЙКИ</button>
  <div id=\"bm-settings-panel\">
    <div class=\"bm-settings-title\">НАСТРОЙКИ ЛОББИ</div>
    <a class="bm-settings-row" href='?src=[R];bm_lobby_action=toggle_nsfw' style="cursor:pointer">
      <span class="bm-s-label">NSFW КОНТЕНТ</span>
      <span class="bm-s-value" id="bm-s-nsfw">ВЫКЛ</span>
    </a>
  </div>
  <div id=\"bm-player-count\">&#183; &#183; &#183;</div>
</div>"}
	parts += {"<div id=\"bm-menu\">"}
	parts += _bm_build_menu()
	parts += "</div>"

	var/char_name = html_encode(uppertext(client?.prefs?.real_name || ""))
	parts += {"<div id=\"bm-footer\">
  <div id=\"bm-char-name\">[char_name ? char_name : "\u2014 \u2014 \u2014"]</div>
  <div id=\"bm-count-row\">
    <span class=\"bm-count-lbl\">ОНЛАЙН&nbsp;<span class=\"bm-count-val\" id=\"bm-count-online\">&#8212;</span></span>
    <span id=\"bm-count-ready-wrap\" class=\"bm-count-lbl\">ГОТОВЫ&nbsp;<span class=\"bm-count-val\" id=\"bm-count-ready\">&#8212;</span></span>
  </div>
</div>"}
	parts += {"<div id=\"bm-audio-bar\">
  <div id=\"bm-audio-row\">
    <button class=\"bm-audio-btn\" id=\"bm-btn-play\" onclick=\"bmAudioPlay()\">&#9654;</button>
    <div id=\"bm-audio-track\">нет трека</div>
    <button class=\"bm-audio-btn\" id=\"bm-btn-mute\" onclick=\"bmAudioMute()\">&#128264;</button>
    <input type=\"range\" id=\"bm-audio-vol\" min=\"0\" max=\"100\" value=\"35\" oninput=\"bmAudioVolume(this.value)\" onchange=\"bmAudioVolume(this.value)\" title=\"Громкость\">
  </div>
  <div id=\"bm-video-row\" style=\"display:none\">
    <button class=\"bm-audio-btn\" id=\"bm-btn-video-mute\" onclick=\"bmVideoMute()\">&#128263;</button>
    <div id=\"bm-video-label\">ВИДЕО</div>
    <input type=\"range\" id=\"bm-video-vol\" min=\"0\" max=\"100\" value=\"0\" oninput=\"bmVideoVolume(this.value)\" onchange=\"bmVideoVolume(this.value)\" title=\"Громкость видео\">
  </div>
</div>
<audio id=\"bm-audio\" loop></audio></div>"}

	var/show_nsfw = client?.prefs?.bm_lobby_show_nsfw || FALSE
	var/notice_js = ""
	if(SStitle_bm?.current_notice)
		var/notice_text = SStitle_bm.current_notice
		notice_text = replacetext(notice_text, "\\", "\\\\")
		notice_text = replacetext(notice_text, "'", "\\'")
		notice_text = replacetext(notice_text, "\n", "\\n")
		notice_js = "bm_show_notice('[notice_text]');"
	var/admin_js = "bm_set_admin([client?.holder ? 1 : 0]);"

	var/datum/asset/simple/bm_lobby/lobby_asset = get_asset_datum(/datum/asset/simple/bm_lobby)
	var/js_url = lobby_asset.get_url_mappings()["bm_lobby.js"]
	parts += {"<script src=\"[js_url]\"></script>"}
	parts += {"<script>
	window._BM_SRC='[R]';
	bm_update_nsfw_indicator([show_nsfw ? 1 : 0]);
	[admin_js]
	[notice_js]
	</script>"}

	parts += {"<script>
var __bm_pr=function(){if(window.__bm_page_ready_sent)return;window.__bm_page_ready_sent=true;location.href='?src=[R];bm_lobby_action=page_ready';};
setTimeout(__bm_pr,0);
window.onload=__bm_pr;
</script>"}

	parts += "</body></html>"
	return parts.Join("")

/mob/dead/new_player/proc/_bm_build_menu()
	var/list/parts = list()
	var/R = REF(src)

	if(!SSticker || SSticker.current_state <= GAME_STATE_PREGAME)
		parts += {"<a id="bm-btn-ready" class="bm-btn" href='?src=[R];bm_lobby_action=toggle_ready'>"}
		parts += ready ? {"<span class='bm-checked'>☑</span> ГОТОВНОСТЬ"} : {"<span class='bm-unchecked'>☒</span> ГОТОВНОСТЬ"}
		parts += "</a>"
		if(client?.holder)
			parts += {"<a class="bm-btn bm-btn-admin" href='?src=[R];bm_lobby_action=start_game'>⚡ СТАРТ ИГРЫ</a>"}
	else
		parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=late_join'>ВОЙТИ В ИГРУ</a>"}
		parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=view_manifest'>СПИСОК ЭКИПАЖА</a>"}
		parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=character_directory'>БИБЛИОТЕКА ПЕРСОНАЖЕЙ</a>"}

	parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=observe'>БЫТЬ НАБЛЮДАТЕЛЕМ</a>"}

	parts += "<div class='bm-divider'></div>"

	parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=character_setup'>НАСТРОЙКА ПЕРСОНАЖА</a>"}
	parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=game_options'>ПАРАМЕТРЫ ИГРЫ</a>"}

	var/is_antag_opted = !(client?.prefs?.toggles & NO_ANTAG)
	parts += {"<a id="bm-btn-antag" class="bm-btn" href='?src=[R];bm_lobby_action=toggle_antag'>"}
	parts += is_antag_opted ? {"<span class='bm-checked'>☑</span> РОЛЬ АНТАГОНИСТА"} : {"<span class='bm-unchecked'>☒</span> РОЛЬ АНТАГОНИСТА"}
	parts += "</a>"

	if(length(GLOB.lobby_station_traits))
		parts += {"<a class="bm-btn" href='?src=[R];bm_lobby_action=job_traits'>ОСОБЕННОСТИ РАБОТЫ</a>"}

	if(!is_guest_key(src.key))
		var/poll_html = _bm_build_polls_button()
		if(poll_html)
			parts += poll_html

	return parts.Join("")

/mob/dead/new_player/proc/_bm_build_polls_button()
	if(!client?.prefs)
		return null
	var/R = REF(src)
	return {"<a class="bm-btn" href='?src=[R];bm_lobby_action=polls_menu'>ОПРОСЫ СЕРВЕРА</a>"}

// ===========================
// ОБРАБОТКА HREF-ЗАПРОСОВ
// ===========================

/mob/dead/new_player/Topic(href, href_list[])
	if(src != usr)
		return FALSE
	if(!client)
		return FALSE

	if(!href_list["bm_lobby_action"])
		return ..()

	var/action = href_list["bm_lobby_action"]

	switch(action)
		if("page_ready")
			bm_lobby_ready = TRUE
			SStitle_bm?.update_character_name(src, client?.prefs?.real_name)
			bm_push_background()
			if(client?.holder)
				client << output(1, "bm_lobby_browser:bm_set_admin")
			SStitle_bm?.push_player_count_to(src)
			if(bm_lobby_music_path != "" || SSticker?.login_music)
				client.bm_push_lobby_music()
			return

		if("toggle_ready")
			_bm_play_click_sound()
			if(!COOLDOWN_FINISHED(src, bm_ready_cd))
				return FALSE
			COOLDOWN_START(src, bm_ready_cd, 0.6 SECONDS)
			if(!ready && !check_preferences())
				// check_preferences уже выставил ready = PLAYER_NOT_READY и ineligible_for_roles
				client << output("Выберите хотя бы одну профессию в настройках персонажа, иначе вы не сможете войти в раунд.", "bm_lobby_browser:bm_show_notice")
				client << output(FALSE, "bm_lobby_browser:bm_toggle_ready")
				return FALSE
			ready = !ready
			client << output(ready, "bm_lobby_browser:bm_toggle_ready")
			return

		if("toggle_antag")
			_bm_play_click_sound()
			var/datum/preferences/prefs = client.prefs
			if(prefs)
				prefs.toggles ^= NO_ANTAG
				prefs.save_preferences()
				var/antag_on = !(prefs.toggles & NO_ANTAG)
				client << output(antag_on, "bm_lobby_browser:bm_toggle_antag")
			return

		if("toggle_nsfw")
			if(client?.prefs)
				client.prefs.bm_lobby_show_nsfw = !client.prefs.bm_lobby_show_nsfw
				client.prefs.save_preferences()
				client << output(client.prefs.bm_lobby_show_nsfw, "bm_lobby_browser:bm_update_nsfw_indicator")
				bm_push_background()
			return


		if("observe")
			_bm_play_click_sound()
			make_me_an_observer()  // bm_hide/show_lobby обрабатывается в override ниже
			return

		if("late_join")
			_bm_play_click_sound()
			LateChoices()
			return

		if("view_manifest")
			_bm_play_click_sound()
			ViewManifest()
			return

		if("character_directory")
			_bm_play_click_sound()
			client.show_character_directory()
			return

		if("character_setup")
			_bm_play_click_sound()
			client.prefs.current_tab = SETTINGS_TAB
			client.prefs.ShowChoices(src)
			return

		if("game_options")
			_bm_play_click_sound()
			client.prefs.current_tab = PREFERENCES_TAB
			client.prefs.ShowChoices(src)
			return

		if("job_traits")
			_bm_play_click_sound()
			show_job_traits()
			return

		if("polls_menu")
			_bm_play_click_sound()
			handle_player_polling()
			return

		if("start_game")
			if(!client?.holder)
				return
			if(!SSticker || SSticker.current_state != GAME_STATE_PREGAME)
				return
			_bm_play_click_sound()
			SSticker.start_immediately = TRUE
			log_admin("[key_name(src)] запустил раунд через HTML-лобби.")
			message_admins("[key_name_admin(src)] запустил раунд через HTML-лобби.")
			return

	return ..()

/mob/dead/new_player/proc/_bm_play_click_sound()
	SEND_SOUND(src, sound('sound/misc/menu/ui_select1.ogg'))

/datum/asset/simple/bm_lobby
	assets = list(
		"bm_lobby.js" = 'modular_bluemoon/assets/js/bm_lobby.js'
	)

/mob/dead/new_player/proc/show_job_traits()
	if(!client)
		return
	if(!length(GLOB.lobby_station_traits))
		to_chat(src, span_warning("Сейчас нет доступных особенностей работы!"))
		return
	var/list/available = list()
	for(var/datum/station_trait/trait as anything in GLOB.lobby_station_traits)
		if(!trait.can_display_lobby_button(client))
			continue
		available += trait
	if(!LAZYLEN(available))
		to_chat(src, span_warning("Сейчас нет доступных особенностей работы!"))
		return
	var/datum/station_trait/clicked_trait = tgui_input_list(src, "Выберите особенность работы для регистрации:", "Особенности работы", available)
	if(!clicked_trait)
		return
	clicked_trait.on_lobby_button_click(src)

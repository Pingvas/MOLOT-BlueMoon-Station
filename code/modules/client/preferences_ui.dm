/datum/preferences/proc/CaptureKeybinding(mob/user, datum/keybinding/kb, old_key, independent = FALSE, special = FALSE)
	var/HTML = {"
<div id='focus' style="outline: 0;" tabindex=0>Keybinding: [kb.full_name]<br>[kb.description]<br><br><b>Press any key to change<br>Press ESC to clear</b></div>
<script>
var deedDone = false;
document.onkeyup = function(e) {
	if(deedDone){ return; }
	var alt = e.altKey ? 1 : 0;
	var ctrl = e.ctrlKey ? 1 : 0;
	var shift = e.shiftKey ? 1 : 0;
	var numpad = (95 < e.keyCode && e.keyCode < 112) ? 1 : 0;
	var escPressed = e.keyCode == 27 ? 1 : 0;
	var url = 'byond://?_src_=prefs;preference=keybindings_set;keybinding=[kb.name];old_key=[old_key];[independent?"independent=1;":""][special?"special=1;":""]clear_key='+escPressed+';key='+e.key+';alt='+alt+';ctrl='+ctrl+';shift='+shift+';numpad='+numpad+';key_code='+e.keyCode;
	window.location=url;
	deedDone = true;
}
document.getElementById('focus').focus();
</script>
"}
	winshow(user, "capturekeypress", TRUE)
	var/datum/browser/popup = new(user, "capturekeypress", "<div align='center'>Keybindings</div>", 350, 300)
	popup.set_content(HTML)
	popup.open(FALSE)
	onclose(user, "capturekeypress", src)



// ========== Sand: Language selection ==========
//SANDSTORM EDIT - extra language
/datum/preferences/proc/SetLanguage(mob/user)
	var/list/dat = list()
	dat += "<center><b>Choose Additional Languages</b></center><br>"
	if(!CONFIG_GET(number/max_languages) == 0)
		dat += "<center>Do note, however, you can have many languages. <b>Do not abuse this.</b></center><br>"
		dat += "<center>If you want no additional language at all, click reset to disable all languages.</center><br>"
		dat += "<hr>"
		if(SSlanguage && SSlanguage.languages_by_name.len)
			for(var/V in SSlanguage.languages_by_name)
				var/datum/language/L = SSlanguage.languages_by_name[V]
				if(!L)
					return
				var/language_name = L.name
				var/restricted = FALSE
				if(L.restricted)
					restricted = TRUE
				if(restricted && !(language_name in pref_species.languagewhitelist))
					var/quirklanguagefound = FALSE
					for(var/datum/quirk/Q in all_quirks)
						if(language_name in Q.languagewhitelist)
							quirklanguagefound = TRUE
					if(!quirklanguagefound)
						continue
				else
					dat += "<a [(language_name in language) ? "class='linkOn'" : ""] href='?_src_=prefs;preference=language;task=update;language=[language_name]'><b>[language_name]</a></b> [L.desc]<br><br>"
		else
			dat += "<center><b>The language subsystem hasn't fully loaded yet! Please wait a bit and try again.</b></center><br>"
		dat += "<hr>"
		dat += "<td><center><a style='white-space:normal;background:#eb2e2e;' href='?_src_=prefs;preference=language;task=reset'>Reset</center></span></td>"
	else
		dat += "<hr>"
		dat += "<b>Additional Languages are disabled.</b>"
		dat += "<hr>"
	dat += "<center><a href='?_src_=prefs;preference=language;task=close'>Done</a></center>"

	var/datum/browser/popup = new(user, "mob_occupation", "<div align='center'>Language Preference</div>", 900, 600) //no reason not to reuse the occupation window, as it's cleaner that way
	popup.set_window_options("can_close=0")
	popup.set_content(dat.Join())
	popup.open(FALSE)
//

/datum/preferences/proc/toggle_language(lang)
	if(lang in language)
		language -= lang
		return TRUE
	else if(check_language_maxhit())
		if(CONFIG_GET(number/max_languages) == 1)
			tgui_alert(usr, "You can only have 1 additional language!", timeout = 5 SECONDS)
		else
			tgui_alert(usr, "You can only have up to [CONFIG_GET(number/max_languages)] additional languages!", timeout = 5 SECONDS)
		return FALSE
	else
		language += lang
		return TRUE

/datum/preferences/proc/check_language_maxhit()
	if(CONFIG_GET(number/max_languages) == -1) //infinite
		return FALSE
	else if(language.len >= CONFIG_GET(number/max_languages))
		return TRUE

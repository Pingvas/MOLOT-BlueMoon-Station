// Preserves scroll position in BYOND browser windows across content refreshes.
// Loaded only for the character preferences browser.
(function () {
	'use strict';

	var KEY = 'bm_prefs_scroll';

	function getScrollTop() {
		return (document.documentElement && document.documentElement.scrollTop) || document.body.scrollTop || 0;
	}

	function setScrollTop(y) {
		try {
			if (document.documentElement) document.documentElement.scrollTop = y;
			if (document.body) document.body.scrollTop = y;
			window.scrollTo(0, y);
		} catch (e) {
			// ignore
		}
	}

	function saveToCookie(y) {
		try {
			document.cookie = KEY + '=' + String(y) + '; path=/; SameSite=Lax';
		} catch (e) {
			// ignore
		}
	}

	function loadFromCookie() {
		try {
			var m = document.cookie.match(new RegExp('(?:^|;\\s*)' + KEY + '=(\\d+)'));
			if (m) return m[1];
		} catch (e) {
			// ignore
		}
		return null;
	}

	function save() {
		var y = getScrollTop();
		// Фикс для 516. используем куки.
		saveToCookie(y);
		try {
			if (window.sessionStorage) {
				window.sessionStorage.setItem(KEY, String(y));
			}
		} catch (e) {
			// ignore
		}
	}

	function load() { // выдираем из куки.
		var stored = null;
		stored = loadFromCookie();
		if (stored == null) {
			try {
				if (window.sessionStorage) stored = window.sessionStorage.getItem(KEY);
			} catch (e) {
				stored = null;
			}
		}
		// Last resort: window.name
		if (stored == null) {
			try {
				var m = (window.name || '').match(new RegExp(KEY + '=(\\d+)'));
				if (m) stored = m[1];
			} catch (e2) {
				stored = null;
			}
		}

		var y = parseInt(stored, 10);
		if (!isNaN(y) && y > 0) {
			setTimeout(function () { setScrollTop(y); }, 60);
		}
	}

	try {
		load();
		window.onscroll = save;
		window.onbeforeunload = save;
		window.onunload = save;
	} catch (e) {
		// ignore
	}
})();

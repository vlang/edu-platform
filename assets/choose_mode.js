"use strict";

const Mode = {DARK: 0, LIGHT: 1};

function defaultSettings() {
	return {mode: Mode.DARK};
}

function settings(f = null) {
	if (f) {
		const j = f({
			...defaultSettings(),
			...(JSON.parse(localStorage.getItem('settings') || '{}')),
		});
		return j ? (localStorage.setItem('settings', JSON.stringify(j)), j) : j;
	}
	return {
		...defaultSettings(),
		...JSON.parse(localStorage.getItem('settings') || '{}'),
	};
}

function switchMode() {
	const { mode } = settings(j => ({
		...j,
		mode: [Mode.LIGHT, Mode.DARK][j.mode],
	}));
	setupMode(mode);
}

function setupMode(mode) {
	for (const e of document.getElementsByClassName('dark-theme')) {
		e.disabled = mode === Mode.LIGHT;
	}
	const html = document.querySelector("html");
	switch (mode) {
	case Mode.LIGHT:
		html.className = 'light_mode';
		break;
	case Mode.DARK:
		html.className = 'dark_mode';
		break;
	}
}

setupMode(settings().mode);

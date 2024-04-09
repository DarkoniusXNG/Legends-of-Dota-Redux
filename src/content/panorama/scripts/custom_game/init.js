GameUI.CustomUIConfig().multiteam_top_scoreboard = {
	shouldSort: false
};

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_TEAMS, true);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_GAME_NAME, true);
GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_HERO_SELECTION_CLOCK, true);

GameUI.SetDefaultUIEnabled(DotaDefaultUIElement_t.DOTA_DEFAULT_UI_ENDGAME, true);

GameEvents.Subscribe('lodCreateIngameErrorMessage', function(data) {
	GameEvents.SendEventClientSide('dota_hud_error_message', {
		splitscreenplayer: 0,
		reason: data.reason || 80,
		message: data.message
	})
});

GameEvents.Subscribe('lodEmitClientSound', function(data) {
	if (data.sound) {
		Game.EmitSound(data.sound);
	}
});

var mapName = Game.GetMapInfo().map_display_name;
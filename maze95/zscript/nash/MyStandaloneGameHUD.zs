class MyStandaloneGameHUD : BaseStatusBar
{
	HUDFont mHUDFont;
	Maze95Player pmo;

	override void Init(void)
	{
		Super.Init();
		SetSize(0, 320, 200);
		Font fnt = SmallFont;
		mHUDFont = HUDFont.Create(fnt, fnt.GetCharWidth("0"), Mono_CellLeft, 1, 1);
	}

	override void Draw(int state, double TicFrac)
	{
		if (CPlayer && CPlayer.mo)
		{
			pmo = Maze95Player(CPlayer.mo);
		}

		BaseStatusBar.Draw(state, TicFrac);

		if (state == HUD_StatusBar || state == HUD_Fullscreen)
		{
			BeginHUD(forcescaled: true);
			// DrawHealth();
		}
	}

	void DrawHealth(void)
	{
		DrawString(mHUDFont, StringTable.Localize("Health: ") .. FormatNumber(pmo.player.health, 3), (44, -20));
	}
}

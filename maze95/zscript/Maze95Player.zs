
class Maze95Player : DoomPlayer replaces DoomPlayer
{
    bool upSideDown;
    bool _oldUpSideDown;
    const ROLL_STEP = 6;
    bool stretchFrozen;

    Default
    {
        Height 64;
        Player.ViewHeight 64;
        Player.AttackZOffset 32;
        Player.ViewBob 0;
        Player.StartItem "Z_NashMove";
    }
    States
    {
        Spawn:
            PLAY A 0 NoDelay _onSpawn();
            goto Normal;
        NormalTransition:
            PLAY A 1 A_SetRoll(roll-ROLL_STEP, SPF_INTERPOLATE);
            PLAY A 0 A_JumpIf(roll <= 0, "Normal");
            loop;
        Normal:
            PLAY A 0 onRotationEnd();
            PLAY A 0 A_SetRoll(0);
            PLAY A -1;
        UpSideDownTransition:
            PLAY A 1 A_SetRoll(roll+ROLL_STEP, SPF_INTERPOLATE);
            PLAY A 0 A_JumpIf(roll >= 180, "UpSideDown");
            loop;
        UpSideDown:
            PLAY A 0 onRotationEnd();
            PLAY A 0 A_SetRoll(180);
            PLAY A -1;
    }

    override void Tick()
    {
        if (self.stretchFrozen && !(self.player.cheats & (CF_NOCLIP | CF_NOCLIP2))) return;
        super.Tick();
        if (upSideDown != _oldUpSideDown) {
            _oldUpSideDown = upSideDown;
            if (upSideDown) {
                SetState(ResolveState("UpSideDownTransition"));
            } else {
                SetState(ResolveState("NormalTransition"));
            }
        }
    }

    void _onSpawn()
    {
        self.upSideDown = false;
        self._oldUpSideDown = false;
    }

    void setSpawnState()
    {
        SetState(ResolveState("Spawn"));
    }

    void onRotationEnd()
    {
        PlatonicSolid solid;
        ThinkerIterator iterator = ThinkerIterator.Create("PlatonicSolid");
        while (solid = PlatonicSolid(iterator.next()))
        {
            if (solid && solid.destroyMeAfterRotation) {
                solid.destroy();
            }
        }
    }
}

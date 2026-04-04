
class Maze95Player : DoomPlayer replaces DoomPlayer
{
    bool upSideDown;
    bool _oldUpSideDown;
    int tmpRoll;
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
            PLAY A 1 A_SetRoll(roll-5, SPF_INTERPOLATE);
            PLAY A 0 A_JumpIf(roll == 0, "Normal");
            loop;
        Normal:
            PLAY A 1;
            loop;
        UpSideDownTransition:
            PLAY A 1 A_SetRoll(roll+5, SPF_INTERPOLATE);
            PLAY A 0 A_JumpIf(roll == 180, "UpSideDown");
            loop;
        UpSideDown:
            PLAY A 1;
            loop;
    }

    override void Tick()
    {
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
        A_SetRoll(0);
        self.upSideDown = false;
        self._oldUpSideDown = false;
    }

    void setSpawnState()
    {
        SetState(ResolveState("Spawn"));
    }
}

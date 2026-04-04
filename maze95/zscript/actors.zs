
class Smiley : Actor
{
    const PROMPT_SECS = 2.5;
    int lastPromptTime;
    bool noPrompt;

    Default
    {
        Height 100;
        Radius 20;
        +NOGRAVITY;
        +SOLID;
    }
    States
    {
        Spawn:
            SMIL A -1;
            Loop;
    }

    override bool Used(Actor user)
    {
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        generator.restart();
        return true;
    }

    override bool CanCollideWith(Actor other, bool passive)
    {
        if (noPrompt || (level.time - lastPromptTime) <= PROMPT_SECS*35*2) {
            return false;
        }
        if (other is "Maze95Player")
        {
            MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
            if (generator.completedLevels > 1) {
                noPrompt = true;
                return false;
            }
            lastPromptTime = level.time;
            generator.player.A_Print("Press 'use' key to finish the level", PROMPT_SECS, "CONFONT");
        }
        return false;
    }

}


class OpenGLLogo : Actor
{
    Default
    {
        +NOGRAVITY;
        +FORCEXYBILLBOARD;
    }
    States
    {
        Spawn:
            OPGL A -1;
            Loop;
    }
}

class StartMarker : Actor
{
    Default
    {
        +NOGRAVITY;
    }
    States
    {
        Spawn:
            STRT A -1;
            Loop;
    }
}


class PlatonicSolid : Actor
{
    Default
    {
        +NOGRAVITY;
    }
    States
    {
        Spawn:
            TNT1 A 0 NoDelay A_JumpIf(random(1, 4) == 4, "tetrahedron");
            TNT1 A 0 A_JumpIf(random(1, 3) == 3, "octahedron");
            TNT1 A 0 A_JumpIf(random(1, 2) == 2, "dodecahedron");
            TNT1 A 0 A_JumpIf(random(1, 1) == 1, "icosahedron");
            loop;
        tetrahedron:
            PLAT A 10;
            loop;
        octahedron:
            PLAT B 10;
            loop;
        dodecahedron:
            PLAT C 10;
            loop;
        icosahedron:
            PLAT D 10;
            loop;
    }
}

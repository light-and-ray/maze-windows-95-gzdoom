
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
        +SOLID;
        Radius 40;
    }
    States
    {
        Spawn:
            TNT1 A 0 NoDelay setRandomModel();
            loop;
        tetrahedron:
            PLAT A -1;
            loop;
        octahedron:
            PLAT B -1;
            loop;
        dodecahedron:
            PLAT C -1;
            loop;
        icosahedron:
            PLAT D -1;
            loop;
    }

    override bool CanCollideWith(Actor other, bool passive)
    {
        if (other is "Maze95Player")
        {
            Maze95Player player = Maze95Player(other);
            player.upSideDown = !player.upSideDown;
            self.destroy();
        }
        return false;
    }

    void setRandomModel()
    {
        int modelIndex = random(1, 4);
        if (modelIndex == 1) {
            SetState(ResolveState("tetrahedron"));
        } else if (modelIndex == 2) {
            SetState(ResolveState("octahedron"));
        } else if (modelIndex == 3) {
            SetState(ResolveState("dodecahedron"));
        } else if (modelIndex == 4) {
            SetState(ResolveState("icosahedron"));
        }
    }
}


class MissingShadersWarning : Actor
{
    Default
    {
        +NOGRAVITY;
    }
    States
    {
        Spawn:
            ADVA A -1;
            loop;
    }
}


class Rat : MazeWalker
{
    States
    {
        Spawn:
            RATA A -1;
            loop;
    }
}

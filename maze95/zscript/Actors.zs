
class Maze3DActor : Actor
{
    bool stretchFrozen;
    bool visibleByPlayer;

    Default
    {
        Height 128;
        Radius 10;
        +NOGRAVITY;
    }
}


class Smiley : Maze3DActor
{
    const PROMPT_SECS = 2.5;
    int lastPromptTime;
    bool noPrompt;
    bool restarted;

    Default
    {
        Radius 20;
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
        self.restart();
        return true;
    }

    override bool CanCollideWith(Actor other, bool passive)
    {
        if (other is "AutoWalkingCamera")
        {
            self.restart();
            return false;
        }
        if (noPrompt || (level.time - lastPromptTime) <= PROMPT_SECS*35*2){
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

    void restart()
    {
        if (self.restarted) return;
        self.restarted = true;
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        generator.stretcher.startStretchingDown();
    }
}


class OpenGLLogo : Maze3DActor
{
    Default
    {
        +FORCEXYBILLBOARD;
    }
    States
    {
        Spawn:
            OPGL A -1;
            Loop;
    }
}

class StartMarker : Maze3DActor
{
    States
    {
        Spawn:
            STRT A -1;
            Loop;
    }
}


class PlatonicSolid : Maze3DActor
{
    bool destroyMeAfterRotation;
    Default
    {
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
        tetrahedron2:
            PLAT E -1;
            loop;
    }

    override bool CanCollideWith(Actor other, bool passive)
    {
        if (Skill <= 1) {
            return false;
        }
        if (self.destroyMeAfterRotation) {
            return false;
        }
        if (other is "Maze95Player")
        {
            Maze95Player player = Maze95Player(other);
            player.upSideDown = !player.upSideDown;
            self.destroyMeAfterRotation = true;
        }
        if (other is "AutoWalkingCamera")
        {
            AutoWalkingCamera camera = AutoWalkingCamera(other);
            camera.upSideDown = !camera.upSideDown;
            self.destroyMeAfterRotation = true;
        }
        return false;
    }

    void setRandomModel()
    {
        int modelIndex = random(1, 5);
        if (modelIndex == 1) {
            SetState(ResolveState("tetrahedron"));
        } else if (modelIndex == 2) {
            SetState(ResolveState("octahedron"));
        } else if (modelIndex == 3) {
            SetState(ResolveState("dodecahedron"));
        } else if (modelIndex == 4) {
            SetState(ResolveState("icosahedron"));
        } else if (modelIndex == 5) {
            SetState(ResolveState("tetrahedron2"));
        }
    }
}


class MissingShadersWarning : Maze3DActor
{
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


class AutoWalkingCamera : MazeWalker
{
    Default
    {
        Height 64;
        CameraHeight 64;
        CameraFOV 115;
        +SOLID;
    }
}


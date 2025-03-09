
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


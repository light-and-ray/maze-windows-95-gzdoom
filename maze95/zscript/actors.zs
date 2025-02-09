
class Smiley : Actor
{
    Default
    {
        Height 100;
        Radius 20;
        +NOGRAVITY;
    }
    States
    {
        Spawn:
            SMIL A -1;
            Loop;
    }
}


class OpenGLLogo : Actor
{
    Default
    {
        +NOGRAVITY;
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


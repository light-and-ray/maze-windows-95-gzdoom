
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

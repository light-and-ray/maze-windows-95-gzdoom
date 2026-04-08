class BackroomsActivator : Thinker
{
    const CHECK_INTERVAL = 200;
    const MAX = 1320;
    const MIN = -50;
    Maze95Player player;

    override void Tick()
    {
        if (Level.time % CHECK_INTERVAL == 0)
        {
            if (self.player.pos.x > self.MAX || self.player.pos.y > self.MAX ||
                self.player.pos.x < self.MIN || self.player.pos.y < self.MIN)
            {
                MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
                generator.toggleBackrooms();
                generator.restart();
                generator.player.player.cheats &= ~CF_NOCLIP;
                generator.player.player.cheats &= ~CF_NOCLIP2;
            }
        }
    }
}


class BackroomsHandler : EventHandler
{
    override void PlayerEntered(PlayerEvent e)
    {
        BackroomsActivator activator = new("BackroomsActivator");
        activator.player = Maze95Player(players[e.PlayerNumber].mo);
    }

}

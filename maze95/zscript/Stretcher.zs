enum StretcherState_t
{
    STRETCHER_NOTHING = 0,
    STRETCHING_UP = 1,
    STRETCHING_DOWN = 2,
}


class Stretcher_t : Thinker
{
    StretcherState_t state;
    const STRETCH_STEP = 0.02;
    double MAX_STRETCH;
    const MIN_STRETCH = STRETCH_STEP;
    double nextStretch;

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        self.MAX_STRETCH = (Skill > 0 ? 1.0 : 0.2);
    }


    override void Tick()
    {
        if (self.state == STRETCHING_UP) {
            self.stretchingUpTick();
        } else if (self.state == STRETCHING_DOWN) {
            self.stretchingDownTick();
        }
    }

    void stretchingUpTick()
    {
        if (self.nextStretch >= self.MAX_STRETCH) {
            self.afterStretchingUp();
        }
        self.applyNextStretch();
        self.nextStretch += self.STRETCH_STEP;
        if (self.nextStretch > self.MAX_STRETCH) {
            self.nextStretch = self.MAX_STRETCH;
        }
    }

    void stretchingDownTick()
    {
        if (self.nextStretch <= self.MIN_STRETCH) {
            self.afterStretchingDown();
        }
        self.applyNextStretch();
        self.nextStretch -= self.STRETCH_STEP;
        if (self.nextStretch < self.MIN_STRETCH) {
            self.nextStretch = self.MIN_STRETCH;
        }
    }

    void applyNextStretch()
    {
        for (int lineNum = 0; lineNum < Level.lines.size(); lineNum += 1)
        {
            Line line = level.lines[lineNum];
            Side front = line.sidedef[Line.front];
            Side back = line.sidedef[Line.back];
            if (front && front.GetTexture(Side.mid))
            {
                front.SetTextureYScale(Side.mid, 1/self.nextStretch);
            }
            if (back && back.GetTexture(Side.mid))
            {
                back.SetTextureYScale(Side.mid, 1/self.nextStretch);
            }
        }
    }


    void startStretchingUp()
    {
        self.hideThings();
        self.nextStretch = self.MIN_STRETCH;
        self.state = STRETCHING_UP;
    }

    void startStretchingDown()
    {
        self.hideThings();
        self.nextStretch = self.MAX_STRETCH - self.STRETCH_STEP;
        self.state = STRETCHING_DOWN;
    }

    void afterStretchingUp()
    {
        self.state = STRETCHER_NOTHING;
        self.showThings();
    }

    void afterStretchingDown()
    {
        self.state = STRETCHER_NOTHING;
        self.showThings();
        self.restart();
    }


    void restart()
    {
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        generator.nextLevel();
    }


    void hideThings()
    {
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            if (actor && !generator.player.CheckSight(actor))
            {
                actor.bINVISIBLE = true;
            }
        }
    }

    void showThings()
    {
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            actor.bINVISIBLE = false;
        }
    }

}

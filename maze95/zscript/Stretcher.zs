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
    const MAX_STRETCH = 1.0;
    double MAX_WALLS_STRETCH;
    const MIN_STRETCH = STRETCH_STEP;
    double nextStretch;
    Map<int, bool> linesToShow;
    const HIDDEN_OFFSET = 30000;

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        self.MAX_WALLS_STRETCH = (Skill > 0 ? 1.0 : 0.2);
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
        if (self.nextStretch <= self.MAX_WALLS_STRETCH)
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
        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            actor.scale.y = self.nextStretch;
        }

    }


    void startStretchingUp()
    {
        self.onStart();
        self.nextStretch = self.MIN_STRETCH;
        self.state = STRETCHING_UP;
    }

    void startStretchingDown()
    {
        self.onStart();
        self.nextStretch = self.MAX_STRETCH - self.STRETCH_STEP;
        self.state = STRETCHING_DOWN;
    }

    void afterStretchingUp()
    {
        self.onEnd();
        self.state = STRETCHER_NOTHING;
    }

    void afterStretchingDown()
    {
        self.onEnd();
        self.state = STRETCHER_NOTHING;
        self.restart();
    }

    void onStart()
    {
        self.freezeActors();
        self.hideThingsAndWalls();
    }

    void onEnd()
    {
        self.unFreezeActors();
        self.showThingsAndWalls();
    }


    void restart()
    {
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        generator.nextLevel();
    }


    void hideThingsAndWalls()
    {
        if (Skill == 0) return;
        self.linesToShow.clear();
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        Actor camera = generator.player.player.camera;

        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            actor.visibleByPlayer = false;
        }

        double MAX_FOV = 120;
        int LINE_TRACING_RESOLUTION = 2000;
        double ANGLE_STEP = MAX_FOV / LINE_TRACING_RESOLUTION;
        double PENETRATION_STEP = 5;

        for (int i = 0; i < LINE_TRACING_RESOLUTION; i++)
        {
            FLineTraceData traceData;
            double offsetForward = 0;
            while (true)
            {
                camera.LineTrace(camera.angle - MAX_FOV/2 + ANGLE_STEP*i, 10000, 0, TRF_ALLACTORS, 64, offsetForward, 0, traceData);
                if (traceData.HitLine) {
                    self.linesToShow.InsertNew(traceData.HitLine.Index());
                    break;
                } else if (traceData.hitActor && traceData.hitActor is "Maze3DActor") {
                    actor = Maze3DActor(traceData.hitActor);
                    actor.visibleByPlayer = true;
                }
                offsetForward += traceData.Distance + PENETRATION_STEP;
            }
        }

        iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            if (!actor.visibleByPlayer)
            {
                actor.bINVISIBLE = true;
            }
        }


        for (int lineNum = 0; lineNum < Level.lines.size(); lineNum++)
        {
            if (!self.linesToShow.CheckKey(lineNum))
            {
                if (Level.lines[lineNum].sidedef[Line.front]) {
                    Level.lines[lineNum].sidedef[Line.front].AddTextureYOffset(Side.mid, HIDDEN_OFFSET);
                }
                if (Level.lines[lineNum].sidedef[Line.back]) {
                    Level.lines[lineNum].sidedef[Line.back].AddTextureYOffset(Side.mid, HIDDEN_OFFSET);
                }
            }
        }
    }

    void showThingsAndWalls()
    {
        if (Skill == 0) return;
        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            actor.bINVISIBLE = false;
        }

        for (int lineNum = 0; lineNum < Level.lines.size(); lineNum++)
        {
            if (!self.linesToShow.CheckKey(lineNum))
            {
                if (Level.lines[lineNum].sidedef[Line.front]) {
                    Level.lines[lineNum].sidedef[Line.front].AddTextureYOffset(Side.mid, -HIDDEN_OFFSET);
                }
                if (Level.lines[lineNum].sidedef[Line.back]) {
                    Level.lines[lineNum].sidedef[Line.back].AddTextureYOffset(Side.mid, -HIDDEN_OFFSET);
                }
            }
        }
    }


    void freezeActors()
    {
        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            actor.stretchFrozen = true;
        }
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        generator.player.stretchFrozen = true;
    }

    void unFreezeActors()
    {
        Maze3DActor actor;
        ThinkerIterator iterator = ThinkerIterator.Create("Maze3DActor");
        while (actor = Maze3DActor(iterator.next()))
        {
            actor.stretchFrozen = false;
        }
        MazeGenerator generator = MazeGenerator(EventHandler.Find("MazeGenerator"));
        generator.player.stretchFrozen = false;
    }

}

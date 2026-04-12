enum WalkerState_t
{
    THINKING = 0,
    WALKING = 1,
    WALKER_NOTHING = 2,
    ROTATING = 3,
}

class MazeWalker : Maze3DActor
{
    void getLineMoveIntermediateSteps(Array<double> points, double xA, double yA, double xB, double yB, double step, bool returnX)
    {
        double dx = xB - xA;
        double dy = yB - yA;
        double lineLength = sqrt(dx * dx + dy * dy);

        // If the points are identical, just return point B
        if (lineLength == 0)
        {
            if (returnX) {
                points.Push(xB);
            } else {
                points.Push(yB);
            }
            return;
        }

        double directionX = dx / lineLength;
        double directionY = dy / lineLength;

        double currentDist = step;

        // Loop to add all intermediate steps that are strictly less than the total length
        while (currentDist < lineLength)
        {
            Vector2 p;
            p.x = xA + directionX * currentDist;
            p.y = yA + directionY * currentDist;

            if (returnX) {
                points.Push(p.x);
            } else {
                points.Push(p.y);
            }

            currentDist += step;
        }

        // Explicitly add the final point B (handling the "shorter last step" automatically)
        if (returnX) {
            points.Push(xB);
        } else {
            points.Push(yB);
        }
    }

    bool turnsAlwaysRight;
    Array<double> intermediateStepsX;
    Array<double> intermediateStepsY;
    Array<double> intermediateStepsAngle;
    int currentStep;
    WalkerState_t walkerState;

    const WALK_STEP = 5;

    bool upSideDown;
    bool _oldUpSideDown;
    WalkerState_t beforeRotationState;
    const ROLL_STEP = 6;

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        self.initialWalk();
    }

    override void Tick()
    {
        super.Tick();
        if (self.stretchFrozen) return;

        if (self.upSideDown != self._oldUpSideDown)
        {
            self._oldUpSideDown = self.upSideDown;
            self.beforeRotationState = self.walkerState;
            self.walkerState = ROTATING;
        }

        if (self.walkerState == THINKING) {
            self.thinkingTick();
        } else if (self.walkerState == WALKING) {
            self.walkTick();
        } else if (self.walkerState == ROTATING) {
            self.rotatingTick();
        }
    }

    void thinkingTick()
    {
        double turns[4];
        turns[0] = (self.turnsAlwaysRight ? -90 : 90);
        turns[1] = 0;
        turns[2] = (self.turnsAlwaysRight ? 90 : -90);
        if (self.turnsAlwaysRight)
        {
            do {
                if (self.tryWalkRight()) break;
                if (self.tryWalkForward()) break;
                if (self.tryWalkLeft()) break;
                if (self.tryWalkBackward()) break;
            } while (false);
        }
        else
        {
            do {
                if (self.tryWalkLeft()) break;
                if (self.tryWalkForward()) break;
                if (self.tryWalkRight()) break;
                if (self.tryWalkBackward()) break;
            } while (false);
        }

        self.currentStep = 0;
        self.walkerState = WALKING;
        self.walkTick();
    }


    bool tryWalkRight()
    {
        return false;
    }

    bool tryWalkLeft()
    {
        return false;
    }

    bool tryWalkForward()
    {
        FLineTraceData traceData;
        self.LineTrace(self.angle, 10000, 0, TRF_THRUACTORS, 64, 64, 0, traceData);
        Vector2 A = (self.pos.x, self.pos.y);
        Vector2 B = (traceData.HitLocation.x, traceData.HitLocation.y);
        Vector2 dirAB = B - A;
        double dist = dirAB.Length();
        if (dist <= 128)
        {
            return false;
        }
        else
        {
            B = A + dirAB.Unit() * 128;
        }
        self.intermediateStepsX.clear();
        self.intermediateStepsY.clear();
        self.intermediateStepsAngle.clear();
        self.getLineMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, self.WALK_STEP, true);
        self.getLineMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, self.WALK_STEP, false);
        for (int i = 0; i < intermediateStepsX.size(); i++) {
            self.intermediateStepsAngle.push(self.angle);
        }
        return true;
    }

    bool tryWalkBackward()
    {
        double turn = (self.turnsAlwaysRight ? -180 : 180);
        FLineTraceData traceData;
        self.LineTrace(self.angle + turn, 10000, 0, TRF_THRUACTORS, 64, 64, 0, traceData);
        Vector2 A = (self.pos.x, self.pos.y);
        Vector2 B = (traceData.HitLocation.x, traceData.HitLocation.y);
        Vector2 dirAB = B - A;
        double dist = dirAB.Length();
        if (dist <= 128)
        {
            return false;
        }
        else
        {
            B = A + dirAB.Unit() * 128;
        }
        self.intermediateStepsX.clear();
        self.intermediateStepsY.clear();
        self.intermediateStepsAngle.clear();
        self.getLineMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, self.WALK_STEP, true);
        self.getLineMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, self.WALK_STEP, false);
        double angleStep = turn / intermediateStepsX.size();
        for (int i = 0; i < intermediateStepsX.size(); i++) {
            self.intermediateStepsAngle.push(self.angle + angleStep*(i+1));
        }
        return true;
    }



    void walkTick()
    {
        double x = self.intermediateStepsX[self.currentStep];
        double y = self.intermediateStepsY[self.currentStep];
        self.setOrigin((x, y, self.pos.z), true);
        self.TestMobjLocation();
        double newAngle = self.intermediateStepsAngle[self.currentStep];
        self.A_SetAngle(newAngle, SPF_INTERPOLATE);
        self.currentStep += 1;
        if (self.currentStep >= self.intermediateStepsX.size())
        {
            self.walkerState = THINKING;
        }
    }

    void rotatingTick()
    {
        bool complete = false;

        if (self.upSideDown)
        {
            A_SetRoll(self.roll+ROLL_STEP, SPF_INTERPOLATE);
            if (self.roll >= 180) {
                complete = true;
                A_SetRoll(180, SPF_INTERPOLATE);
            }
        }
        else
        {
            A_SetRoll(self.roll-ROLL_STEP, SPF_INTERPOLATE);
            if (self.roll <= 0) {
                complete = true;
                A_SetRoll(0, SPF_INTERPOLATE);
            }
        }
        if (complete)
        {
            self.walkerState = self.beforeRotationState;
            PlatonicSolid solid;
            ThinkerIterator iterator = ThinkerIterator.Create("PlatonicSolid");
            while (solid = PlatonicSolid(iterator.next()))
            {
                if (solid && solid.destroyMeAfterRotation) {
                    solid.destroy();
                }
            }
        }
    }


    void initialWalk()
    {
        Vector2 A = (self.pos.x, self.pos.y);
        Vector2 B;
        B.x = A.x + 64 * cos(self.angle);
        B.y = A.y + 64 * sin(self.angle);

        self.getLineMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, self.WALK_STEP, true);
        self.getLineMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, self.WALK_STEP, false);
        for (int i = 0; i < intermediateStepsX.size(); i++) {
            self.intermediateStepsAngle.push(self.angle);
        }
        self.currentStep = 0;
        self.walkerState = WALKING;
    }

}

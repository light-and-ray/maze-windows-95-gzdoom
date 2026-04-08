enum WalkerState_t
{
    THINKING = 0,
    WALKING = 1,
    WALKER_NOTHING = 2,
}

class MazeWalker : Actor
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

    double walkAngle;
    const WALK_STEP = 5;

    bool upSideDown;
    bool _oldUpSideDown;

    override void PostBeginPlay()
    {
        super.PostBeginPlay();
        self.walkAngle = self.angle;
    }

    override void Tick()
    {
        super.Tick();

        if (self.walkerState == THINKING) {
            self.thinkingTick();
        } else if (self.walkerState == WALKING) {
            self.walkTick();
        }
    }

    void thinkingTick()
    {
        double turns[4];
        turns[0] = (self.turnsAlwaysRight ? -90 : 90);
        turns[1] = 0;
        turns[2] = (self.turnsAlwaysRight ? 90 : -90);
        turns[3] = (self.turnsAlwaysRight ? -180 : 180);;
        double CELL_STEP = 128.0;

        for (int i = 0; i < 4; i++)
        {
            FLineTraceData traceData;
            self.LineTrace(self.walkAngle + turns[i], 10000, 0, TRF_THRUACTORS, 64, 0, 0, traceData);
            Vector2 A = (self.pos.x, self.pos.y);
            Vector2 B = (traceData.HitLocation.x, traceData.HitLocation.y);
            Vector2 dirAB = B - A;
            double dist = dirAB.Length();
            if (dist <= CELL_STEP)
            {
                continue;
            }
            else
            {
                B = A + dirAB.Unit() * CELL_STEP;
            }
            self.walkAngle += turns[i];
            self.intermediateStepsX.clear();
            self.intermediateStepsY.clear();
            self.intermediateStepsAngle.clear();
            self.getLineMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, self.WALK_STEP, true);
            self.getLineMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, self.WALK_STEP, false);
            double angleStep = turns[i] / intermediateStepsX.size();
            for (int i = 0; i < intermediateStepsX.size(); i++) {
                self.intermediateStepsAngle.push(self.angle + angleStep * (i+1));
            }
            self.currentStep = 0;
            self.walkerState = WALKING;
            self.walkTick();
            break;
        }
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
}

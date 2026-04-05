enum WalkerState_t
{
    AIMING = 0,
    WALKING = 1,
    NOTHING = 2,
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

    Array<double> intermediateStepsX;
    Array<double> intermediateStepsY;
    int currentStep;
    WalkerState_t walkerState;

    override void Tick()
    {
        if (self.walkerState == AIMING) {
            self.aimingTick();
        } else if (self.walkerState == WALKING) {
            self.walkTick();
        }
    }

    void aimingTick()
    {
        FLineTraceData traceData;
        self.LineTrace(self.angle, 10000, 0, TRF_THRUACTORS, 0, 0, 0, traceData);
        Vector2 A = (self.pos.x, self.pos.y);
        Vector2 B = (traceData.HitLocation.x, traceData.HitLocation.y);
        Vector2 dirToA = A - B;
        double dist = dirToA.Length();
        if (dist <= 80)
        {
            console.printf("Needs turn");
            self.walkerState = NOTHING;
            return;

        }
        else
        {
            B += dirToA.Unit() * 64.0;
        }

        self.intermediateStepsX.clear();
        self.intermediateStepsY.clear();
        double STEP = 5;
        self.getLineMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, STEP, true);
        self.getLineMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, STEP, false);
        self.currentStep = 0;
        self.walkerState = WALKING;
        self.walkTick();
    }

    void walkTick()
    {
        double x = self.intermediateStepsX[self.currentStep];
        double y = self.intermediateStepsY[self.currentStep];
        self.setOrigin((x, y, self.pos.z), true);
        self.currentStep += 1;
        if (self.currentStep >= self.intermediateStepsX.size())
        {
            self.walkerState = NOTHING;
            console.printf("Needs turn");
        }
    }
}

enum WalkerState_t
{
    THINKING = 0,
    WALKING = 1,
    WALKER_NOTHING = 2,
    ROTATING = 3,
}

class MazeWalker : Maze3DActor
{
    void getLineStraightMoveIntermediateSteps(Array<double> points, double xA, double yA, double xB, double yB, double step, bool returnX)
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


    void getArcMoveIntermediateSteps(Array<double> points, double xA, double yA, double startAngle, double stepDist, bool isRight, bool returnX)
    {
        // The radius is fixed at 64
        double radius = 64.0;

        // Calculate the center of the circle (the pivot point)
        // If turning right, the center is 90 degrees to our right
        // If turning left, the center is 90 degrees to our left
        double turnDir = isRight ? -90 : 90;
        double centerX = xA + cos(startAngle + turnDir) * radius;
        double centerY = yA + sin(startAngle + turnDir) * radius;

        // We are traveling a 90-degree arc.
        // Arc length = (angle_in_radians) * radius.
        // For 90 degrees (PI/2): length = 1.5708 * 64 ≈ 100.53 units.
        double totalArcAngle = 90.0;
        double arcLength = (3.14159 * radius) / 2.0;

        double currentDist = stepDist;

        while (currentDist < arcLength)
        {
            // Calculate how far through the 90 degrees we are
            double progress = currentDist / arcLength;
            double currentAngleOffset = progress * totalArcAngle;

            // Target angle from the center of the circle
            // If turning right, we start at startAngle+90 and go to startAngle
            // If turning left, we start at startAngle-90 and go to startAngle
            double angleFromCenter;
            if (isRight) {
                angleFromCenter = (startAngle + 90) - currentAngleOffset;
            } else {
                angleFromCenter = (startAngle - 90) + currentAngleOffset;
            }

            if (returnX) {
                points.Push(centerX + cos(angleFromCenter) * radius);
            } else {
                points.Push(centerY + sin(angleFromCenter) * radius);
            }

            currentDist += stepDist;
        }

        // Push final position (The end of the arc)
        // The end position is: Center + Vector back towards original facing * radius
        // which simplifies to: Original A + (Forward * 64) + (Right/Left * 64)
        double finalAngle = isRight ? startAngle - 90 : startAngle + 90;
        // We want the position 64 units forward and 64 units to the side
        double destX = xA + cos(startAngle) * radius + cos(startAngle + turnDir) * radius;
        double destY = yA + sin(startAngle) * radius + sin(startAngle + turnDir) * radius;

        if (returnX) {
            points.Push(destX);
        } else {
            points.Push(destY);
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
        // if (self.turnsAlwaysRight)
        // {
            do {
                if (self.tryWalkRight(false)) break;
                if (self.tryWalkStraight(0, false)) break;
                if (self.tryWalkLeft(false)) break;
                if (self.tryWalkRight(true)) break;
                if (self.tryWalkStraight(-180, true)) break;
                if (self.tryWalkLeft(true)) break;
            } while (false);
        // }
        // else
        // {
        //     do {
        //         if (self.tryWalkLeft()) break;
        //         if (self.tryWalkForward()) break;
        //         if (self.tryWalkRight()) break;
        //         if (self.tryWalkBackward()) break;
        //     } while (false);
        // }
        self.currentStep = 0;
        self.walkerState = WALKING;
        self.walkTick();
    }


    bool tryWalkRight(bool isBack)
    {
        double turn = -90;
        return self.tryWalkArc(-90, true, isBack);
    }

    bool tryWalkLeft(bool isBack)
    {
        double turn = 90;
        return self.tryWalkArc(90, false, isBack);
    }

    bool tryWalkArc(double turn, bool isRight, bool isBack)
    {
        if (!self._testTurn(turn, isBack)) return false;

        Vector2 A = (self.pos.x, self.pos.y);
        self.intermediateStepsX.clear();
        self.intermediateStepsY.clear();
        self.intermediateStepsAngle.clear();

        double startAngle = isBack ? self.angle - 180 : self.angle;
        self.getArcMoveIntermediateSteps(intermediateStepsX, A.x, A.y, startAngle, self.WALK_STEP, isRight, true);
        self.getArcMoveIntermediateSteps(intermediateStepsY, A.x, A.y, startAngle, self.WALK_STEP, isRight, false);

        double totalSteps = intermediateStepsX.size();
        double angleStep = turn / intermediateStepsX.size();
        for (int i = 0; i < intermediateStepsX.size(); i++) {
            self.intermediateStepsAngle.push(self.angle + angleStep*(i+1));
        }
        return true;
    }

    bool tryWalkStraight(double turn, bool isBack)
    {
        if (!self._testTurn(turn, isBack)) return false;

        Vector2 A = (self.pos.x, self.pos.y);
        Vector2 B;
        B.x = A.x + cos(self.angle + turn) * 128;
        B.y = A.y + sin(self.angle + turn) * 128;
        self.intermediateStepsX.clear();
        self.intermediateStepsY.clear();
        self.intermediateStepsAngle.clear();
        self.getLineStraightMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, self.WALK_STEP, true);
        self.getLineStraightMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, self.WALK_STEP, false);
        double angleStep = turn / intermediateStepsX.size();
        for (int i = 0; i < intermediateStepsX.size(); i++) {
            self.intermediateStepsAngle.push(self.angle + angleStep*(i+1));
        }
        return true;
    }


    bool _testTurn(double turn, bool isBack)
    {
        FLineTraceData traceData;
        Vector3 tracePos;
        if (!isBack) {
            tracePos.x = self.pos.x + cos(self.angle) * 64;
            tracePos.y = self.pos.y + sin(self.angle) * 64;
        } else {
            tracePos.x = self.pos.x + cos(self.angle) * -64;
            tracePos.y = self.pos.y + sin(self.angle) * -64;
            turn + 180;
        }
        tracePos.z = self.pos.z + 64;
        self.LineTrace(self.angle + turn, 10000, 0, TRF_THRUACTORS|TRF_ABSPOSITION, tracePos.z, tracePos.x, tracePos.y, traceData);
        Vector2 A = (tracePos.x, tracePos.y);
        Vector2 B = (traceData.HitLocation.x, traceData.HitLocation.y);
        Vector2 dirAB = B - A;
        double dist = dirAB.Length();
        if (dist <= 128)
        {
            return false;
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

        self.getLineStraightMoveIntermediateSteps(intermediateStepsX, A.x, A.y, B.x, B.y, self.WALK_STEP, true);
        self.getLineStraightMoveIntermediateSteps(intermediateStepsY, A.x, A.y, B.x, B.y, self.WALK_STEP, false);
        for (int i = 0; i < intermediateStepsX.size(); i++) {
            self.intermediateStepsAngle.push(self.angle);
        }
        self.currentStep = 0;
        self.walkerState = WALKING;
    }

}

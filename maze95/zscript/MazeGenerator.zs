
class MazeGenerator : EventHandler
{
    const MAZE_W = 10;
    const TOTAL_CELLS = MAZE_W*MAZE_W;
    const TEXTURE_W = 128;
    const LINEDEFS_SIZE = MAZE_W*MAZE_W*4;

    int linedefs[LINEDEFS_SIZE];
    int cells[MAZE_W][MAZE_W][4];
    int cellsToLinedefs[MAZE_W][MAZE_W][4];

    const SIDE_TOP = 2;
    const SIDE_RIGHT = 1;
    const SIDE_BOTTOM = 0;
    const SIDE_LEFT = 3;

    const OPENGL_WALLS_NUM = 3;
    const OPENGL_LOGOS_NUM = 2;
    const PLATONIC_SOLIDS_MAX_NUM = 6;
    const THINGS_N = 1 /*player*/ + 1 /*smiley*/ + OPENGL_WALLS_NUM + OPENGL_LOGOS_NUM + PLATONIC_SOLIDS_MAX_NUM;


    PlayerPawn player;
    Array<Actor> actorsToRemove;
    int completedLevels;


    override void PlayerEntered (PlayerEvent e)
    {
        player = players[e.PlayerNumber].mo;
        initCellsToLinedefs();
        restart();
    }


    void restart()
    {
        if (completedLevels > 0) {
            player.A_Print(String.format("Completed levels streak: %d", completedLevels), 2.5, "CONFONT");
        }
        completedLevels++;
        removeAllThings();
        generateMaze();
        applyCellsOnLevel();
        fillThings();
    }

    void removeAllThings()
    {
        while (actorsToRemove.size() != 0)
        {
            Actor a = actorsToRemove[actorsToRemove.size() - 1];
            actorsToRemove.pop();
            a.destroy();
        }
    }

    void generateMaze()
    {
        int x = MAZE_W;
        int y = MAZE_W;
        bool unvis[MAZE_W][MAZE_W];

        //initialize arrays
        for (int i = 0; i < y; i++) {
            for (int j = 0; j < x; j++) {
                for (int k = 0; k < 4; k++) {
                    cells[i][j][k] = 0;
                }
                unvis[i][j] = true;
            }
        }

        //set starting position
        Vector2 currentCell;
        currentCell.x = floor(frandom(0.0, 1.0)*y);
        currentCell.y = floor(frandom(0.0, 1.0)*x);

        Vector2 path[TOTAL_CELLS];
        path[0] = currentCell;
        int path_size = 1;
        unvis[currentCell.x][currentCell.y] = false;
        int visited = 1;


        while (visited < TOTAL_CELLS) {
            //generate array of valid unvisited neighbor cells
            int potential[4][4];
            potential[0][0] = currentCell.x-1;  // bottom
            potential[0][1] = currentCell.y;
            potential[0][2] = 0;
            potential[0][3] = 2;
            potential[1][0] = currentCell.x; // right
            potential[1][1] = currentCell.y+1;
            potential[1][2] = 1;
            potential[1][3] = 3;
            potential[2][0] = currentCell.x+1; // top
            potential[2][1] = currentCell.y;
            potential[2][2] = 2;
            potential[2][3] = 0;
            potential[3][0] = currentCell.x; // left
            potential[3][1] = currentCell.y-1;
            potential[3][2] = 3;
            potential[3][3] = 1;

            int neighbors[4][4];
            int neighbor_size = 0;
            for (int l = 0; l < 4; l++) {
                if (potential[l][0] > -1 && potential[l][0] < y && potential[l][1] > -1 &&
                        potential[l][1] < x && unvis[potential[l][0]][potential[l][1]]) {
                    neighbors[neighbor_size][0] = potential[l][0];
                    neighbors[neighbor_size][1] = potential[l][1];
                    neighbors[neighbor_size][2] = potential[l][2];
                    neighbors[neighbor_size][3] = potential[l][3];
                    neighbor_size += 1;
                }
            }
            //remove the border to a neighboring cell and visit it
            if (neighbor_size != 0) {
                int next[4];
                int random_index = floor(frandom(0.0, 1.0)*neighbor_size);
                next[0] = neighbors[random_index][0];
                next[1] = neighbors[random_index][1];
                next[2] = neighbors[random_index][2];
                next[3] = neighbors[random_index][3];
                cells[currentCell.x][currentCell.y][next[2]] = 1;
                cells[next[0]][next[1]][next[3]] = 1;

                unvis[next[0]][next[1]] = false;
                visited++;

                currentCell.x = next[0];
                currentCell.y = next[1];
                path[path_size] = currentCell;
                path_size += 1;
            } else {
                path_size -= 1;
                currentCell = path[path_size];
            }
        }
        // printCells();
    }


    void initCellsToLinedefs()
    {
        for (int i = 0; i < LINEDEFS_SIZE; i++) {
            int x = level.lines[i].args[0];
            int y = level.lines[i].args[1];
            int cellSide = level.lines[i].args[2];
            cellsToLinedefs[y][x][cellSide] = i;
        }
    }


    void makeLineSolid(int lineIdx)
    {
        Line line = level.lines[lineIdx];
        line.flags |= Line.ML_BLOCKEVERYTHING;
        TextureId wallTexture = TexMan.CheckForTexture("wall", TexMan.Type_Any);
        line.sidedef[Line.front].SetTexture(Side.mid, wallTexture);
        line.sidedef[Line.back].SetTexture(Side.mid, wallTexture);
    }

    void makeLineInvisible(int lineIdx)
    {
        Line line = level.lines[lineIdx];
        line.flags &= ~Line.ML_BLOCKEVERYTHING;
        TextureId noTexture = TexMan.CheckForTexture("-", TexMan.Type_Any);
        line.sidedef[Line.front].SetTexture(Side.mid, noTexture);
        line.sidedef[Line.back].SetTexture(Side.mid, noTexture);
    }

    void applyCellsOnLevel()
    {
        for (int i = 0; i < LINEDEFS_SIZE; i++) {
            linedefs[i] = 1;
        }

        for (int y = 0; y < MAZE_W; y++) {
            for (int x = 0; x < MAZE_W; x++) {
                linedefs[cellsToLinedefs[y][x][0]] = cells[y][x][0]; // top
                linedefs[cellsToLinedefs[y][x][2]] = cells[y][x][2]; // bottom
                linedefs[cellsToLinedefs[y][x][1]] = cells[y][x][1]; // right
                linedefs[cellsToLinedefs[y][x][3]] = cells[y][x][3]; // left
            }
        }

        for (int i = 0; i < LINEDEFS_SIZE; i++) {
            if (linedefs[i] == 0) {
                makeLineSolid(i);
            } else {
                makeLineInvisible(i);
            }
        }
    }


    void fillThings()
    {
        int things[THINGS_N][2];
        int things_current = 0;
        int near_threshold = 1;

        // get random things coordinates

        int x, y, i, j, count = 0;
        bool unique;

        while (count < THINGS_N) {
            x = random(0, MAZE_W - 1);
            y = random(0, MAZE_W - 1);

            unique = true;
            for (i = 0; i < count; i++) {
                if (abs(x - things[i][0]) <= near_threshold && abs(y - things[i][1]) <= near_threshold) {
                    unique = false;
                    break;
                }
            }

            if (unique) {
                things[count][0] = x;
                things[count][1] = y;
                count++;
            }
        }

        // for (int i = 0; i < THINGS_N; i++) {
        //     console.printf("(%d, %d)", things[i][0], things[i][1]);
        // }

        // fill things

        Vector3 playerPos;
        int playerCellX = things[things_current][0];
        int playerCellY = things[things_current][1];
        playerPos.x = (playerCellX + 0.5) * TEXTURE_W;
        playerPos.y = (playerCellY + 0.5) * TEXTURE_W;
        playerPos.z = 0;
        things_current++;
        player.setOrigin(playerPos, true);
        double playerAngle;
        for (int i = 0; i < 4; i++) {
            if (cells[playerCellY][playerCellX][i] != 0) {
                playerAngle = -90 + 90*i;
                player.A_SetAngle(playerAngle);
                break;
            }
        }

        Vector3 startMarkerPos;
        int startMarkerOffset = 50;
        startMarkerPos.x = playerPos.x + startMarkerOffset * cos(playerAngle);
        startMarkerPos.y = playerPos.y + startMarkerOffset * sin(playerAngle);
        startMarkerPos.z = 0.5 * TEXTURE_W;
        Actor a;
        a = Actor.Spawn("StartMarker", startMarkerPos);
        actorsToRemove.push(a);

        Vector3 smileyPos;
        smileyPos.x = (things[things_current][0] + 0.5) * TEXTURE_W;
        smileyPos.y = (things[things_current][1] + 0.5) * TEXTURE_W;
        smileyPos.z = 0.5 * TEXTURE_W;
        things_current++;
        a = Actor.Spawn("Smiley", smileyPos);
        actorsToRemove.push(a);

        TextureId openglWallTexture = TexMan.CheckForTexture("openglwall", TexMan.Type_Any);
        for (int i = 0; i < OPENGL_WALLS_NUM; i++)
        {
            int x = things[things_current][0];
            int y = things[things_current][1];
            things_current++;
            int cellSide;
            while (true) {
                cellSide = random(0, 3);
                if (cells[y][x][cellSide] == 0) break;
            }
            Line line;
            line = level.lines[cellsToLinedefs[y][x][cellSide]];
            line.sidedef[Line.front].SetTexture(Side.mid, openglWallTexture);
            line.sidedef[Line.back].SetTexture(Side.mid, openglWallTexture);
            if (cellSide == SIDE_TOP && (y+1) < MAZE_W) {
                line = level.lines[cellsToLinedefs[y+1][x][SIDE_BOTTOM]];
            }
            if (cellSide == SIDE_BOTTOM && (y-1) >= 0) {
                line = level.lines[cellsToLinedefs[y-1][x][SIDE_TOP]];
            }
            if (cellSide == SIDE_RIGHT && (x+1) < MAZE_W) {
                line = level.lines[cellsToLinedefs[y][x+1][SIDE_LEFT]];
            }
            if (cellSide == SIDE_LEFT && (x-1) >= 0) {
                line = level.lines[cellsToLinedefs[y][x-1][SIDE_RIGHT]];
            }
            line.sidedef[Line.front].SetTexture(Side.mid, openglWallTexture);
            line.sidedef[Line.back].SetTexture(Side.mid, openglWallTexture);
        }


        for (int i = 0; i < OPENGL_LOGOS_NUM; i++)
        {
            Vector3 openglLogoPos;
            openglLogoPos.x = (things[things_current][0] + 0.5) * TEXTURE_W;
            openglLogoPos.y = (things[things_current][1] + 0.5) * TEXTURE_W;
            openglLogoPos.z = 0.5 * TEXTURE_W;
            things_current++;
            a = Actor.Spawn("OpenGLLogo", openglLogoPos);
            actorsToRemove.push(a);
        }


        for (int i = 0; i < PLATONIC_SOLIDS_MAX_NUM; i++)
        {
            Vector3 platonicSolidPos;
            platonicSolidPos.x = (things[things_current][0] + 0.5) * TEXTURE_W;
            platonicSolidPos.y = (things[things_current][1] + 0.5) * TEXTURE_W;
            platonicSolidPos.z = 0.25 * TEXTURE_W;
            things_current++;
            a = Actor.Spawn("PlatonicSolid", platonicSolidPos);
            actorsToRemove.push(a);
        }

    }


}

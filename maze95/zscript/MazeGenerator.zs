
class MazeGenerator : EventHandler
{
    const MAZE_W = 10;
    const TOTAL_CELLS = 100;
    int cells[MAZE_W][MAZE_W][4];
    int cellsToLinedefs[MAZE_W][MAZE_W][4];
    const LINEDEFS_SIZE = (MAZE_W+1)*(MAZE_W)*2;
    int linedefs[LINEDEFS_SIZE];

    override void WorldLoaded(WorldEvent e)
    {
        generateMaze();
        initCellsToLinedefs();
        applyCellsOnLevel();
    }

    void printCells()
    {
        console.printf("cells:");
        for (int i = 0; i < MAZE_W; i++) {
            string line = "";
            for (int j = 0; j < MAZE_W; j++) {
                line = string.format("%s, [%d, %d, %d, %d] ", line, cells[i][j][0], cells[i][j][1], cells[i][j][2], cells[i][j][3]);
            }
            console.printf(line);
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
            potential[0][0] = currentCell.x-1;  // top
            potential[0][1] = currentCell.y;
            potential[0][2] = 0;
            potential[0][3] = 2;
            potential[1][0] = currentCell.x; // right
            potential[1][1] = currentCell.y+1;
            potential[1][2] = 1;
            potential[1][3] = 3;
            potential[2][0] = currentCell.x+1; // bottom
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
        printCells();
    }


    void printCellsToLinedefs() {
        console.printf("cellsToLinedefs:");
        for (int y = 0; y < MAZE_W; y++) {
            for (int x = 0; x < MAZE_W; x++) {
                console.printf("(%d, %d): top=%d, right=%d, bottom=%d, left=%d",
                       x, y,
                       cellsToLinedefs[x][y][0],
                       cellsToLinedefs[x][y][1],
                       cellsToLinedefs[x][y][2],
                       cellsToLinedefs[x][y][3]);
            }
        }
    }


    void initCellsToLinedefs()
    {
        int lineIndex = 0;
        // Initialize horizontal lines
        for (int y = 0; y <= MAZE_W; y++) {
            for (int x = 0; x < MAZE_W; x++) {
                if (y > 0) {
                    cellsToLinedefs[x][y - 1][2] = lineIndex; // bottom side of cell at (x, y-1)
                }
                if (y < MAZE_W) {
                    cellsToLinedefs[x][y][0] = lineIndex; // top side of cell at (x, y)
                }
                lineIndex++;
            }
        }

        // Initialize vertical lines
        for (int x = 0; x <= MAZE_W; x++) {
            for (int y = 0; y < MAZE_W; y++) {
                if (x > 0) {
                    cellsToLinedefs[x - 1][y][1] = lineIndex; // right side of cell at (x-1, y)
                }
                if (x < MAZE_W) {
                    cellsToLinedefs[x][y][3] = lineIndex; // left side of cell at (x, y)
                }
                lineIndex++;
            }
        }
        printCellsToLinedefs();
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
        // for (int y = 0; y < MAZE_W; y++) {
        //     for (int x = 0; x < MAZE_W; x++) {
        //         for (int i = 0; i < 4; i++) {
        //             linedefs[cellsToLinedefs[x][y][i]] = cells[x][y][i];
        //         }
        //     }
        // }

        for (int i = 0; i < 4; i++) {
            linedefs[cellsToLinedefs[0][0][i]] = 1;
            linedefs[cellsToLinedefs[0][1][i]] = 1;
            linedefs[cellsToLinedefs[0][2][i]] = 1;
            linedefs[cellsToLinedefs[0][3][i]] = 1;
            linedefs[cellsToLinedefs[0][4][i]] = 1;
            linedefs[cellsToLinedefs[0][5][i]] = 1;
        }

        for (int i = 0; i < LINEDEFS_SIZE; i++) {
            if (linedefs[i] != 0) {
                makeLineSolid(i);
            } else {
                makeLineInvisible(i);
            }
        }
    }
}

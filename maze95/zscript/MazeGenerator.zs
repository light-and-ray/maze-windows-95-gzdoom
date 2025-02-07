
class MazeGenerator : EventHandler
{
    const MAZE_W = 10;
    const TOTAL_CELLS = 100;
    int cells[MAZE_W][MAZE_W][4];

    override void PlayerEntered(PlayerEvent e)
    {
        PlayerInfo player = players[e.PlayerNumber];
        if (!player) return;
        generateMaze();
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
                next[0] = neighbors[floor(frandom(0.0, 1.0)*neighbor_size)][0];
                next[1] = neighbors[floor(frandom(0.0, 1.0)*neighbor_size)][1];
                next[2] = neighbors[floor(frandom(0.0, 1.0)*neighbor_size)][2];
                next[3] = neighbors[floor(frandom(0.0, 1.0)*neighbor_size)][3];
                cells[currentCell.x][currentCell.y][next[2]] = 1;
                cells[next[0]][next[1]][next[3]] = 1;

                unvis[next[0]][next[1]] = false;
                visited++;

                currentCell.x = next[0];
                currentCell.y = next[1];
                path[path_size] = currentCell;
                path_size += 1;
            } else {
                currentCell = path[path_size-1];
                path_size -= 1;
            }
        }
    }
}

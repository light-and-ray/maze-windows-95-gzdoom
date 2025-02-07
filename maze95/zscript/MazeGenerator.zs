
class MazeGenerator : EventHandler
{
    Array<Array<int> > maze;

    override void PlayerEntered(PlayerEvent e)
    {
        PlayerInfo player = players[e.PlayerNumber];
        if (!player) return;
        generateMaze();
    }

    void generateMaze()
    {
        x = 10;
        y = 10;
        int totalCells = x*y;
        Array<Array<Array<int> > > cells;
        Array<Array<bool> > unvis;

        //initialize arrays
        for (int i = 0; i < y; i++) {
            Array<Array<int> > tmp1;
            cells.push(tmp1);
            Array<bool> tmp2;
            unvis.push(tmp2);
            for (int j = 0; j < x; j++) {
                Array<int> tmp3;
                tmp.pushV(0,0,0,0);
                cells[i][j].push(tmp3);
                unvis[i][j].push(true);
            }
        }

        //set starting position
        Vector2 currentCell = Vector2(floor(frandom(0.0, 1.0)*y), floor(frandom(0.0, 1.0)*x));

        Array<Vector2> path;
        path.push(currentCell);
        unvis[currentCell.x][currentCell.y] = false;
        int visited = 1;


        while (visited < totalCells) {
            //generate array of valid unvisited neighbor cells
            Array<Array<int> > potential;
            Array<int> tmp1;
            tmp1.pushV(currentCell.x-1, currentCell.y, 0, 2); // top
            potential.push(tmp1);
            Array<int> tmp2;
            tmp2.pushV(currentCell.x, currentCell.y+1, 1, 3); // right
            potential.push(tmp2);
            Array<int> tmp3;
            tmp3.pushV(currentCell.x+1, currentCell.y, 2, 0); // bottom
            potential.push(tmp3);
            Array<int> tmp4;
            tmp4.pushV(currentCell.x, currentCell.y-1, 3, 1); // left
            potential.push(tmp4);

            Array<Array<int> > neighbors;
            for (int l = 0; l < 4; l++) {
                if (potential[l][0] > -1 && potential[l][0] < y && potential[l][1] > -1 && potential[l][1] < x && unvis[potential[l][0]][potential[l][1]]) {
                    neighbors.push(potential[l]);
                }
            }
            //remove the border to a neighboring cell and visit it
            if (neighbors.size()) {
                Array<int> next = neighbors[floor(frandom(0.0, 1.0)*neighbors.size())];
                cells[currentCell.x][currentCell.y][next[2]] = 1;
                cells[next[0]][next[1]][next[3]] = 1;

                unvis[next[0]][next[1]] = false;
                visited++;

                currentCell = Vector2(next[0], next[1]);
                path.push(currentCell);
            } else {
                currentCell = path.pop();
            }
        }

        return cells;
    }
}

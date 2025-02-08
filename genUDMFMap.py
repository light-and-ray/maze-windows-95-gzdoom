
from dataclasses import dataclass
import os
import omg

@dataclass
class Line:
    v1: tuple[int]
    v2: tuple[int]
    cellX: int = None
    cellY: int = None
    cellSide: int = None

MAZE_W = 10
TEXTURE_W = 128
LIGHT_LEVEL = 300

def save(lines: list[list[Line]], box: list[Line]):
    vertexes : list[tuple[int]] = []
    def addVertex(newVertex) -> int:
        for i in range(len(vertexes)):
            if vertexes[i] == newVertex:
                return i
        vertexes.append(newVertex)
        return len(vertexes) - 1

    allLines : list[Line] = []
    for lineRow in lines:
        allLines.extend(lineRow)

    udmfMap = omg.UMapEditor()
    udmfMap.namespace = "zdoom"

    sideIdx = 0
    for line in allLines:
        v1Idx = addVertex(line.v1)
        v2Idx = addVertex(line.v2)
        udmfMap.linedefs.append(omg.ULinedef(v1=v1Idx, v2=v2Idx, sidefront=sideIdx, sideback=sideIdx+1))
        udmfMap.linedefs[-1].twosided = True
        udmfMap.linedefs[-1].arg0 = line.cellX
        udmfMap.linedefs[-1].arg1 = line.cellY
        udmfMap.linedefs[-1].arg2 = line.cellSide
        sideIdx += 2
    sideIdx -= 1
    for _ in range(len(udmfMap.sidedefs), sideIdx+1):
        udmfMap.sidedefs.append(omg.USidedef(sector=0))
        udmfMap.sidedefs[-1].texturemiddle = "wall"

    sideIdx += 1
    for line in box:
        v1Idx = addVertex(line.v1)
        v2Idx = addVertex(line.v2)
        udmfMap.linedefs.append(omg.ULinedef(v1=v1Idx, v2=v2Idx, sidefront=sideIdx))
        sideIdx += 1
    sideIdx -= 1
    for _ in range(len(udmfMap.sidedefs), sideIdx+1):
        udmfMap.sidedefs.append(omg.USidedef(sector=0))
        udmfMap.sidedefs[-1].texturemiddle = "black"

    udmfMap.sectors.append(omg.USector(textureceiling="ceiling", texturefloor="floor",
                            heightfloor=0, heightceiling=TEXTURE_W, lightlevel=LIGHT_LEVEL))
    udmfMap.things.append(omg.UThing(x=64, y=64, ednum=1)) # spawn point
    udmfMap.vertexes = [omg.UVertex(*v) for v in vertexes]

    mapName = 'maze95'
    wad = omg.WAD()
    wad.udmfmaps[mapName] = udmfMap.to_lumps()
    wadPath = "maze95/maps/" + mapName + ".wad"
    os.makedirs(os.path.dirname(wadPath), exist_ok=True)
    wad.to_file(wadPath)


def genUDMFMap():
    lines : list[list[Line]] = []
    for x in range(MAZE_W):
        lines.append([])
        for y in range(MAZE_W):
            A = (x*TEXTURE_W, (y+1)*TEXTURE_W)
            B = ((x+1)*TEXTURE_W, (y+1)*TEXTURE_W)
            C = ((x+1)*TEXTURE_W, y*TEXTURE_W)
            D = (x*TEXTURE_W, y*TEXTURE_W)
            lines[x].append(Line(A, B, x, y, 2))
            lines[x].append(Line(B, C, x, y, 1))
            lines[x].append(Line(C, D, x, y, 0))
            lines[x].append(Line(D, A, x, y, 3))

    box : list[Line] = []
    A = (-TEXTURE_W, MAZE_W*TEXTURE_W+TEXTURE_W)
    B = (MAZE_W*TEXTURE_W+TEXTURE_W, MAZE_W*TEXTURE_W+TEXTURE_W)
    C = (MAZE_W*TEXTURE_W+TEXTURE_W, -TEXTURE_W)
    D = (-TEXTURE_W, -TEXTURE_W)

    box.append(Line(A, B))
    box.append(Line(B, C))
    box.append(Line(C, D))
    box.append(Line(D, A))

    save(lines, box)


if __name__ == "__main__":
    genUDMFMap()

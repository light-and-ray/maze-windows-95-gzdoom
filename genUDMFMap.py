
from dataclasses import dataclass
import os
import omg

@dataclass
class Line:
    v1: tuple[int]
    v2: tuple[int]

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
    udmfMap.things.append(omg.UThing(x=0, y=0, ednum=1))
    udmfMap.vertexes = [omg.UVertex(*v) for v in vertexes]

    mapName = 'maze95'
    wad = omg.WAD()
    wad.udmfmaps[mapName] = udmfMap.to_lumps()
    wadPath = "maze95/maps/" + mapName + ".wad"
    os.makedirs(os.path.dirname(wadPath), exist_ok=True)
    wad.to_file(wadPath)


def genUDMFMap():
    lines : list[list[Line]] = []
    num = 0
    for i in range(MAZE_W+1):
        lines.append([])
        for j in range(MAZE_W):
            lines[i].append(Line(v1=(i*TEXTURE_W, j*TEXTURE_W), v2=(i*TEXTURE_W, (j+1)*TEXTURE_W)))
            num += 1
    for i in range(MAZE_W):
        lines.append([])
        for j in range(MAZE_W+1):
            lines[i].append(Line(v1=(i*TEXTURE_W, j*TEXTURE_W), v2=((i+1)*TEXTURE_W, j*TEXTURE_W)))
            num += 1

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

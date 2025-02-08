#
# by meta llama 3.3
#

import math
import os

def generate_icosahedron(radius=1.0):
    # Define the golden ratio
    phi = (1 + math.sqrt(5)) / 2

    # Define the vertices of the icosahedron
    vertices = [
        [-1, phi, 0],
        [1, phi, 0],
        [-1, -phi, 0],
        [1, -phi, 0],
        [0, -1, phi],
        [0, 1, phi],
        [0, -1, -phi],
        [0, 1, -phi],
        [phi, 0, -1],
        [phi, 0, 1],
        [-phi, 0, -1],
        [-phi, 0, 1],
    ]

    # Scale the vertices by the radius
    vertices = [[radius * x, radius * y, radius * z] for x, y, z in vertices]

    # Define the faces of the icosahedron
    faces = [
        [0, 11, 5], [0, 5, 1], [0, 1, 7], [0, 7, 10], [0, 10, 11],
        [1, 5, 9], [5, 11, 4], [11, 10, 2], [10, 7, 6], [7, 1, 8],
        [3, 9, 4], [3, 4, 2], [3, 2, 6], [3, 6, 8], [3, 8, 9],
        [4, 9, 5], [2, 4, 11], [6, 2, 10], [8, 6, 7], [9, 8, 1],
    ]

    return vertices, faces


def generate_octahedron(radius=1.0):
    # Define the vertices of the octahedron
    vertices = [
        [radius, 0, 0],
        [-radius, 0, 0],
        [0, radius, 0],
        [0, -radius, 0],
        [0, 0, radius],
        [0, 0, -radius],
    ]

    # Define the faces of the octahedron
    faces = [
        [0, 2, 4], [0, 4, 3], [0, 3, 5], [0, 5, 2],
        [1, 2, 5], [1, 5, 3], [1, 3, 4], [1, 4, 2],
    ]

    return vertices, faces


def generate_tetrahedron(radius=1.0):
    # Define the vertices of the tetrahedron
    vertices = [
        [radius, radius, radius],
        [radius, -radius, -radius],
        [-radius, radius, -radius],
        [-radius, -radius, radius],
    ]

    # Define the faces of the tetrahedron
    faces = [
        [0, 1, 2],
        [0, 2, 3],
        [0, 3, 1],
        [1, 3, 2],
    ]

    return vertices, faces

RESULT_DIR = "maze95/models/"

def write_to_obj(vertices, faces, filename):
    os.makedirs(RESULT_DIR, exist_ok=True)
    with open(RESULT_DIR+filename, 'w') as f:
        # Write vertices
        for i, (x, y, z) in enumerate(vertices):
            f.write(f"v {x} {y} {z}\n")

        # Write faces
        for face in faces:
            # OBJ file uses 1-based indexing
            face = [str(v + 1) for v in face]
            f.write(f"f {' '.join(face)}\n")


if __name__ == "__main__":
    vertices, faces = generate_icosahedron(radius=1.0)
    write_to_obj(vertices, faces, 'icosahedron.obj')
    vertices, faces = generate_octahedron(radius=1.0)
    write_to_obj(vertices, faces, 'octahedron.obj')
    vertices, faces = generate_tetrahedron(radius=1.0)
    write_to_obj(vertices, faces, 'tetrahedron.obj')

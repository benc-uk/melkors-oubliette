extends Node

# The size in world units of each map cell
const CELL_SIZE = 10
const HALF_CELL_SIZE = CELL_SIZE / 2

# The four cardinal directions
enum COMPASS {NORTH, EAST, SOUTH, WEST}

# These are rotations in radians around Y axis 
# which corrispond to the COMPASS enum 
const DIRECTIONS = [0, -(PI/2), PI, +(PI/2)]

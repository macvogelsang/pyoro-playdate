NUM_BLOCKS = 30
BLOCK_WIDTH = 10

X_LOWER_BOUND = 50 
X_UPPER_BOUND = 350 
Y_LOWER_BOUND = 0
Y_UPPER_BOUND = 228

Y_RANGE = Y_UPPER_BOUND - Y_LOWER_BOUND
SCORE_SECTION_HEIGHT = Y_RANGE / 5

LEFT, RIGHT = -1, 1

REFRESH_RATE = 30
FRAME_LEN = REFRESH_RATE / 30 -- how many 30 fps frames long is a frame?
DT =  1/30

COLLIDE_PLAYER_GROUP, COLLIDE_TONGUE_GROUP, COLLIDE_BLOCK_GROUP = 1, 2, 3

gfx = playdate.graphics

--[[

See you later!
Take a break!
Better luck next time.
Ouch!


]]--
NUM_BLOCKS = 30
BLOCK_WIDTH = 10

X_LOWER_BOUND = 50 
X_UPPER_BOUND = 350 
Y_LOWER_BOUND = 0
Y_UPPER_BOUND = 228
PLAY_AREA_WIDTH = 300

Y_RANGE = Y_UPPER_BOUND - Y_LOWER_BOUND
SCORE_SECTION_HEIGHT = Y_RANGE / 5

LEFT, RIGHT = -1, 1

-- hit constants
GROUND, NONGROUND, SPIT = 1, 2, 3

REFRESH_RATE = 30
FRAME_TIME_SEC = 1/REFRESH_RATE
FRAME_LEN = REFRESH_RATE / 30 -- how many 30 fps frames long is a frame?
DT =  1/REFRESH_RATE

COLLIDE_PLAYER_GROUP, COLLIDE_TONGUE_GROUP, COLLIDE_BLOCK_GROUP, COLLIDE_FOOD_GROUP, COLLIDE_NOTHING_GROUP = 1, 2, 3, 4, 5

STARTING_FOOD_PARAMS = {
    slow = {chance=0.7, speed=25},
    med = {chance=0.3, speed=33},
    fast = {chance=0, speed=0},
}
BNB1, BNB2 = 'bnb1', 'bnb2'

BAGEL_MODE = false 

gfx = playdate.graphics
SCORE_FONT = gfx.font.new('img/fonts/space-harrier2')

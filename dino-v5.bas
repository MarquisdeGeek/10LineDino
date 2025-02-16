# Contents:
# 1       : Score
# 2       : Lives
# 3       : Dino legs animation frame (toggles between 1 and 5)
# 4       : Jump state (A=chr$ 38 = none)
# 5       : Player Y, as a CODE character (base of > is 18)
# 6       : Position of ground, as CODE, starts at 13 ($)
# (was 12 until I switched chr$(12) to £ so it fit on a line, and realised text2p breaks and substitutes TAB for £)
# 7       : Blank for cleaner lives rendering
# 8 to 10  : Gf\;; for the 3 lives
# 12      : Map data
1 LET a$=" \''\' A>$ \ :\ :\ :_ \,,\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\,,\;;\;;\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\;;\;;\;;\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\,,\;;\;;\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\;;\;;\;;\,,\,,\,,\,,\;;"

# COmbines both state variables and level data.
# THe level data is repeated twice, so the renderer can simply print A TO B, without having
# to consider wrapping around, and our update loop doesn't need to process a moving pattern

# Game loop, when score/lives have changed

# Update the score/lives if there's a cactii underfoot
# The final AT causes a divide by zero error. This stops the game. It also shortens the GOTO
# statement at 10 (improving speed), and ensures the lives count is cleared to 0 when the player
# is finally dead.
2 print at 0,0;"Score: "; code a$(1);at 0,15;"Lives:";a$(7 to 7+code a$(2));"  ";at (1 / code a$(2)),0;

# Lives count is rendered graphically, with trailing spaces to erase the previous lives counter, if it has been
# decremented since the last iteration of the loop
# Note that the two spaces remove the dinos head, when falling after a jump. IN all other cases
# the instruction is benign.


# Update the dino if he's jumping
3  print at code a$(5)-6,2;"  ",,"  \:'\::",,"  \::\;;",,"\. \ .\::\''",,"\:.\::\::\':",,"\ '\:'\': "
#; at 8,0;code a$(1);at 0,22;code a$(2)


# Game loop, when nothing's changed

# Render ground
# (plus dino feet, done here to even out the line lengths)
# To save 1 byte, the last blank of the first set of feet gets re-used to be the first blank of the second frame of feet
4  print at code a$(5),not pi;  " \:.\ '\'  \''\ :\. "(code a$(3) to code a$(3)+3) ,,"    "; at 18,4;a$(CODE a$(6) TO CODE a$(6)+27)

# ($2 is the refresh flag)
# R is a refresh flag, indcating you're over a cacti
# Done because: line 6 was too long, and using a var _seems_ quicker that the a$(CODE()) pattern
# Seems a waste to have such a short line, but the original code was only 9, so I don't feel so bad about it
# Also note, I check against the data from the array. I could have placed them in specific places (e.g. multiples of 5, to eliminate
# the array reference, but wanted to keep the game fully data-driven)
# The -1 is because we draw the ground at X=4 to stop flickering between dino/ground. So the collision is one space back
# from the first drawn elemement.
5 let r=(A$(CODE a$(6)-SGN pi)="\;;")


# Update both player states: score, lives
# The third bit toggles A$(3) between 1 and 5, the dino leg graphics
6 lET A$(1 TO 3)=chr$( code A$(1)+(r and a$(5) <> ">") ) + chr$( code a$(2)-(r and a$(5) = ">") ) + chr$(6-code a$(3))



# Change jump state: a combination of
# Pressed Q? + increment, if jumping + reset to 'no jump'
7 let a$(4) = chr$(CODE A$(4) + (inkey$="Q" AND A$(4) = "A") + (A$(4) > "A" AND A$(4) < "G") + -6*( A$(4) = "G"))

# Change the player height, if in first few jump states, or dec thereafter
# Use CODE("letter") because it might be slightly quicker that using explicit integer constants
8 let a$(5) = CHR$(code a$(5) - ( A$(4) > ("A") and  A$(4) < ("E")) + (A$(4) > ("D")))

# Scroll the ground to the next position
# sgn pi being 1
9 LET a$(6) = chr$ (sgn pi+  CODE a$(6)*(a$(6) < ("G")) + (12*( a$(6) > ("F"))) )

# Either GOTO line
# 4 : Normal
# 4-2 = 2 : Score or lives need updating (because R refresh flag is set)
# 4-1 = 3 : Because dino is not on ground (i.e.jumping)
# 4+50 = 54 : Game ends

# Dino refresh is needed when jumping, or just landed
# (Checking Y doesn't help, because y=18 is indistinguishable from normal walk)
10 goto 3 -r + (not r and a$(4)="A") 

# Originally this line was 4-2*r-1r=0 etc) but changed to be 3 plus/minus one to remove the calculations
# So the logic needed to be inverted from 'player not on ground, GOTO 4-1' to 'player on ground, goto 3+1'

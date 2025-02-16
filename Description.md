
# Variables

* A$ : The level data
* R : Refresh flag

Because the ZX81 only allows one instruction per line, each new variable requires a LET statement. Consequently, every other variable is "hidden" inside A$ and converted to an int with, e.g. CODE A$(1)

A$(0) : (invalid, ZX strings count from 1)
A$(1) : Score
A$(2) : Lives
A$(3) : Animation frame of dino legs (toggles between 1 and 5)
A$(4) : Jump state (A=chr$ 38 = none)
A$(5) : Player Y, as a CODEd character (> is 18)
A$(6) : Position of ground, as CODE, starts at 13 ($)
A$(7) : Unused - used for cleaner lives rendering code
A$(8 TO 10) : Graphics for the 3 lives counter
A$(12 TO end) : Map data



# The Code

```
1 LET a$=" \''\' A>$ \ :\ :\ :_ \,,\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\,,\;;\;;\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\;;\;;\;;\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\,,\;;\;;\,,\,,\,,\,,\;;\,,\,,\,,\,,\,,\;;\;;\;;\,,\,,\,,\,,\;;"
```
Initialise everything! This combines both state variables and level data.
The level data is repeated twice, so the renderer can simply print A TO B, without having
to consider wrapping around, and our update loop doesn't need to process a moving pattern

Note the symbols here are converted by zxmakebas into the ZX81 graphic characters, as seen in the listing image(s).

```
2 PRINT AT 0,0;"Score: "; CODE A$(1);at 0,15;"Lives:";A$(7 to 7+CODE A$(2));"  ";at (1 / CODE A$(2)),0;
```
Start of the game loop, if either score or lives count has changed. This happens if there's a cactii underfoot.

Print the top row of stats.

The final AT causes a divide by zero error. This stops the game. It also shortens the GOTO
statement at line 10 (improving speed), and ensures the lives count is cleared to 0 when the player
is finally dead.

The lives count is rendered graphically, with trailing spaces to erase the previous lives counter, if it has been
decremented since the last iteration of the loop
Note that the two spaces remove the dinos head, when falling after a jump. In all other cases
the instruction is benign.


```
3 PRINT AT CODE A$(5)-6,2;"  ",,"  \:'\::",,"  \::\;;",,"\. \ .\::\''",,"\:.\::\::\':",,"\ '\:'\': "
```
Start of the game loop, if the dino is jumping.

Print the dino at the appropriate Y position. (Note, co-ords are AT Y,X)



```
4 PRINT AT CODE A$(5),not pi;  " \:.\ '\'  \''\ :\. "(CODE A$(3) to CODE A$(3)+3) ,,"    "; at 18,4;A$(CODE A$(6) TO CODE A$(6)+27)
```
Start of the game loop, if nothing (other than the ground) has changed

Render ground plus dino feet, done here to even out the line lengths.

To save 1 byte, the last blank of the first set of feet gets re-used to be the first blank of the second frame of feet.


```
5 LET R=(A$(CODE A$(6)-SGN pi)="\;;")
```
R is a refresh flag, indcating you're over a cacti.
This is done because line 6 was too long, and using a var _seems_ quicker that the a$(CODE()) pattern.
Seems a waste to have such a short line, but the original code was only 9, so I don't feel so bad about it.
Also note, I check against the data from the array. I could have placed them in specific places (e.g. multiples of 5, to eliminate
the array reference, but wanted to keep the game fully data-driven)
The -1 is because we draw the ground at X=4 to stop flickering between dino/ground. So the collision is one space back
from the first drawn elemement.


```
6 LET A$(1 TO 3)=CHR$( CODE A$(1)+(R and A$(5) <> ">") ) + CHR$( CODE A$(2)-(R and A$(5) = ">") ) + CHR$(6-CODE A$(3))
```
Update both player states - score and lives - with three string concenations. The third part toggles A$(3) between 1 and 5, the dino leg graphics. Uses the standard "r AND a$()" that evaluates to True or False, and interpreted as 1 or 0.


```
7 LET A$(4) = CHR$(CODE A$(4) + (INKEY$="Q" AND A$(4) = "A") + (A$(4) > "A" AND A$(4) < "G") + -6*( A$(4) = "G"))
```
Change the jump state: a combination of "Pressed Q?" and increment of Y if jumping, or a reset to 'no jump' if landed via the -6*(check for true state)

```
8 LET A$(5) = CHR$(CODE A$(5) - ( A$(4) > ("A") and  A$(4) < ("E")) + (A$(4) > ("D")))
```
Change the player height, if in first few jump states, or decrement thereafter.
Use CODE("letter") because it might be slightly quicker that using explicit integer constants.

```
9 LET A$(6) = CHR$ (sgn pi+  CODE A$(6)*(A$(6) < ("G")) + (12*( A$(6) > ("F"))) )
```
Scroll the ground to the next position. sgn pi is a quicker and shorter way to indicate the constant, 1.

```
10 GOTO 3 -r + (not R and A$(4)="A") 
```
Jump back to the game loop. This line is either:
* 4 : Normal loop
* 4-2 = 2 : Score or lives need updating (because R refresh flag is set)
* 4-1 = 3 : Because dino is not on ground (i.e.jumping)




# Resources

Online version : https://em.ulat.es/machines/SinclairZX81/?load=dino

Playback video : https://youtu.be/8MCIswYqDqI




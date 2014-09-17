Color_Tracker_Server
================

This application tracks the average locations of pixels that match a few specified colors in two camera feeds as (x,y) coordinates. If the cameras are arranged properly, the two camera feeds could actually be representative of a 3D space in the real world, where you could be tracking an object on the x, y, and z planes. A good setup is one camera straight on (x, y) and one camera from the right (y, z).

It then serves three ints (x, y and z), over and over again in a string "x, y, z". To interface with it, you must use a client application that receives the string of ints appropriately.

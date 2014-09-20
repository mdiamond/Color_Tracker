Goldfish_Tracker
================

Tracks a fish as (x, y, z) coordinates and renders it in a 3D space

##Usage

1. Run the server sketch on a machine with two USB cameras attached to it. The first image displayed will be from the camera to be used for the (x,y) coordinates.
2. Click to select up to 8 colors to track from the image. When finished, press any key to move on to configuration of the camera tracking the (z) coordinate.
3. Again, select up to 8 colors to track. When finished, press any key, and the program will begin serving the average location of your tracked colors as x:1 ratios of the location within the image to the size of the image.
4. Run any client sketch that receives these coordinates appropriately and render anything you want using an objects location.

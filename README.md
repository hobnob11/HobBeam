# HobBeam
A Wiremod Expression2 Extension

---- H2D ---

	|----------------------------------------------------------| -this table is confusing as shit so here goes
	|                     H2DBeamTable{}                       | This table is global to all e2's for everyone on the server
	|----------------------------------------------------------| it contains a table of all of the e2's that have created beams
	|  ["ownerE2"]=1   |   ["ownerE2"]=2   |   ["ownerE2"]=3   |-these tables are stored using the related e2 entity index's as keys 
	|------------------|-------------------|-------------------| and contain all of the information for the beams that that e2 has created 
	|    ["index"]=1   |    ["index"]=1    |    ["index"]=1    |
	|    ["index"]=2   |    ["index"]=2    |    ["index"]=2    | -The individual beams are stored as tables with the beams index as the key.
	|    ["index"]=3   |    ["index"]=3    |    ["index"]=3    | the individual args (startPos,color etc..) are stored in this table with a 
	|    ["index"]=4   |    ["index"]=4    |    ["index"]=4    | string of the name of the arg as the key. 

E2 Functions: 

createH2DBeam(number Index, vector StartPos, vector EndPos, number Width, string Texture, number Scale, vector4 Color)

	Index    - much like holo indexes or egp indexes, just used to reference the beam
	StartPos - the vector that the beam starts drawing at
	EndPos   - the vector that the beam stops at
	Width    - the Width of the beam
	Texture  - The file path of the texture to be used (see garrysmod_dir.vpk/cable/ for examples)
	Scale    - the beam is the same square image repeated in a line, scale is the height of the image. 
	Color    - Sets the render color - note: not all textures support changing colours


setH2DBeamPos(number Index, vector StartPos, vector EndPos)

	-Updates the beam specified by Index's starting and ending vectors. (see above)


setH2DBeamColor(number Index, vector4 Color)

	-Updates the beam specified by Index's Color. (see above)


killH2DBeam(number Index)

	-Kills the beam with given index. (makes it go away for eeeveeer)

// Meshing parameters
Mesh.ElementOrder = 1;
Mesh.SecondOrderLinear = 0;


// Define point parameters
sizing = 0.03;

/* X = 0.1
Y = 0.2 */


/* MESH AND NODE LAYOUT
12-----------------------------------------11
|                                         |
|                                         |
|       3-----4           7-----8         |
|       |     |           |     |         |
|       |     |           |     |         |
1-------2     5-----------6     9---------10
*/

// Build points
Point(1) = {0,0,0, sizing};
Point(2) = {0.1,0,0, sizing};
Point(3) = {0.1+X,0.1+Y,0, sizing};
Point(4) = {0.2,0.1,0, sizing};
Point(5) = {0.2,0,0, sizing};
Point(6) = {0.4,0,0, sizing};
Point(7) = {0.4,0.1,0, sizing};
Point(8) = {0.5-X,0.1-Y,0, sizing};
Point(9) = {0.5,0,0,sizing};
Point(10) = {0.6,0,0,sizing};
Point(11) = {0.6,0.2,0,sizing};
Point(12) = {0,0.2,0,sizing};

// Build lines between points:
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 9};
Line(9) = {9,10};
Line(10) = {10,11};
Line(11) = {11,12};
Line(12) = {12,1};

// Turn lines into a loop and turn loop into bounded surface
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8,9,10,11,12};
Plane Surface(1) = {1};

// Assign names to domains
Physical Surface("fluid") = {1};

Physical Line("inlet") = {12};
Physical Line("outlet") = {10};
Physical Line("no_slip") = {1, 2,3,4, 5,6, 7,8,9,11};

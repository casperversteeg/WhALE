// Meshing parameters
Mesh.ElementOrder = 2;
Mesh.SecondOrderLinear = 0;


// Define point parameters
sizing = 0.003;

// Build points
Point(1) = {0,0,0, sizing};
Point(2) = {0.0495,0,0, sizing};
Point(3) = {0.0495,0.0195,0, sizing};
Point(4) = {0.0505,0.0195,0, sizing};
Point(5) = {0.0505,0,0, sizing};
Point(6) = {0.1,0,0, sizing};
Point(7) = {0.1,0.02,0, sizing};
Point(8) = {0,0.02,0, sizing};

// Build lines between points:
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 1};

// Turn lines into a loop and turn loop into bounded surface
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};

// Assign names to domains
Physical Surface("fluid") = {1};

Physical Line("inlet") = {8};
Physical Line("outlet") = {6};
Physical Line("no_slip") = {1, 5, 7};
Physical Line("dam_left") = {2};
Physical Line("dam_top") = {3};
Physical Line("dam_right") = {4};

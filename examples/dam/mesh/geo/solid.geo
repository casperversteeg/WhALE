// Meshing parameters
Mesh.ElementOrder = 2;
Mesh.SecondOrderLinear = 0;


// Define point parameters
sizing = 0.001;

// Build points
Point(1) = {0.0495,0,0, sizing};
Point(2) = {0.0495,0.01,0, sizing};
Point(3) = {0.0505,0.01,0, sizing};
Point(4) = {0.0505,0,0, sizing};

// Build lines between points:
Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 1};

// Turn lines into a loop and turn loop into bounded surface
Line Loop(1) = {1, 2, 3, 4};
Plane Surface(1) = {1};

// Assign names to domains
Physical Surface("solid") = {1};

Physical Line("fixed") = {4};
Physical Line("left") = {1};
Physical Line("top") = {2};
Physical Line("right") = {3};

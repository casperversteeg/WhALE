// Meshing parameters
Mesh.ElementOrder = 2;
Mesh.SecondOrderLinear = 0;


// Define point parameters
sizing = 0.003;

// Build points
Point(1) = {0.12,0,0, sizing};
Point(2) = {0.135,0.01,0, sizing};
Point(3) = {0.14,0,0, sizing};
Point(4) = {0.14,0.03,0, sizing};
Point(5) = {0.135,0.02,0, sizing};
Point(6) = {0.12,0.03,0, sizing};

// Build lines between points: (VF = vocal fold)
Spline(1) = {1, 2, 3};  // lower VF fluid face
Line(2) = {3, 1};       // lower VF fixed face
Spline(3) = {4, 5, 6};  // upper VF fluid face
Line(4) = {6, 4};       // upper VF fixed face

// Turn lines into a loop and turn loop into bounded surface
Line Loop(1) = {1, 2};
Plane Surface(1) = {1};
Line Loop(2) = {3, 4};
Plane Surface(2) = {2};

// Assign names to domains
Physical Surface("LowerVF") = {1};
Physical Surface("UpperVF") = {2};

Physical Line("fixed") = {2, 4};
Physical Line("no_slip") = {1, 2};

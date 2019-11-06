// Meshing parameters
Mesh.ElementOrder = 2;
Mesh.SecondOrderLinear = 0;


// Define point parameters
sizing = 0.003;

// Build points
Point(1) = {0,0,0, sizing};
Point(2) = {0.12,0,0, sizing};
Point(3) = {0.135,0.01,0, sizing};
Point(4) = {0.14,0,0, sizing};
Point(5) = {0.3,0,0, sizing};
Point(6) = {0.3,0.03,0, sizing};
Point(7) = {0.14,0.03,0, sizing};
Point(8) = {0.135,0.02,0, sizing};
Point(9) = {0.12,0.03,0, sizing};
Point(10) = {0,0.03,0, sizing};

// Build lines between points: (VF = vocal fold)
Line(1) = {1, 2};       // Bottom before VF
Spline(2) = {2, 3, 4};  // VF bottom
Line(3) = {4, 5};       // Bottom after VF
Line(4) = {5, 6};       // Outlet line
Line(5) = {6, 7};       // Top after VF
Spline(6) = {7, 8 , 9}; // VF top
Line(7) = {9, 10};      // Top before VF
Line(8) = {10, 1};      // Inlet line

// Turn lines into a loop and turn loop into bounded surface
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};

// Assign names to domains
Physical Surface("fluid") = {1};

Physical Line("inlet") = {8};
Physical Line("outlet") = {4};
Physical Line("no_slip") = {1, 3, 5, 7};
Physical Line("vocal_folds") = {2, 6};

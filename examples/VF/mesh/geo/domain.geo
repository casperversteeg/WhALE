// Meshing parameters
Mesh.ElementOrder = 2;
Mesh.SecondOrderLinear = 0;


// Define point parameters
sizing = 0.003;

// Build points
Point(1) = {0,0,0, sizing};
Point(2) = {0.04,0,0, sizing};
Point(3) = {0.055,0.01,0, sizing};
Point(4) = {0.06,0,0, sizing};
Point(5) = {0.1,0,0, sizing};
Point(6) = {0.1,0.03,0, sizing};
Point(7) = {0.06,0.03,0, sizing};
Point(8) = {0.055,0.02,0, sizing};
Point(9) = {0.04,0.03,0, sizing};
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
Line(9) = {4, 2};       // Lower VF fix
Line(10) = {9, 7};      // Upper VF fix

// Turn lines into a loop and turn loop into bounded surface
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};
Line Loop(2) = {2, 9};
Line Loop(3) = {6, 10};
Plane Surface(2) = {2};
Plane Surface(3) = {3};

// Assign names to domains
Physical Surface("fluid") = {1};
Physical Surface("VF") = {2, 3};

Physical Line("inlet") = {8};
Physical Line("outlet") = {4};
Physical Line("no_slip") = {1, 3, 5, 7};
Physical Line("fixed") = {9, 10};
Physical Line("VF_fsi") = {2, 6};

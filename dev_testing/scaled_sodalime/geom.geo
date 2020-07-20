// Meshing parameters
Mesh.ElementOrder = 1;
// Mesh.SecondOrderLinear = 0;a = 8;
d = 0.3;
h = 31;
h2 = 23;
D = 6.9154;
H = 150;
W = 100;

ref_opp = 20;

E = 2;
e = 0.2;
e1 = 0.2;

Point(1) = {-h2, 0, 0, e};              // Center crack
Point(2) = {-h, 0, 0, e};            // Top right V
Point(3) = {-W/2, D, 0, e};            // Top left V
Point(4) = {-W/2, ref_opp, 0, e};
Point(5) = {-W/2, H/2, 0, E};           // Top left
Point(6) = {W/2, H/2, 0, e1};           // Top right
Point(7) = {W/2, ref_opp, 0, e};       // Top-top right band
Point(8) = {W/2, 0, 0, e};             // Center right

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Line(4) = {4, 5};
Line(5) = {5, 6};
Line(6) = {6, 7};
Line(7) = {7, 8};
Line(8) = {8, 1};
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8};
Plane Surface(1) = {1};

Line(9) = {4, 7};
Line{9} In Surface {1};

Physical Surface("all") = {1};
Physical Line("top") = {5};
Physical Line("center") = {8};
Physical Line("left") = {3, 4};
Physical Line("right") = {6, 7};
Physical Line("load") = {2};

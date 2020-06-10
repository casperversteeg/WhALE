// Meshing parameters
Mesh.ElementOrder = 1;
// Mesh.SecondOrderLinear = 0;

a = 8e-3;
d = 0.3e-3;
h = 31e-3;
h2 = 23e-3;
D = 6.9154e-3;
H = 0.15;
W = 0.1;

E = 0.005;
e = 0.0002;

Point(1) = {-W/2, -H/2, 0, E};
Point(2) = {-W/2, -D, 0, E};
Point(3) = {-h, -d/2, 0, E};
Point(4) = {-h2, -d/2, 0, e};
Point(5) = {-h2, 0, 0, e};
Point(6) = {-h2, d/2, 0, e};
Point(7) = {-h, d/2, 0, E};
Point(8) = {-W/2, D, 0, E};
Point(9) = {-W/2, H/2, 0, E};
Point(10) = {W/2, H/2, 0, E};
Point(11) = {W/2, 5*d/2, 0, e};
Point(12) = {W/2, -5*d/2, 0, e};
Point(13) = {W/2, -H/2, 0, E};
Point(14) = {-h2, 5*d/2, 0, e};
Point(15) = {-h2, -5*d/2, 0, e};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 4};
Circle(4) = {4, 5, 6};
Line(5) = {6, 7};
Line(6) = {7, 8};
Line(7) = {8, 9};
Line(8) = {9, 10};
Line(9) = {10, 11};
Line(10) = {11, 12};
Line(11) = {12, 13};
Line(12) = {13, 1};
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
Line(13) = {11, 14};
Line(14) = {12, 15};

Plane Surface(1) = {1};
Line{13, 14} In Surface {1};

Physical Surface("all") = {1};
Physical Line("top") = {8};
Physical Line("bottom") = {10};
Physical Line("left") = {1, 7};
Physical Line("right") = {9};
Physical Line("load_bottom") = {2};
Physical Line("load_top") = {6};

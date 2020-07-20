Mesh.ElementOrder = 1;

sizing = 10;
c = 0.175;
d = 1e-3;

Point(1) = {0, 0, 0, sizing};
Point(2) = {100, 0, 0, sizing};
Point(3) = {100, 100, 0, sizing};
Point(4) = {0, 100, 0, sizing};
Point(5) = {0, 25+d, 0, sizing};
Point(6) = {50, 25, 0, c};
Point(7) = {0, 25-d, 0, sizing};

Point(8) = {51, 24, 0, c};
Point(9) = {49, 26, 0, c};
Point(10) = {85, 100, 0, c};
Point(11) = {90, 100, 0, c};

Line(1) = {1, 2};
Line(2) = {2, 3};
Line(3) = {3, 11};
Line(4) = {11, 10};
Line(5) = {10, 4};
Line(6) = {4, 5};
Line(7) = {5, 6};
Line(8) = {6, 7};
Line(9) = {7, 1};
Line Loop(1) = {1, 2, 3, 4, 5, 6, 7, 8, 9};
Plane Surface(1) = {1};

Line(10) = {8,11};
Line(11) = {9,10};
Line(12) = {9,6};
Line(13) = {8,6};
Line{10, 11, 12, 13} In Surface {1};

Physical Surface("all") = {1};
Physical Line("load") = {9};
Physical Line("bottom") = {1};

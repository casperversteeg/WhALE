a = 120;
b = 50;
e = 5;

aa = 80;
bb = 2;
ee = 0.8;

Point(1) = {-a/2,-b/2,0,e};
Point(2) = {-a/2,b/2,0,e};
Point(3) = {a/2,b/2,0,e};
Point(4) = {a/2,-b/2,0,e};

Point(5) = {-aa/2,-bb/2,0,ee};
Point(6) = {-aa/2,bb/2,0,ee};
Point(7) = {aa/2,bb/2,0,ee};
Point(8) = {aa/2,-bb/2,0,ee};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};

Line(5) = {5,6};
Line(6) = {6,7};
Line(7) = {7,8};
Line(8) = {8,5};

Line Loop(1) = {1,2,3,4};
Line Loop(2) = {5,6,7,8};

Plane Surface(1) = {1,2};

Physical Surface("fluid") = {1};

Physical Line("left") = {1};
Physical Line("right") = {3};
Physical Line("top") = {2};
Physical Line("bottom") = {4};

Physical Line("structure_left") = {5};
Physical Line("structure_right") = {7};
Physical Line("structure_top") = {6};
Physical Line("structure_bottom") = {8};

Physical Point("corner") = {1};

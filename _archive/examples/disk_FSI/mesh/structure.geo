aa = 80;
bb = 2;
ee = 0.7;

Point(1) = {-aa/2,-bb/2,0,ee};
Point(2) = {-aa/2,bb/2,0,ee};
Point(3) = {aa/2,bb/2,0,ee};
Point(4) = {aa/2,-bb/2,0,ee};

Point(5) = {-aa/4,0,0,ee};
Point(6) = {0,0,0,ee};
Point(7) = {aa/4,0,0,ee};

Line(1) = {1,2};
Line(2) = {2,3};
Line(3) = {3,4};
Line(4) = {4,1};

Line Loop(1) = {1,2,3,4};

Plane Surface(1) = {1};
Point{5,6,7} In Surface{1};

Physical Surface("structure") = {1};

Physical Line("left") = {1};
Physical Line("right") = {3};
Physical Line("top") = {2};
Physical Line("bottom") = {4};

Physical Point("left_point") = {5};
Physical Point("center") = {6};
Physical Point("right_point") = {7};
Physical Point("top_right") = {3};

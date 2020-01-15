// Meshing parameters
SetFactory("OpenCASCADE");
D = 1;

Mesh.ElementOrder = 2;
Mesh.SecondOrderLinear = 0;
Mesh.Algorithm = 5; // QUAD
Mesh.Smoothing = 10;
Mesh.CharacteristicLengthMin = 0.1*D;
Mesh.CharacteristicLengthMax = 0.1*D;


// Build points
Rectangle(1) = {-2*D, -2.05*D, 0, 11*D, 4.1*D, 0};
Disk(5) = {0, 0, 0, 0.5*D};
Rectangle(6) = {0.489897,-0.1*D, 0, 3.5*D,0.2*D,0};
un[] = BooleanUnion{Surface{5};Delete;}{Surface{6};Delete;};
Physical Surface("solid") = {3, 1, 2};

BooleanDifference{ Surface{1}; Delete; }{ Surface{3}; Delete; }
BooleanDifference{ Surface{1}; Delete; }{ Surface{4}; Delete; }
BooleanDifference{ Surface{3}; Delete; }{ Surface{2}; Delete; }
Recursive Delete {
  Surface{4};
}

Recombine Surface {3};

Physical Line("no_slip") = {10,13};
Physical Line("dam") = {15,16,17};
Physical Line("inlet") = {11};
Physical Line("outlet") = {12};
Physical Line("fixed") = {14};

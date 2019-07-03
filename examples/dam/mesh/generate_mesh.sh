#!/bin/bash

MSH_DIR="/home/casperversteeg/MOOSE/whale/examples/dam/mesh"

gmsh $MSH_DIR/geo/fluid.geo -2 -o $MSH_DIR/fluid.msh
gmsh $MSH_DIR/geo/solid.geo -2 -o $MSH_DIR/solid.msh

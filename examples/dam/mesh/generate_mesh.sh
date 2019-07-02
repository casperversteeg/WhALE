#!/bin/bash

gmsh geo/fluid.geo -2 -o fluid.msh
gmsh geo/solid.geo -2 -o solid.msh

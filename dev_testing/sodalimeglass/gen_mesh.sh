#!/bin/bash

rm *.msh

gmsh geom.geo -2 -o geom.msh

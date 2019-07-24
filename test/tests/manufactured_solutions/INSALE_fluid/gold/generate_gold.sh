#!/bin/bash

mpirun -n 4 ../../../../../whale-opt -i ../INSALE_convergence_test.i Outputs/file_base=4x4 Mesh/nx=4 Mesh/ny=4
mpirun -n 4 ../../../../../whale-opt -i ../INSALE_convergence_test.i Outputs/file_base=8x8 Mesh/nx=8 Mesh/ny=8
mpirun -n 4 ../../../../../whale-opt -i ../INSALE_convergence_test.i Outputs/file_base=16x16 Mesh/nx=16 Mesh/ny=16
mpirun -n 4 ../../../../../whale-opt -i ../INSALE_convergence_test.i Outputs/file_base=32x32 Mesh/nx=32 Mesh/ny=32

#!/bin/bash

mpirun -n 4 ../../../../../whale-opt -i ../INS_vanilla_convergence.i Outputs/file_base=4x4 Mesh/nx=4 Mesh/ny=4
mpirun -n 4 ../../../../../whale-opt -i ../INS_vanilla_convergence.i Outputs/file_base=16x16 Mesh/nx=16 Mesh/ny=16
mpirun -n 4 ../../../../../whale-opt -i ../INS_vanilla_convergence.i Outputs/file_base=64x64 Mesh/nx=64 Mesh/ny=64
mpirun -n 4 ../../../../../whale-opt -i ../INS_vanilla_convergence.i Outputs/file_base=128x128 Mesh/nx=128 Mesh/ny=128
mpirun -n 4 ../../../../../whale-opt -i ../INS_vanilla_convergence.i Outputs/file_base=256x256 Mesh/nx=256 Mesh/ny=256
mpirun -n 4 ../../../../../whale-opt -i ../INS_vanilla_convergence.i Outputs/file_base=1024/1024 Mesh/nx=1024 Mesh/ny=1024

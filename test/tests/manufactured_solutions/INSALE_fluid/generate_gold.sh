#!/bin/bash

mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=4x4_alpha_1e-6 Mesh/nx=4 Mesh/ny=4 GlobalParams/alpha=1e-6
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=8x8_alpha_1e-6 Mesh/nx=8 Mesh/ny=8 GlobalParams/alpha=1e-6
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=16x16_alpha_1e-6 Mesh/nx=16 Mesh/ny=16 GlobalParams/alpha=1e-6
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=32x32_alpha_1e-6 Mesh/nx=32 Mesh/ny=32 GlobalParams/alpha=1e-6

mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=4x4_alpha_1e-3 Mesh/nx=4 Mesh/ny=4 GlobalParams/alpha=1e-3
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=8x8_alpha_1e-3 Mesh/nx=8 Mesh/ny=8 GlobalParams/alpha=1e-3
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=16x16_alpha_1e-3 Mesh/nx=16 Mesh/ny=16 GlobalParams/alpha=1e-3
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=32x32_alpha_1e-3 Mesh/nx=32 Mesh/ny=32 GlobalParams/alpha=1e-3

mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=4x4_alpha_1e0 Mesh/nx=4 Mesh/ny=4 GlobalParams/alpha=1e0
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=8x8_alpha_1e0 Mesh/nx=8 Mesh/ny=8 GlobalParams/alpha=1e0
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=16x16_alpha_1e0 Mesh/nx=16 Mesh/ny=16 GlobalParams/alpha=1e0
mpirun -n 4 ../../../../whale-opt -i INSALE_convergence_test.i Outputs/file_base=32x32_alpha_1e0 Mesh/nx=32 Mesh/ny=32 GlobalParams/alpha=1e0

#!/bin/bash

mpirun -n 2 ../../../../whale-opt -i INS_steady.i
mpirun -n 2 ../../../../whale-opt -i INS_transient.i
mpirun -n 2 ../../../../whale-opt -i ../FSI_fluid_steady.i
mpirun -n 2 ../../../../whale-opt -i ../FSI_fluid_transient.i

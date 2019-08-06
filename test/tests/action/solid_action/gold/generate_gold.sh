#!/bin/bash

../../../../../whale-opt -i INS_steady.i
../../../../../whale-opt -i INS_transient.i
../../../../../whale-opt -i ../FSI_fluid_steady.i
../../../../../whale-opt -i ../FSI_fluid_transient.i

../../../../../whale-opt -i TM_steady.i
../../../../../whale-opt -i TM_transient.i
../../../../../whale-opt -i ../FSI_solid_steady.i
../../../../../whale-opt -i ../FSI_solid_transient.i

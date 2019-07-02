## Header comments

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  displacements = 'disp_x disp_y'
[]

# Load or build mesh file for this problem.
[Mesh]
  type = FileMesh
  file = ../mesh/solid.msh
  dim = 2 # Must be supplied for GMSH generated meshes
[]

# Set material parameters based on mesh regions
[Materials]
  [./elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'solid'
  [../]
  [./_elastic_stress1]
    type = ComputeFiniteStrainElasticStress
    block = 'solid'
  [../]
[]

# Variables in the problem's governing equations which must be solved
[Variables]

[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]

[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]

[]

[Modules/TensorMechanics/Master]
  [./block1]
    strain = FINITE
    add_variables = true
    block = 'solid'
  [../]
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]

[]

# Model boundary conditions that need to be enforced
[BCs]
  [./fixed_x]
    type = PresetBC
    boundary = 'fixed'
    variable = disp_x
    value = 0
  [../]
  [./fixed_y]
    type = PresetBC
    boundary = 'fixed'
    variable = disp_y
    value = 0
  [../]
  [./pressure]
    type = Pressure
    boundary = 'left'
    function = '1e3'
    component = 0
    variable = disp_x
  [../]
[]

# Define postprocessor operations that can be used for viewing data/statistics
[Postprocessors]

[]

# Set up matrix preconditioner to improve convergence
[Preconditioning]
  [./SMP]
    type = SMP
    full = true
  [../]
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  type = Steady

  petsc_options_iname = '-ksp_gmres_restart -pc_type -pc_hypre_type -pc_hypre_boomeramg_max_iter'
  petsc_options_value = '  201               hypre    boomeramg      10'

  line_search = 'none'

  nl_rel_tol = 5e-9
  nl_abs_tol = 1e-10
  nl_max_its = 15

  l_tol = 1e-3
  l_max_its = 50
[]

# Output files for viewing after model finishes
[Outputs]
  # Do not print linear residuals to stdout
  print_linear_residuals = false
  # Write results to exodus .e file
  [./exodus]
    type = Exodus
    # Set output folder and filename
    file_base = output/solid
  [../]
[]

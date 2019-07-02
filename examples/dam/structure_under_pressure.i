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
  [./density]
    type = GenericConstantMaterial
    block = 'solid'
    prop_names = 'density'
    prop_values = '1e2'
  [../]
[]

# Variables in the problem's governing equations which must be solved
[Variables]

[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [./vel_x]
  [../]
  [./accel_x]
  [../]
  [./vel_y]
  [../]
  [./accel_y]
  [../]
  [./stress_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
  [./strain_yy]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]
  [./inertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.3025
    gamma = 0.6
    eta=0.0
    use_displaced_mesh = true
  [../]
  [./inertia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.3025
    gamma = 0.6
    eta=0.0
    use_displaced_mesh = true
  [../]
[]

[Modules/TensorMechanics/Master]
  [./solid]
    strain = FINITE
    add_variables = true
    block = 'solid'
  [../]
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]
  [./accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.3025
    execute_on = timestep_end
  [../]
  [./vel_x]
    type = NewmarkVelAux
    variable = vel_x
    acceleration = accel_x
    gamma = 0.6
    execute_on = timestep_end
  [../]
  [./accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.3025
    execute_on = timestep_end
  [../]
  [./vel_y]
    type = NewmarkVelAux
    variable = vel_y
    acceleration = accel_y
    gamma = 0.6
    execute_on = timestep_end
  [../]
  [./stress_yy]
    type = RankTwoAux
    rank_two_tensor = stress
    variable = stress_yy
    index_i = 0
    index_j = 1
  [../]
  [./strain_yy]
    type = RankTwoAux
    rank_two_tensor = total_strain
    variable = strain_yy
    index_i = 0
    index_j = 1
  [../]
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
  # Set solver to transient, with Newton-Raphson nonlinear solver
  type = Transient
  solve_type = NEWTON

  # Nonlinear solver parameters for nonlinear iterations and linear subiterations
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 30
  l_tol = 1e-6
  l_max_its = 300
  dt = 1e-4
  end_time = 0.2e-1

  # PETSc solver options
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package '
  petsc_options_value = 'lu       superlu_dist'
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

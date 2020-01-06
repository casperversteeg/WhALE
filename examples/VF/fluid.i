## Header comments

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  convective_term = true
  transient_term = true
[]

# Load or build mesh file for this problem.
[Mesh]
  type = FileMesh
  file = mesh/fluid.msh
  dim = 2
[]

# Set material parameters based on mesh regions
[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1 1'
  []
[]

# Variables in the problem's governing equations which must be solved
[Variables]
  [vel_x]
    order = SECOND
    family = LAGRANGE
  []
  [vel_y]
    order = SECOND
    family = LAGRANGE
  []
  [p]
    order = FIRST
    family = LAGRANGE
  []
[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [disp_x]
    order = SECOND
    family = LAGRANGE
  []
  [disp_y]
    order = SECOND
    family = LAGRANGE
  []
  [traction_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [traction_y]
    order = CONSTANT
    family = MONOMIAL
  []
[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]
  [mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  []
  [x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  []
  [y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  []
  [vel_x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
  []
  [vel_y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
  []
  [./vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    use_displaced_mesh = true
  []
  [./vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
    use_displaced_mesh = true
  []
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]
  [traction_x]
    type = ComputeINSStress
    variable = traction_x
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 0
    boundary = 'vocal_folds'
  []
  [traction_y]
    type = ComputeINSStress
    variable = traction_y
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 1
    boundary = 'vocal_folds'
  []
[]

# Model boundary conditions that need to be enforced
[BCs]
  [x_noslip]
    type = DirichletBC
    variable = vel_x
    boundary = 'no_slip'
    value = 0
  []
  [y_noslip]
    type = DirichletBC
    variable = vel_y
    boundary = 'no_slip'
    value = 0
  []
  [inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = '1'
  []
  [outlet]
    type = FunctionDirichletBC
    variable = p
    boundary = 'outlet'
    function = '0'
  []
[]

# Define postprocessor operations that can be used for viewing data/statistics
[Postprocessors]

[]

# Set up matrix preconditioner to improve convergence
[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  type = Transient

  dt = 1e-4
  nl_abs_tol = 1e-6

  solve_type = 'NEWTON'
[]

# Output files for viewing after model finishes
[Outputs]
  print_linear_residuals = false
  exodus = true
[]

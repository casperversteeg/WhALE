## Header comments
[Debug]
#   show_actions = true
  show_var_residual_norms = true
  show_parser = true
[]
# These are the apps that need to be linked together
[MultiApps]
  [VF]
    type = TransientMultiApp
    app_type = whaleApp
    input_files = VF.i
    # execute_on = 'timestep_end'
    sub_cycling = true
    output_sub_cycles = true
    clone_master_mesh = true
  []
[]

# Which variables need to be transferred to and from where, and when/how
[Transfers]
  # Transfer stresses to solid
  [traction_to_solid_x]
    type = MultiAppNearestNodeTransfer
    direction = to_multiapp
    multi_ap = VF
    source_variable = traction_x
    variable = traction_x
  []
  [traction_to_solid_y]
    type = MultiAppNearestNodeTransfer
    direction = to_multiapp
    multi_ap = VF
    source_variable = traction_y
    variable = traction_y
  []
  # Take displacements from solid
  [disp_from_solid_x]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_ap = VF
    source_variable = traction_x
    variable = traction_x
  []
  [disp_from_solid_y]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_ap = VF
    source_variable = traction_y
    variable = traction_y
  []
[]

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  convective_term = true
  transient_term = true
[]

# Load or build mesh file for this problem.
[Mesh]
  type = FileMesh
  file = mesh/domain.msh
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
    block = 'VF'
  []
  [vel_y]
    order = SECOND
    family = LAGRANGE
    block = 'VF'
  []
  [p]
    order = FIRST
    family = LAGRANGE
    block = 'VF'
  []
  [disp_x]
    order = SECOND
    block = 'VF'
  []
  [disp_y]
    order = SECOND
    block = 'VF'
  []
[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [traction_x]
    order = CONSTANT
    family = MONOMIAL
    block = 'VF'
  []
  [traction_y]
    order = CONSTANT
    family = MONOMIAL
    block = 'VF'
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
  [vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
  []
  [vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
  []
  [diffuse_mesh_x]
    type = Diffusion
    variable = disp_x
  []
  [diffuse_mesh_y]
    type = Diffusion
    variable = disp_y
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
    boundary = 'VF_fsi'
  []
  [traction_y]
    type = ComputeINSStress
    variable = traction_y
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 1
    boundary = 'VF_fsi'
  []
[]

# Model boundary conditions that need to be enforced
[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'inlet outlet no_slip'
    value = 0
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'inlet outlet no_slip'
    value = 0
  []
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
  end_time = 2e-3
  nl_abs_tol = 1e-6

  solve_type = 'NEWTON'

  picard_max_its = 10
  picard_abs_tol = 1e-6
[]

# Output files for viewing after model finishes
[Outputs]
  print_linear_residuals = false
  exodus = true
[]

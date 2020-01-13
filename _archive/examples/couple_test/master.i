## Header comments
[Debug]
  # show_actions = true
  # show_var_residual_norms = true
  # show_parser = true
[]
# These are the apps that need to be linked together
[MultiApps]
  [dam]
    type = TransientMultiApp
    app_type = whaleApp
    input_files = dam.i
    execute_on = 'timestep_end'
    output_sub_cycles = true
    catch_up = true
    # clone_master_mesh = true
  []
[]

# Which variables need to be transferred to and from where, and when/how
[Transfers]
  # Transfer stresses to solid
  [traction_to_solid_x]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = dam
    source_variable = traction_x
    variable = traction_x
  []
  [traction_to_solid_y]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = dam
    source_variable = traction_y
    variable = traction_y
  []
  # Transfer velocity to solid
  [vel_to_solid_x]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = dam
    source_variable = vel_x
    variable = vel_x
  []
  [vel_to_solid_y]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = dam
    source_variable = vel_y
    variable = vel_y
  []
  # Take displacements from solid
  [disp_from_solid_x]
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = dam
    source_variable = disp_x
    variable = bc_x
  []
  [disp_from_solid_y]
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = dam
    source_variable = disp_y
    variable = bc_y
  []
[]

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  convective_term = true
  transient_term = true
  # block = 'fluid'
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
  [disp_x]
    order = SECOND
  []
  [disp_y]
    order = SECOND
  []
[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [bc_x]
    order = SECOND
  []
  [bc_y]
    order = SECOND
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
    boundary = 'dam'
  []
  [traction_y]
    type = ComputeINSStress
    variable = traction_y
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 1
    boundary = 'dam'
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
  [couple_x]
    type = DirichletBCfromAux
    variable = disp_x
    boundary = 'dam'
    aux_variable = bc_x
  []
  [couple_y]
    type = DirichletBCfromAux
    variable = disp_y
    boundary = 'dam'
    aux_variable = bc_y
  []
  # [couple_vx]
  #   type = CoupledVelocityBC
  #   variable = disp_x
  #   boundary = 'dam'
  #   v = vel_x
  # []
  # [couple_vy]
  #   type = CoupledVelocityBC
  #   variable = disp_y
  #   boundary = 'dam'
  #   v = vel_y
  # []
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

  dt = 1e-6
  end_time = 2e-3
  nl_abs_tol = 1e-6
  l_max_its = 300

  solve_type = 'NEWTON'

  picard_max_its = 10
  picard_abs_tol = 1e-6
[]

# Output files for viewing after model finishes
[Outputs]
  print_linear_residuals = false
  exodus = true
[]

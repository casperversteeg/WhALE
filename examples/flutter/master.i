[Debug]
  # show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = true
  laplace = false
  convective_term = true
  transient_term = true
  supg = true
  # pspg = true

  order = SECOND
[]

[Mesh]
  type = FileMesh
  file = mesh/mesh.msh
  dim = 2
  uniform_refine = 1
[]

[Variables]
  [vel_x]
  []
  [vel_y]
  []
  [p]
    order = FIRST
  []
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [traction_x]
    family = MONOMIAL
    order = CONSTANT
  []
  [traction_y]
    family = MONOMIAL
    order = CONSTANT
  []
  [disp_bc_x]
    family = LAGRANGE
  []
  [disp_bc_y]
    family = LAGRANGE
  []
[]

[Kernels]
  # FLUID
  [x_momentum]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  []
  [y_momentum]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  []
  [x_accel]
    type = INSMomentumTimeDerivative
    variable = vel_x
  []
  [y_accel]
    type = INSMomentumTimeDerivative
    variable = vel_y
  []
  [mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  []

  # MESH
  [x_mesh]
    type = INSConvectedMesh
    variable = vel_x
    disp_x = disp_x
    disp_y = disp_y
  []
  [y_mesh]
    type = INSConvectedMesh
    variable = vel_y
    disp_x = disp_x
    disp_y = disp_y
  []
  [smooth_mesh_x]
    type = Diffusion
    variable = disp_x
  []
  [smooth_mesh_y]
    type = Diffusion
    variable = disp_y
  []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1 1e-0'
  []
[]

[BCs]
  # FLUID
  [x_noslip]
    type = DirichletBC
    variable = vel_x
    value = 0.0
    boundary = 'no_slip fixed'
  []
  [y_noslip]
    type = DirichletBC
    variable = vel_y
    value = 0.0
    boundary = 'no_slip fixed'
  []
  [inlet]
    type = FunctionDirichletBC
    variable = vel_x
    function = '(3/2 - (600*x^2)/1681)*0.1'
    boundary = 'inlet'
  []
  [u_out]
    type = INSMomentumNoBCBCLaplaceForm
    boundary = 'outlet'
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  []
  [v_out]
    type = INSMomentumNoBCBCLaplaceForm
    boundary = 'outlet'
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  []



  # INTERFACE VEL
  [fsi_rel_vel_x]
    type = CoupledDirichletDotBC
    variable = vel_x
    v = disp_x
    implicit = true
    boundary = 'dam'
  []
  [fsi_rel_vel_y]
    type = CoupledDirichletDotBC
    variable = vel_y
    v = disp_y
    implicit = true
    boundary = 'dam'
  []

  # MESH
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0.0
    boundary = 'inlet outlet fixed no_slip'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0.0
    boundary = 'inlet outlet fixed no_slip'
  []
  [couple_x]
    type = CoupledDirichletBC
    variable = disp_x
    v = disp_bc_x
    boundary = 'dam'
  []
  [couple_y]
    type = CoupledDirichletBC
    variable = disp_y
    v = disp_bc_y
    boundary = 'dam'
  []
[]

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

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient
  #
  # picard_max_its = 20
  # picard_abs_tol = 1e-6
  # picard_force_norms = true

  dt = 1e-4
  end_time = 1e-1
  # num_steps = 20

  nl_abs_tol = 1e-6
  nl_max_its = 1e2
  l_max_its = 100

  solve_type = 'NEWTON'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

# [MultiApps]
#   [sub]
#     type = TransientMultiApp
#     app_type = whaleApp
#     input_files = sub.i
#     execute_on = 'timestep_end'
#     output_sub_cycles = true
#     catch_up = true
#   []
# []
#
# [Transfers]
#   [send_traction_x]
#     type = MultiAppInterpolationTransfer
#     direction = to_multiapp
#     multi_app = sub
#     source_variable = traction_x
#     variable = traction_x
#   []
#   [send_traction_y]
#     type = MultiAppInterpolationTransfer
#     direction = to_multiapp
#     multi_app = sub
#     source_variable = traction_y
#     variable = traction_y
#   []
#
#   [take_disp_x]
#     type = MultiAppNearestNodeTransfer
#     direction = from_multiapp
#     multi_app = sub
#     source_variable = disp_x
#     variable = disp_bc_x
#   []
#   [take_disp_y]
#     type = MultiAppNearestNodeTransfer
#     direction = from_multiapp
#     multi_app = sub
#     source_variable = disp_y
#     variable = disp_bc_y
#   []
# []

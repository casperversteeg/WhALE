[Debug]
  # show_actions = true
  # show_var_residual_norms = true
  # show_parser = true
[]

[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = false
  laplace = true
  convective_term = true
  transient_term = true
  supg = true
  # pspg = true

  order = SECOND
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    nx = 50
    ny = 20
    xmin = 0
    xmax = 0.05
    ymin = 0
    ymax = 0.02
    elem_type = TRI6
    dim = 2
  []
  [solid]
    type = SubdomainBoundingBoxGenerator
    input = GenMesh
    block_id = 1
    bottom_left = '0.024 0 0'
    top_right = '.026 .01 0'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = solid
    master_block = '0'
    paired_block = '1'
    new_boundary = 'dam'
  []
  [break_boundary]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
  []
  [delete_solid]
    type = BlockDeletionGenerator
    input = break_boundary
    block_id = 1
  []
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
  [d_bc_x]
    family = LAGRANGE
  []
  [d_bc_y]
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
    prop_values = '999.70 1.307e-0'
  []
[]

[BCs]
  # FLUID
  [x_noslip]
    type = DirichletBC
    variable = vel_x
    value = 0.0
    boundary = 'top bottom'
  []
  [y_noslip]
    type = DirichletBC
    variable = vel_y
    value = 0.0
    boundary = 'top bottom'
  []
  # [inlet]
  #   type = FunctionDirichletBC
  #   variable = vel_x
  #   function = '-${v}*(y/0.01-1)^2+${v}'
  #   boundary = 'left'
  # []
  # [outlet]
  #   type = FunctionDirichletBC
  #   variable = vel_x
  #   function = '-${v}*(y/0.01-1)^2+${v}'
  #   boundary = 'right'
  # []
  [in_p]
    type = DirichletBC
    variable = p
    value = 1e6
    boundary = 'left'
  []
  [out_p]
    type = DirichletBC
    variable = p
    value = 0.0
    boundary = 'right'
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
    boundary = 'top bottom left right'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0.0
    boundary = 'top bottom left right'
  []
  [couple_x]
    type = CoupledDirichletBC
    variable = disp_x
    v = d_bc_x
    boundary = 'dam'
  []
  [couple_y]
    type = CoupledDirichletBC
    variable = disp_y
    v = d_bc_y
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

  picard_max_its = 20
  picard_abs_tol = 1e-6
  picard_force_norms = true

  dt = 1e-4
  end_time = 1e-2
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

[MultiApps]
  [sub]
    type = TransientMultiApp
    app_type = whaleApp
    input_files = sub.i
    execute_on = 'timestep_end'
    output_sub_cycles = true
    catch_up = true
  []
[]

[Transfers]
  [send_traction_x]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = sub
    source_variable = traction_x
    variable = traction_x
  []
  [send_traction_y]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = sub
    source_variable = traction_y
    variable = traction_y
  []

  [take_disp_x]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = sub
    source_variable = disp_x
    variable = d_bc_x
  []
  [take_disp_y]
    type = MultiAppNearestNodeTransfer
    direction = from_multiapp
    multi_app = sub
    source_variable = disp_y
    variable = d_bc_y
  []
[]

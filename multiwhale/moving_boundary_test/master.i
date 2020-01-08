[Debug]
  # show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

[GlobalParams]
  gravity = '0 0 0'
  integrate_p_by_parts = false
  # laplace = true
  convective_term = true
  transient_term = true
  # supg = true
  displacements = 'disp_x disp_y'
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
    elem_type = QUAD9
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
    family = LAGRANGE
    order = SECOND
  []
  [vel_y]
    family = LAGRANGE
    order = SECOND
  []
  [p]
    family = LAGRANGE
    order = FIRST
  []
  [disp_x]
    family = LAGRANGE
    order = SECOND
  []
  [disp_y]
    family = LAGRANGE
    order = SECOND
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
    order = SECOND
  []
  [disp_bc_y]
    family = LAGRANGE
    order = SECOND
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
    use_displaced_mesh = true
  []
  [y_mesh]
    type = INSConvectedMesh
    variable = vel_y
    disp_x = disp_x
    disp_y = disp_y
    use_displaced_mesh = true
  []
  [smooth_mesh_x]
    type = Diffusion
    variable = disp_x
    use_displaced_mesh = true
  []
  [smooth_mesh_y]
    type = Diffusion
    variable = disp_y
    use_displaced_mesh = true
  []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1 1'
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
  [inlet]
    type = FunctionDirichletBC
    variable = vel_x
    function = '.01'
    boundary = 'left'
  []
  [outlet]
    type = FunctionDirichletBC
    variable = vel_x
    function = '.01'
    boundary = 'right'
  []
  [outlet_p]
    type = FunctionDirichletBC
    variable = p
    function = '0'
    boundary = 'right'
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
  [move_left]
    type = FunctionDirichletBC
    variable = disp_x
    function = '2*t*y'
    boundary = 'dam'
    use_displaced_mesh = true
  []
  [move_down]
    type = FunctionDirichletBC
    variable = disp_y
    function = '-2*t*y'
    boundary = 'dam'
    use_displaced_mesh = true
  []

  # MATCH VEL
  [dam_match_vx]
    type = CoupledDirichletDotBC
    variable = vel_x
    v = disp_x
    implicit = false
    use_displaced_mesh = true
    boundary = 'dam'
  []
  [dam_match_vy]
    type = CoupledDirichletDotBC
    variable = vel_y
    v = disp_y
    implicit = false
    use_displaced_mesh = true
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

  dt = 1e-6
  # end_time = 1e-1
  num_steps = 20

  nl_abs_tol = 1e-6
  l_max_its = 100

  solve_type = 'NEWTON'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

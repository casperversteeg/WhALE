[GlobalParams]
  gravity = '0 0 0'
  laplace = true
  transient_term = true
  integrate_p_by_parts = true
  family = LAGRANGE
  order = FIRST
  supg = true
  pspg = true
[]

[Mesh]
  [gen]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1.0
    ymin = 0
    ymax = 1.0
    nx = 128
    ny = 128
    elem_type = QUAD9
  []
  [./corner_node]
    type = ExtraNodesetGenerator
    new_boundary = 'pinned_node'
    nodes = '0'
    input = gen
  [../]
  # [./lid_side]
  #   type = SideSetsFromBoundingBoxGenerator
  #   input = corner_node
  #   block_id = 0
  #   boundary_id_old = 'top'
  #   boundary_id_new = 11
  #   bottom_left = '0.01 0.99 0'
  #   top_right = '0.99 1.01 0'
  # [../]
[]

[Variables]
  [./vel_x]
  [../]

  [./vel_y]
  [../]

  [./p]
    order = FIRST
  [../]
[]

[Kernels]
  [x_accel]
    type = INSMomentumTimeDerivative
    variable = vel_x
  []
  [y_accel]
    type = INSMomentumTimeDerivative
    variable = vel_y
  []
  # mass
  [./mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
  [../]

  # x-momentum, space
  [./x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
  [../]

  # y-momentum, space
  [./y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
  [../]
[]

[BCs]
  [./x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'bottom right left'
    value = 0.0
    preset = true
  [../]

  [./lid]
    type = FunctionPenaltyDirichletBC
    variable = vel_x
    boundary = 'top'
    function = 'lid_function'
    penalty = 1e4
  [../]

  [./y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'bottom right top left'
    value = 0.0
    preset = true
  [../]

  [./pressure_pin]
    type = DirichletBC
    variable = p
    boundary = 'pinned_node'
    value = 0
    preset = true
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'rho mu'
    prop_values = '5000  1'
  [../]
[]

[Functions]
  [./lid_function]
    # We pick a function that is exactly represented in the velocity
    # space so that the Dirichlet conditions are the same regardless
    # of the mesh spacing.
    type = ParsedFunction
    value = 'if(x > 0.0 & x < 1.0, 1, 0)'
  [../]
[]

[Preconditioning]
  [./SMP]
    type = SMP
    full = true
    solve_type = 'NEWTON'
  [../]
[]

[Executioner]
  type = Transient
  dt = 1e-1
  end_time = 40
  nl_rel_tol = 1e-10
  nl_abs_tol = 5e-4
  nl_max_its = 500
  l_tol = 1e-6
  l_max_its = 300
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
  petsc_options = '-snes_converged_reason -ksp_converged_reason'
[]

[Outputs]
  exodus = true
  print_linear_residuals = false
[]

[Debug]
  # show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

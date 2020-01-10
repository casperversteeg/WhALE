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
  supg = true
  pspg = true
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    nx = 50
    ny = 50
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    elem_type = QUAD9
    dim = 2
  []
[]

[Variables]
  [vel_x]
    family = LAGRANGE
    order = FIRST
  []
  [vel_y]
    family = LAGRANGE
    order = FIRST
  []
  [p]
    family = LAGRANGE
    order = FIRST
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
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1 1'
  []
[]

v = 1e2*t

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
    function = '-${v}*(2*y-1)^2 + ${v}'
    boundary = 'left'
  []
  [outlet]
    type = FunctionDirichletBC
    variable = vel_x
    function = '-${v}*(2*y-1)^2 + ${v}'
    boundary = 'right'
  []
  # [out_p]
  #   type = DirichletBC
  #   variable = p
  #   value = 0.0
  #   boundary = 'right'
  # []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Transient

  dt = 1
  # end_time = 1e-2
  num_steps = 100

  nl_abs_tol = 1e-6
  nl_max_its = 1e4
  l_max_its = 100

  solve_type = 'NEWTON'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

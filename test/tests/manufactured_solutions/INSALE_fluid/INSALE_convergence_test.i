# Pretty much entirely lifted this from the Navier-Stokes App testing routines
mu=1
rho=1

[GlobalParams]
  integrate_p_by_parts = false
  laplace = true
  u = vel_x
  v = vel_y
  p = p
  order = SECOND
  family = LAGRANGE
  mesh_x = disp_x
  mesh_y = disp_y
  use_displaced_mesh = true
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  xmin = 0
  xmax = 1.0
  ymin = 0
  ymax = 1.0
  elem_type = QUAD9
  nx = 4
  ny = 4
[]

[MeshModifiers]
  [./corner_node]
    type = AddExtraNodeset
    new_boundary = 'pinned_node'
    nodes = '0'
  [../]
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
  # mass
  [./mass]
    type = INSMass
    variable = p
  [../]

  [./x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
  [../]
  [./y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
  [../]

  # Add ALE momentum equation kernels, including convective, traction and body terms
  [./convection_x]
    type = INSALEMomentumConvection
    variable = vel_x
    component = 0
  [../]
  [./convection_y]
    type = INSALEMomentumConvection
    variable = vel_y
    component = 1
  [../]
  [./traction_x]
    type = INSALEMomentumTraction
    variable = vel_x
    component = 0
  [../]
  [./traction_y]
    type = INSALEMomentumTraction
    variable = vel_y
    component = 1
  [../]
  [./body_x]
    type = INSALEMomentumBodyForce
    variable = vel_x
    component = 0
    forcing_func = vel_x_source_func
  [../]
  [./body_y]
    type = INSALEMomentumBodyForce
    variable = vel_y
    component = 1
    forcing_func = vel_y_source_func
  [../]

  [./p_source]
    type = BodyForce
    function = p_source_func
    variable = p
  [../]
[]

[BCs]
  [./vel_x]
    type = FunctionDirichletBC
    boundary = 'left right top bottom'
    function = vel_x_func
    variable = vel_x
  [../]
  [./vel_y]
    type = FunctionDirichletBC
    boundary = 'left right top bottom'
    function = vel_y_func
    variable = vel_y
  [../]
  [./p]
    type = FunctionDirichletBC
    boundary = 'left right top bottom'
    function = p_func
    variable = p
  [../]
[]

[Functions]
  [./vel_x_source_func]
    type = ParsedFunction
    value = '-${mu}*(-0.028*pi^2*x^2*sin(0.2*pi*x*y) - 0.028*pi^2*y^2*sin(0.2*pi*x*y) - 0.1*pi^2*sin(0.5*pi*x) - 0.4*pi^2*sin(pi*y)) + ${rho}*(0.14*pi*x*cos(0.2*pi*x*y) + 0.4*pi*cos(pi*y))*(0.6*sin(0.8*pi*x) + 0.3*sin(0.3*pi*y) + 0.2*sin(0.3*pi*x*y) + 0.3) + ${rho}*(0.14*pi*y*cos(0.2*pi*x*y) + 0.2*pi*cos(0.5*pi*x))*(0.4*sin(0.5*pi*x) + 0.4*sin(pi*y) + 0.7*sin(0.2*pi*x*y) + 0.5) + 0.1*pi*y*cos(0.2*pi*x*y) + 0.25*pi*cos(0.5*pi*x)'
  [../]
  [./vel_y_source_func]
    type = ParsedFunction
    value = '-${mu}*(-0.018*pi^2*x^2*sin(0.3*pi*x*y) - 0.018*pi^2*y^2*sin(0.3*pi*x*y) - 0.384*pi^2*sin(0.8*pi*x) - 0.027*pi^2*sin(0.3*pi*y)) + ${rho}*(0.06*pi*x*cos(0.3*pi*x*y) + 0.09*pi*cos(0.3*pi*y))*(0.6*sin(0.8*pi*x) + 0.3*sin(0.3*pi*y) + 0.2*sin(0.3*pi*x*y) + 0.3) + ${rho}*(0.06*pi*y*cos(0.3*pi*x*y) + 0.48*pi*cos(0.8*pi*x))*(0.4*sin(0.5*pi*x) + 0.4*sin(pi*y) + 0.7*sin(0.2*pi*x*y) + 0.5) + 0.1*pi*x*cos(0.2*pi*x*y) + 0.3*pi*cos(0.3*pi*y)'
  [../]
  [./p_source_func]
    type = ParsedFunction
    value = '-0.06*pi*x*cos(0.3*pi*x*y) - 0.14*pi*y*cos(0.2*pi*x*y) - 0.2*pi*cos(0.5*pi*x) - 0.09*pi*cos(0.3*pi*y)'
  [../]
  [./vel_x_func]
    type = ParsedFunction
    value = '0.4*sin(0.5*pi*x) + 0.4*sin(pi*y) + 0.7*sin(0.2*pi*x*y) + 0.5'
  [../]
  [./vel_y_func]
    type = ParsedFunction
    value = '0.6*sin(0.8*pi*x) + 0.3*sin(0.3*pi*y) + 0.2*sin(0.3*pi*x*y) + 0.3'
  [../]
  [./p_func]
    type = ParsedFunction
    value = '0.5*sin(0.5*pi*x) + 1.0*sin(0.3*pi*y) + 0.5*sin(0.2*pi*x*y) + 0.5'
  [../]
  [./vxx_func]
    type = ParsedFunction
    value = '0.14*pi*y*cos(0.2*pi*x*y) + 0.2*pi*cos(0.5*pi*x)'
  [../]
[]

[Materials]
  [./const]
    type = GenericConstantMaterial
    block = 0
    prop_names = 'rho mu'
    prop_values = '${rho}  ${mu}'
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
  #petsc_options = '-snes_converged_reason -ksp_converged_reason'
  #petsc_options_iname = '-pc_type -pc_factor_shift_type -pc_factor_mat_solver_package'
  #petsc_options_value = 'lu NONZERO superlu_dist'
  #line_search = 'none'
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-9
  nl_max_its = 20
  l_tol = 1e-6
  l_max_its = 30
  # To run to steady-state, set num-steps to some large number (1000000 for example)
  type = Transient
  steady_state_detection = true
  steady_state_tolerance = 1e-10
  dt = 0.1
[]

[Outputs]
  print_linear_residuals = false
  [./exodus]
    type = Exodus
  [../]
  [./csv]
    type = CSV
    time_column = false
    execute_on = 'final'
  [../]
[]

[Postprocessors]
  [./L2vel_x]
    # execute_on = 'final'
    type = ElementL2Error
    variable = vel_x
    function = vel_x_func
    outputs = 'console csv'
  [../]
  [./L2vel_y]
    # execute_on = 'final'
    variable = vel_y
    function = vel_y_func
    type = ElementL2Error
    outputs = 'console csv'
  [../]
  [./L2p]
    # execute_on = 'final'
    variable = p
    function = p_func
    type = ElementL2Error
    outputs = 'console csv'
  [../]
  [./L2vxx]
    # execute_on = 'final'
    variable = vxx
    function = vxx_func
    type = ElementL2Error
    outputs = 'console csv'
  [../]
[]

[AuxVariables]
  [./vxx]
    family = MONOMIAL
    order = FIRST
  [../]
  [./disp_x]
    order = SECOND
    family = LAGRANGE
  [../]
  [./disp_y]
    order = SECOND
    family = LAGRANGE
  [../]
[]

[AuxKernels]
  [./vxx]
    type = VariableGradientComponent
    component = x
    variable = vxx
    gradient_variable = vel_x
  [../]
[]

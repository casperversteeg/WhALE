[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 1
    ymin = 0
    ymax = 1
    elem_type = QUAD9
    nx = 10
    ny = 10
  []
  # [rotate]
  #   type = TransformGenerator
  #   input = GenMesh
  #   transform = rotate
  #   vector_value = '45 0 0'
  # []
[]

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

[AuxVariables]
  [traction_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [traction_y]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  # [fluidstress_x]
  #   type = INSStressComponentAux
  #   variable = traction_x
  #   comp = 0
  #   mu_name = mu
  #   # pressure = p
  #   velocity = vel_x
  # []
  # [fluidstress_y]
  #   type = INSStressComponentAux
  #   variable = traction_y
  #   comp = 1
  #   mu_name = mu
  #   # pressure = p
  #   velocity = vel_y
  # []
  [traction_x]
    type = ComputeINSStress
    variable = traction_x
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 0
    boundary = 'bottom'
  []
  [traction_y]
    type = ComputeINSStress
    variable = traction_y
    u = vel_x
    v = vel_y
    p = p
    mu_name = mu
    component = 1
    boundary = 'bottom'
  []
[]

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
[]

[BCs]
  [no_x]
    type = DirichletBC
    variable = vel_x
    boundary = 'top bottom'
    value = 0.0
  []
  [no_y]
    type = DirichletBC
    variable = vel_y
    boundary = 'top bottom'
    value = 0.0
  []

  [vx_in]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'left'
    function = '-8*y*(y-1)'
  []
  # [vy_in]
  #   type = FunctionDirichletBC
  #   variable = vel_y
  #   boundary = 'left'
  #   function = '-8*y*(y-1)'
  # []
[]

[Materials]
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Executioner]
  type = Steady
  solve_type = Newton
  nl_rel_tol = 1e-8
  l_max_its = 20
[]

[Outputs]
  [out]
    type = Exodus
    # elemental_as_nodal = true
  []
[]

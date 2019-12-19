[Debug]
#   show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

[Mesh]
  [GenMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 2
    ymin = 0
    ymax = 1
    elem_type = QUAD9
    nx = 20
    ny = 10
  []
  [fluid]
    type = SubdomainBoundingBoxGenerator
    input = GenMesh
    block_id = 0
    bottom_left = '0 0 0'
    top_right = '1 1 0'
    block_name = 'fluid'
  []
  [solid]
    type = SubdomainBoundingBoxGenerator
    input = fluid
    block_id = 1
    bottom_left = '1 0 0'
    top_right = '2 1 0'
    block_name = 'solid'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = solid
    master_block = '0'
    paired_block = '1'
    new_boundary = 'fsi'
  []
  [break_boundary]
    input = interface
    type = BreakBoundaryOnSubdomainGenerator
  []
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
    block = 'fluid'
  []
  [disp_x]
    order = SECOND
    family = LAGRANGE
  []
  [disp_y]
    order = SECOND
    family = LAGRANGE
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
  convective_term = true
  transient_term = true
[]


[AuxVariables]
  [accel_x]
    block = 'solid'
    order = SECOND
  []
  [accel_y]
    block = 'solid'
    order = SECOND
  []
[]

[AuxKernels]
  [accel_x]
    type = NewmarkAccelAux
    variable = accel_x
    displacement = disp_x
    velocity = vel_x
    beta = 0.25
    execute_on = timestep_end
    block = 'solid'
  []
  [accel_y]
    type = NewmarkAccelAux
    variable = accel_y
    displacement = disp_y
    velocity = vel_y
    beta = 0.25
    execute_on = timestep_end
    block = 'solid'
  []
[]

[Kernels]
  [vel_x_time]
    type = INSMomentumTimeDerivative
    variable = vel_x
    block = 'fluid'
  []
  [vel_y_time]
    type = INSMomentumTimeDerivative
    variable = vel_y
    block = 'fluid'
  []
  [mass]
    type = INSMass
    variable = p
    u = vel_x
    v = vel_y
    p = p
    block = 'fluid'
  []
  [x_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_x
    u = vel_x
    v = vel_y
    p = p
    component = 0
    block = 'fluid'
  []
  [y_momentum_space]
    type = INSMomentumLaplaceForm
    variable = vel_y
    u = vel_x
    v = vel_y
    p = p
    component = 1
    block = 'fluid'
  []
  [vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    block = 'fluid'
  []
  [vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
    block = 'fluid'
  []
  [disp_x_fluid]
    type = Diffusion
    variable = disp_x
    block = 'fluid'
  []
  [disp_y_fluid]
    type = Diffusion
    variable = disp_y
    block = 'fluid'
  []

  [SolidInertia_x]
    type = InertialForce
    variable = disp_x
    velocity = vel_x
    acceleration = accel_x
    beta = 0.25
    gamma = 0.5
    block = 'solid'
  []
  [SolidInetia_y]
    type = InertialForce
    variable = disp_y
    velocity = vel_y
    acceleration = accel_y
    beta = 0.25
    gamma = 0.5
    block = 'solid'
  []

  [vxs_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_x
    v = disp_x
    block = 'solid'
  []
  [vys_time_derivative_term]
    type = CoupledTimeDerivative
    variable = vel_y
    v = disp_y
    block = 'solid'
  []
  [source_vxs]
    type = MatReaction
    variable = vel_x
    block = 'solid'
    mob_name = 1
  []
  [source_vys]
    type = MatReaction
    variable = vel_y
    block = 'solid'
    mob_name = 1
  []
[]

[InterfaceKernels]
  [./penalty_interface_x]
    type = InterfaceReaction
    variable = vel_x
    neighbor_var = vel_x
    boundary = 'fsi'
    kb = 1
    kf = 1
  [../]
  [./penalty_interface_y]
    type = InterfaceReaction
    variable = vel_y
    neighbor_var = vel_y
    boundary = 'fsi'
    kb = 1
    kf = 1
  [../]
[]

[Modules/TensorMechanics/Master]
  [./solid_domain]
    strain = SMALL
    generate_output = 'stress_xx stress_yy' ## Not at all necessary, but nice
    block = 'solid'
  [../]
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'solid'
  []
  [_elastic_stress1]
    type = ComputeLinearElasticStress
    block = 'solid'
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e3'
    block = 'solid'
  []
  [const]
    type = GenericConstantMaterial
    block = 'fluid'
    prop_names = 'rho mu'
    prop_values = '1  1'
  []
[]

[BCs]
  [inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'left'
    function = '1'
  []
  # [x_noslip]
  #   type = DirichletBC
  #   variable = vel_x
  #   value = 0
  #   boundary = 'top bottom'
  # []
  [y_noslip]
    type = DirichletBC
    variable = vel_y
    value = 0
    boundary = 'top bottom'
  []
  [no_disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'right'
    value = 0
  []
  [no_disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'left right'
    value = 0
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
  dt = 1e-3

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 150
  l_tol = 1e-6
  l_max_its = 300
  end_time = 1e-0

  solve_type = 'PJFNK'
[]

[Outputs]
  print_linear_residuals = false
  execute_on = 'timestep_end'
  # xda = true
  [out]
    type = Exodus
  []
[]


# [Kernels]
#   [mass]
#     type = INSMass
#     variable = p
#     u = vel_x
#     v = vel_y
#     p = p
#     block = 'fluid'
#   []
#   [x_accel]
#     type = INSMomentumTimeDerivative
#     variable = vel_x
#     block = 'fluid'
#   []
#   [y_accel]
#     type = INSMomentumTimeDerivative
#     variable = vel_y
#     block = 'fluid'
#   []
#   [x_momentum]
#     type = INSMomentumTractionForm
#     variable = vel_x
#     component = 0
#     u = vel_x
#     v = vel_y
#     p = p
#     block = 'fluid'
#   []
#   [y_momentum]
#     type = INSMomentumTractionForm
#     variable = vel_y
#     component = 1
#     u = vel_x
#     v = vel_y
#     p = p
#     block = 'fluid'
#   []
#
#   [vel_x_mesh]
#     type = INSConvectedMesh
#     disp_x = disp_x
#     disp_y = disp_y
#     variable = vel_x
#     block = 'fluid'
#   []
#   [vel_y_mesh]
#     type = INSConvectedMesh
#     disp_x = disp_x
#     disp_y = disp_y
#     variable = vel_y
#     block = 'fluid'
#   []
#   [disp_x_fluid]
#     type = Diffusion
#     variable = disp_x
#     block = 'fluid'
#   []
#   [disp_y_fluid]
#     type = Diffusion
#     variable = disp_y
#     block = 'fluid'
#   []
#
#   [xvel_solid]
#     type = CoupledTimeDerivative
#     variable = vel_x
#     v = disp_x
#     block = 'solid'
#   []
#   [yvel_solid]
#     type = CoupledTimeDerivative
#     variable = vel_y
#     v = disp_y
#     block = 'solid'
#   []
#   [xvel_source]
#     type = MatReaction
#     variable = vel_x
#     block = 'solid'
#     mob_name = '1'
#   []
#   [yvel_source]
#     type = MatReaction
#     variable = vel_y
#     block = 'solid'
#     mob_name = '1'
#   []
# []
#
# [Modules/TensorMechanics/Master]
#   displacements = 'disp_x disp_y'
#   [solid_domain]
#     strain = SMALL
#     # add_variables = true
#     # incremental = false
#     generate_output = 'strain_xx strain_yy strain_zz' ## Not at all necessary, but nice
#     block = 'solid'
#     displacements = 'disp_x disp_y'
#   []
# []
#
# [InterfaceKernels]
#   [x_reaction]
#     type = InterfaceReaction
#     variable = vel_x
#     neighbor_var = vel_x
#     boundary = 'fsi'
#     kb = 1
#     kf = 1
#   []
#   [y_reaction]
#     type = InterfaceReaction
#     variable = vel_y
#     neighbor_var = vel_y
#     boundary = 'fsi'
#     kb = 1
#     kf = 1
#   []
# []
#
# [BCs]
#   [vx_left]
#     type = DirichletBC
#     variable = vel_x
#     value = 1
#     boundary = 'left'
#   []
#
#   [fix_right]
#     type = DirichletBC
#     variable = disp_x
#     value = 0
#     boundary = 'right'
#   []
#   [fix_right_y]
#     type = DirichletBC
#     variable = disp_y
#     value = 0
#     boundary = 'right'
#   []
# []
#
# [Materials]
#   [const]
#     type = GenericConstantMaterial
#     block = 'fluid'
#     prop_names = 'rho mu'
#     prop_values = '1 1'
#   []
#   [elasticity_tensor]
#     type = ComputeIsotropicElasticityTensor
#     youngs_modulus = 1e8
#     poissons_ratio = 0.3
#     block = 'solid'
#   []
#   [_elastic_stress1]
#     type = ComputeLinearElasticStress
#     block = 'solid'
#   []
#   [density]
#     type = GenericConstantMaterial
#     prop_names = 'density'
#     prop_values = '1e3'
#     block = 'solid'
#   []
# []
#
# [Preconditioning]
#   [SMP]
#     type = SMP
#     full = true
#   []
# []
#
# [Executioner]
#   type = Transient
#   dt = 1e-4
#
#   nl_rel_tol = 1e-10
#   nl_abs_tol = 1e-7
#   nl_max_its = 150
#   l_tol = 1e-6
#   #l_max_its = 300
#   end_time = 2e-3
#
#   solve_type = 'NEWTON'
# []
#
# [Outputs]
#   [exodus]
#     type = Exodus
#   []
#   print_linear_residuals = false
# []


[AuxKernels]
  [fluidstress_x]
    type = INSStressComponentAux
    variable = stress_xx
    comp = 0
    mu_name = mu
    pressure = p
    velocity = vel_x
    block = 'fluid'
  []
  [fluidstress_y]
    type = INSStressComponentAux
    variable = stress_yy
    comp = 1
    mu_name = mu
    pressure = p
    velocity = vel_y
    block = 'fluid'
  []
[]

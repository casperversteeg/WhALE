[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  # [GenMesh]
  #   type = GeneratedMeshGenerator
  #   nx = 50
  #   ny = 20
  #   xmin = 0
  #   ymin = 0
  #   xmax = 0.05
  #   ymax = 0.02
  #   elem_type = QUAD9
  #   dim = 2
  # []
  # [subdomain1]
  #   input = GenMesh
  #   type = SubdomainBoundingBoxGenerator
  #   bottom_left = '0.024 0 0'
  #   top_right = '.026 .01 0'
  #   block_id = 1
  #   block_name = 'solid'
  # []
  [GenMesh]
    type = GeneratedMeshGenerator
    dim = 2
    xmin = 0
    xmax = 3.0
    ymin = 0
    ymax = 1.0
    nx = 10
    ny = 15
    elem_type = QUAD9
  []
  [subdomain1]
    type = SubdomainBoundingBoxGenerator
    input = GenMesh
    bottom_left = '0.0 0.5 0'
    block_id = 1
    top_right = '3.0 1.0 0'
    block_name = 'solid'
  []
  [interface]
    type = SideSetsBetweenSubdomainsGenerator
    input = subdomain1
    master_block = '0'
    paired_block = '1'
    new_boundary = 'fluid_fsi'
  []
  [interface_again]
    type = SideSetsBetweenSubdomainsGenerator
    input = interface
    master_block = '1'
    paired_block = '0'
    new_boundary = 'solid_fsi'
  []
  [break_boundary]
    input = interface_again
    type = BreakBoundaryOnSubdomainGenerator
  []
  [rename_fluid]
    type = RenameBlockGenerator
    input = break_boundary
    old_block_id = 0
    new_block_name = 'fluid'
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
    block = 'fluid'
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

[Kernels]
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
  [diffuse_mesh_x]
    type = Diffusion
    variable = disp_x
    block = 'fluid'
  []
  [diffuse_mesh_y]
    type = Diffusion
    variable = disp_y
    block = 'fluid'
  []
[]

[Modules/TensorMechanics/Master]
  [solid]
    strain = SMALL
    block = 'solid'
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'solid'
  []
  [elastic_stress1]
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
    prop_names = 'rho mu'
    prop_values = '1 1'
    block = 'fluid'
  []
[]

[BCs]
  [inlet]
    type = DirichletBC
    variable = vel_x
    value = 1.0
    boundary = 'left_to_0'
  []
  [outlet]
    type = DirichletBC
    variable = p
    value = 0.0
    boundary = 'right'
  []
  [noslip_x]
    type = DirichletBC
    variable = vel_x
    value = 0.0
    boundary = 'top bottom'
  []
  [noslip_y]
    type = DirichletBC
    variable = vel_y
    value = 0.0
    boundary = 'top bottom'
  []
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


  [vel_cont_x]
    type = MatchedValueBC
    variable = vel_x
    v = vel_x
    boundary = 'solid_fsi_to_solid'
  []
  [vel_cont_y]
    type = MatchedValueBC
    variable = vel_y
    v = vel_y
    boundary = 'solid_fsi_to_solid'
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

  dt = 1e-5
  num_steps = 100
  # end_time = 1e-2

  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-6
  l_max_its = 100

  solve_type = 'NEWTON'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
[]

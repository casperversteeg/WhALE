[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
  elem_type = QUAD9
[]

[MeshModifiers]
  # section the solid out of the fluid block
  [solid]
    type = SubdomainBoundingBox
    block_id = 1
    bottom_left = '0 0 0'
    top_right = '0.5 1 0'
  []
  # create named interface between fluid and solid
  [interface]
    type = SideSetsBetweenSubdomains
    depends_on = solid
    master_block = '0'
    paired_block = '1'
    new_boundary = 'interface'
  []
  [break_boundary]
    depends_on = interface
    type = BreakBoundaryOnSubdomain
  []
[]

[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1000
    poissons_ratio = 0.3
    block = 1
  []
  [stress]
    type = ComputeLinearElasticStress
    block = 1
  []
  [density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1'
    block = 1
  []
  [const]
    type = GenericConstantMaterial
    prop_names = 'rho mu'
    prop_values = '1  1'
    block = 0
  []
[]

[FSI]
  [Fluid]
    [1]
      velocities = 'vel_x vel_y'
      pressure = 'pressure'
      add_variables = true
      block = 0
    []
  []
  [Solid]
    [1]
      displacements = 'disp_x disp_y'
      strain = SMALL
      add_variables = true
      block = 1
    []
  []
[]

[BCs]
  [vel_inlet]
    type = DirichletBC
    variable = vel_y
    boundary = 'bottom_to_0'
    value = 1.0
  []
  [p_outlet]
    type = DirichletBC
    variable = pressure
    boundary = 'top_to_0'
    value = 0.0
  []
  [no_slip_x]
    type = DirichletBC
    variable = vel_x
    boundary = 'interface right'
    value = 0.0
  []
  [no_slip_y]
    type = DirichletBC
    variable = vel_y
    boundary = 'interface right'
    value = 0.0
  []

  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0
    boundary = 'bottom_to_1'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0
    boundary = 'bottom_to_1'
  []
  [Pressure]
    [left]
      boundary = 'top_to_1'
      function = '1'
      displacements = 'disp_x disp_y'
    []
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

  nl_abs_tol = 1e-8

  solve_type = 'PJFNK'
  petsc_options_iname = '-ksp_gmres_restart -pc_type -sub_pc_type -sub_pc_factor_levels'
  petsc_options_value = '300                bjacobi  ilu          4'
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
  file_base = "uncoupled_steady"
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = mesh/structure.msh
[]

[Variables]
  [disp_x]
    order = SECOND
  []
  [disp_y]
    order = SECOND
  []
[]

[AuxVariables]
  [tau_x]
    order = CONSTANT
    family = MONOMIAL
  []
  [tau_y]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[Kernels]
  [inertia_x]
    type = InertialForceExp
    variable = disp_x
    eta = 10
    use_displaced_mesh = true
  []
  [inertia_y]
    type = InertialForceExp
    variable = disp_y
    eta = 10
    use_displaced_mesh = true
  []
  [solid_x]
    type = StressDivergenceExpTensors
    variable = disp_x
    component = 0
    use_displaced_mesh = true
  []
  [solid_y]
    type = StressDivergenceExpTensors
    variable = disp_y
    component = 1
    use_displaced_mesh = true
  []
[]

[NodalKernels]
  [f_right]
    type = UserForcingFunctionNodalKernel
    variable = disp_y
    function = '5e8*sin(100*pi*t)'
    boundary = right_point
  []
[]

[BCs]
  [left_xfix]
    type = DirichletBC
    variable = disp_x
    boundary = 'left'
    value = 0
    use_displaced_mesh = true
  []
  [left_yfix]
    type = DirichletBC
    variable = disp_y
    boundary = 'left'
    value = 0
    use_displaced_mesh = true
  []
  [traction_x]
    type = CoupledTractionBC
    variable = disp_x
    traction = tau_x
    factor = -1e4
    boundary = 'top bottom right'
    use_displaced_mesh = true
  []
  [traction_y]
    type = CoupledTractionBC
    variable = disp_y
    traction = tau_y
    factor = -1e4
    boundary = 'top bottom right'
    use_displaced_mesh = true
  []
[]

[Materials]
  [density_structure]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = 80
  []
  [Cijkl_structure]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e9
    poissons_ratio = 0.3
  []
  [finite_strain]
    type = ComputeFiniteStrain
  []
  [elastic_stress]
    type = ComputeFiniteStrainElasticStress
  []
[]

[Postprocessors]
  [KE]
    type = KineticEnergy
    variable = disp_y
    disp_x = disp_x
    disp_y = disp_y
    execute_on = 'timestep_end'
  []
  [dt]
    type = ExplicitDynamicsTimeStep
    execute_on = 'timestep_end'
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    #ksp_norm = default
  []
[]

[Executioner]
  type = Transient

  solve_type = NEWTON
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'lu       superlu_dist'

  nl_rel_tol = 1e-6
  nl_max_its = 30
  l_tol = 1e-6
  l_max_its = 300
  dt = 1e-5
  # [TimeStepper]
  #   type = PostprocessorDT
  #   postprocessor = dt
  #   dt = 1e-6
  # []
[]

[Outputs]
  interval = 10
  print_linear_residuals = false
  csv = true
  [exodus]
    type = Exodus
    file_base = output/structure
  []
[]

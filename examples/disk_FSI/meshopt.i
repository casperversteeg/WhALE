[MultiApps]
  [structure]
    type = TransientMultiApp
    app_type = whaleApp
    positions = '0.0 0.0 0.0'
    input_files = structure.i
    execute_on = 'timestep_begin'
    sub_cycling = true
    output_sub_cycles = true
  []
  [fluid]
    type = TransientMultiApp
    app_type = whaleApp
    positions = '0.0 0.0 0.0'
    input_files = fluid.i
    execute_on = 'timestep_end'
  []
[]

[Transfers]
  [from_disp_x]
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = structure
    source_variable = disp_x
    variable = x_BC
    execute_on = 'timestep_begin'
  []
  [from_disp_y]
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = structure
    source_variable = disp_y
    variable = y_BC
    execute_on = 'timestep_begin'
  []

  [to_disp_x]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = fluid
    source_variable = disp_x
    variable = disp_x
    execute_on = 'timestep_end'
  []
  [to_disp_y]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = fluid
    source_variable = disp_y
    variable = disp_y
    execute_on = 'timestep_end'
  []

  [from_tau_x]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = fluid
    source_variable = tau_x
    variable = tau_x
    execute_on = 'timestep_end'
  []
  [from_tau_y]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = fluid
    source_variable = tau_y
    variable = tau_y
    execute_on = 'timestep_end'
  []

  [to_tau_x]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = structure
    source_variable = tau_x
    variable = tau_x
    execute_on = 'timestep_end'
  []
  [to_tau_y]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = structure
    source_variable = tau_y
    variable = tau_y
    execute_on = 'timestep_end'
  []
[]

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = mesh/fluid.msh
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
  [x_BC]
    order = SECOND
  []
  [y_BC]
    order = SECOND
  []
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
  [solid_x]
    type = StressDivergenceTensors
    variable = disp_x
    component = 0
  []
  [solid_y]
    type = StressDivergenceTensors
    variable = disp_y
    component = 1
  []
[]

[BCs]
  [boundary_xdisp]
    type = DirichletBC
    variable = disp_x
    boundary = 'top bottom left right'
    value = 0
  []
  [boundary_ydisp]
    type = DirichletBC
    variable = disp_y
    boundary = 'top bottom left right'
    value = 0
  []
  [structure_xdisp]
    type = CoupledDirichletBC
    variable = disp_x
    boundary = 'structure_top structure_bottom structure_left structure_right'
    var = x_BC
  []
  [structure_ydisp]
    type = CoupledDirichletBC
    variable = disp_y
    boundary = 'structure_top structure_bottom structure_left structure_right'
    var = y_BC
  []
[]

[Materials]
  [Cijkl]
    type = ComputeIsotropicElasticityTensor
    lambda = 1e8
    shear_modulus = 1e11
  []
  [strain]
    type = ComputeSmallStrain
  []
  [stress]
    type = ComputeLinearElasticStress
  []
[]

[Preconditioning]
  [smp]
    type = SMP
    full = true
    ksp_norm = default
  []
[]

[Executioner]
  type = Transient

  max_picard_iterations = 30
  
  solve_type = NEWTON
  petsc_options_iname = '-ksp_type -pc_type -pc_factor_mat_solver_package'
  petsc_options_value = 'preonly   lu       superlu_dist'

  nl_rel_tol = 1e-6
  nl_max_its = 30
  l_tol = 1e-6
  l_max_its = 300
  dt = 1e-4
  end_time = 1
[]

[Outputs]
  interval = 1
  print_linear_residuals = false
[]

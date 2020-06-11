E = 70e9
nu = 0.2
rho = 2500
T = 1e8

l = 5e-3
Gc = 9
psic = 114

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = 'fracture.i'
    cli_args = 'Gc=${Gc};l=${l};psic=${psic}'
  []
[]

[Transfers]
  [from_d]
    type = MultiAppCopyTransfer
    multi_app = 'fracture'
    direction = from_multiapp
    source_variable = 'd'
    variable = 'd'
  []
  [to_E_el_active]
    type = MultiAppCopyTransfer
    multi_app = 'fracture'
    direction = to_multiapp
    source_variable = 'E_el_active'
    variable = 'E_el_active'
  []
[]

[Mesh]
  type = FileMesh
  file = 'geom.msh'
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [stress]
    order = CONSTANT
    family = MONOMIAL
  []
  [d]
  []
  [E_el_active]
    family = MONOMIAL
  []
  [hmin]
    order = CONSTANT
    family = MONOMIAL
  []
[]


[Kernels]
  [inertia_x]
    type = InertialForce
    variable = disp_x
  []
  [inertia_y]
    type = InertialForce
    variable = disp_y
  []

  [solid_x]
    type = ADStressDivergenceTensors
    variable = 'disp_x'
    component = 0
  []
  [solid_y]
    type = ADStressDivergenceTensors
    variable = 'disp_y'
    component = 1
  []
[]

[AuxKernels]
  [stress]
    type = ADRankTwoScalarAux
    variable = 'stress'
    rank_two_tensor = 'stress'
    scalar_type = 'MaxPrincipal'
    execute_on = 'TIMESTEP_END'
  []
  [E_el_active]
    type = ADMaterialRealAux
    variable = 'E_el_active'
    property = 'E_el_active'
  []
  [max_h]
    type = ElementLengthAux
    variable = hmin
    method = min
    execute_on = 'TIMESTEP_BEGIN'
  []
[]

[Materials]
  [elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = '${E}'
    poissons_ratio = '${nu}'
  []
  [reg_elasticity_tensor]
    type = MaterialConverter
    ad_props_in = 'effective_stiffness'
    reg_props_out = 'reg_effective_stiffness'
  []
  [elastic_strain]
    type = ADComputeSmallStrain
  []
  [bulk]
    type = GenericConstantMaterial
    prop_names = 'density phase_field_regularization_length energy_release_rate critical_fracture_energy'
    prop_values = '${rho} ${l} ${Gc} ${psic}'
  []
  [degraded_stress]
    type = SmallStrainDegradedElasticPK2Stress_StrainSpectral
    d = 'd'
  []
  [fracture_properties]
    type = FractureMaterial
    local_dissipation_norm = 8/3
    # local_dissipation_norm = 2
  []
  [degradation]
    type = LorentzDegradation
    # type = QuadraticDegradation
    d = 'd'
    residual_degradation = 1e-9
    # residual_degradation = 0
  []
[]

[BCs]
  [fix_x]
    type = DirichletBC
    variable = disp_x
    value = 0.0
    boundary = 'top bottom'
  []
  [fix_y]
    type = DirichletBC
    variable = disp_y
    value = 0.0
    boundary = 'top bottom'
  []

  [pulse_x]
    type = Pressure
    variable = disp_x
    component = 0
    function = 'if(t < 3e-6, ${T}, 0)'
    boundary = 'load_top load_bottom'
  []
  [pulse_y]
    type = Pressure
    variable = disp_y
    component = 1
    function = 'if(t < 3e-6, ${T}, 0)'
    boundary = 'load_top load_bottom'
  []
[]

[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

[Postprocessors]
  [explicit_dt]
    type = BetterCriticalTimeStep
    density_name = 'density'
    E_name = 'reg_effective_stiffness'
    # factor = 0.8
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []
[]


[Executioner]
  type = Transient
  # dt = 2e-8
  end_time = 1e-3

  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-8
  l_max_its = 50

  solve_type = 'NEWTON'


  [TimeStepper]
    type = PostprocessorDT
    postprocessor = explicit_dt
    scale = 0.9
  []
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []
  # [TimeIntegrator]
  #   type = NewmarkBeta
  #   beta = 0.25
  #   gamma = 0.5
  # []
[]

[Outputs]
  print_linear_residuals = false
  exodus = true
  hide = 'explicit_dt'
  [Console]
    type = Console
    outlier_variable_norms = false
  []
[]

[Debug]
  # show_actions = true
  show_var_residual_norms = true
  # show_parser = true
[]

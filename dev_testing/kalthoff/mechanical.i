E = 190e3
rho = 8e-9
nu = 0.3

Gc = 22.2
# sigmac = 1.733e3
psic = 7.9034
l = 0.35

[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = FileMesh
  file = 'kalthoff.msh'
[]

[MultiApps]
  [fracture]
    type = TransientMultiApp
    input_files = 'fracture.i'
    cli_args = 'Gc=${Gc};l=${l};psic=${psic}'
  []
[]

[Transfers]
  [get_damage]
    type = MultiAppCopyTransfer
    multi_app = 'fracture'
    direction = from_multiapp
    source_variable = 'd'
    variable = 'd'
  []
  [send_elastic_energy]
    type = MultiAppCopyTransfer
    multi_app = 'fracture'
    direction = to_multiapp
    source_variable = 'E_el_active'
    variable = 'E_el_active'
  []
[]

[Variables]
  [disp_x]
  []
  [disp_y]
  []
[]

[AuxVariables]
  [sigma1]
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
  [hmax]
    order = CONSTANT
    family = MONOMIAL
  []
[]

[AuxKernels]
  [stress]
    type = ADRankTwoScalarAux
    variable = 'sigma1'
    rank_two_tensor = 'stress'
    scalar_type = 'MaxPrincipal'
    execute_on = 'TIMESTEP_END'
  []
  [E_el_active]
    type = ADMaterialRealAux
    variable = 'E_el_active'
    property = 'E_el_active'
  []
  [min_h]
    type = ElementLengthAux
    variable = 'hmin'
    method = min
    execute_on = 'INITIAL'
  []
  [max_h]
    type = ElementLengthAux
    variable = 'hmax'
    method = max
    execute_on = 'INITIAL'
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

[BCs]
  [v_in]
    type = FunctionDirichletBC
    variable = 'disp_x'
    boundary = 'load'
    function = 'if(t<1e-6, 0.5*1.65e10*t*t, 1.65e4*t-0.5*1.65e-2)'
    preset = false
  []
  [symmetry]
    type = DirichletBC
    variable = 'disp_y'
    boundary = 'bottom'
    value = '0'
  []
[]

[Materials]
  [bulk]
    type = GenericConstantMaterial
    prop_names = 'density phase_field_regularization_length energy_release_rate critical_fracture_energy'
    prop_values = '${rho} ${l} ${Gc} ${psic}'
  []
  [elasticity_tensor]
    type = ADComputeIsotropicElasticityTensor
    youngs_modulus = '${E}'
    poissons_ratio = '${nu}'
  []
  [reg_elasticty_tensor]
    type = MaterialConverter
    ad_props_in = 'effective_stiffness'
    reg_props_out = 'reg_effective_stiffness'
  []
  [strain]
    type = ADComputeSmallStrain
  []
  [stress]
    type = SmallStrainDegradedElasticPK2Stress_StrainSpectral
    d = 'd'
  []
  [fracture_properties]
    type = FractureMaterial
    local_dissipation_norm = 8/3
  []
  [degradation]
    type = LorentzDegradation
    d = 'd'
    residual_degradation = 1e-09
  []
[]

[Postprocessors]
  [explicit_dt]
    type = BetterCriticalTimeStep
    density_name = 'density'
    E_name = 'reg_effective_stiffness'
    execute_on = 'INITIAL TIMESTEP_BEGIN TIMESTEP_END'
  []
[]

[Executioner]
  type = Transient
  end_time = 85e-6

  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-8
  l_max_its = 50
  nl_max_its = 100

  solve_type = 'NEWTON'

  [TimeStepper]
    type = PostprocessorDT
    postprocessor = explicit_dt
    scale = 0.95
  []
  [TimeIntegrator]
    type = CentralDifference
    solve_type = lumped
  []
[]

[Outputs]
  print_linear_residuals = false
  [Exodus]
    type = Exodus
    file_base = 'Kalthoff_noAM'
  []
  hide = 'explicit_dt'
  [Console]
    type = Console
    outlier_variable_norms = false
  []
[]

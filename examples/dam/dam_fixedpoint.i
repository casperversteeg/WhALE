## Header comments

# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
  add_variables = true
[]

# Load or build mesh file for this problem.
[Mesh]
  type = FileMesh
  file = mesh/domain.msh
  dim = 2
[]

# Set material parameters based on mesh regions
[Materials]
  [elasticity_tensor]
    type = ComputeIsotropicElasticityTensor
    youngs_modulus = 1e8
    poissons_ratio = 0.3
    block = 'solid'
  []
  [elastic_stress]
    type = ComputeFiniteStrainElasticStress
    block = 'solid'
  [../]
  [solid_density]
    type = GenericConstantMaterial
    prop_names = 'density'
    prop_values = '1e2'
    block = 'solid'
  []
  [fluid]
    type = GenericConstantMaterial
    block = 'fluid'
    prop_names = 'rho mu'
    prop_values = '1  1'
  [../]
[]

# Variables in the problem's governing equations which must be solved
[Variables]

[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]

[]

[FSI]
  [Fluid]
    [1]
      velocities = 'vel_x vel_y'
      pressure = 'pressure'
      block = 'fluid'
    []
  []
  [Solid]
    [1]
      displacements = 'disp_x disp_y'
      block = 'solid'
      strain = FINITE
    []
  []
[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]
  [vel_x_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_x
    block = 'fluid'
    use_displaced_mesh = true
  []
  [vel_y_mesh]
    type = INSConvectedMesh
    disp_x = disp_x
    disp_y = disp_y
    variable = vel_y
    block = 'fluid'
    use_displaced_mesh = true
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
[]

[InterfaceKernels]
  [./penalty_interface_x]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_x
    neighbor_var = disp_x
    slave_coupled_var = vel_x_solid
    boundary = 'dam_left dam_top dam_right'
    penalty = 1e6
  [../]
  [./penalty_interface_y]
    type = CoupledPenaltyInterfaceDiffusion
    variable = vel_y
    neighbor_var = disp_y
    slave_coupled_var = vel_y_solid
    boundary = 'dam_left dam_top dam_right'
    penalty = 1e6
  [../]
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]

[]

# Model boundary conditions that need to be enforced
[BCs]
  [fluid_x_no_slip]
    type = DirichletBC
    variable = vel_x
    boundary = 'no_slip'
    value = 0.0
  []
  [fluid_y_no_slip]
    type = DirichletBC
    variable = vel_y
    boundary = 'no_slip'
    value = 0.0
  []
  [inlet]
    type = FunctionDirichletBC
    variable = vel_x
    boundary = 'inlet'
    function = '1'
  []
  [outlet]
    type = FunctionDirichletBC
    variable = p
    boundary = 'outlet'
    function = '0'
  []
  [no_disp_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'fixed no_slip inlet outlet'
    value = 0
  []
  [no_disp_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'fixed no_slip inlet outlet'
    value = 0
  []
  [solid_x_no_slip]
    type = DirichletBC
    variable = vel_x_solid
    boundary = 'dam_left dam_top dam_right'
    value = 0.0
  []
  [solid_y_no_slip]
    type = DirichletBC
    variable = vel_y_solid
    boundary = 'dam_left dam_top dam_right'
    value = 0.0
  []
[]

# Define postprocessor operations that can be used for viewing data/statistics
[Postprocessors]

[]

# Set up matrix preconditioner to improve convergence
[Preconditioning]
  [SMP]
    type = SMP
    full = true
  []
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  type = Steady

  nl_rel_tol = 1e-10
  nl_abs_tol = 1e-7
  nl_max_its = 15
  l_tol = 1e-6
  l_max_its = 300
  end_time = 5e-3

  solve_type = 'PJFNK'
  petsc_options_iname = '-pc_type'
  petsc_options_value = 'lu'
[]

# Output files for viewing after model finishes
[Outputs]
  file_base = output/dam
  print_linear_residuals = false
  execute_on = 'timestep_end'
  # xda = true
  [out]
    type = Exodus
  []
[]

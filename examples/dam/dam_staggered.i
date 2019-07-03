## Header comments

# These are the apps that need to be linked together
[MultiApps]
  [./Solid]
    type = TransientMultiApp
    app_type = whaleApp
    input_files = subapps/structure.i
    execute_on = 'TIMESTEP_BEGIN'
    catch_up = true
  [../]
  [./Fluid]
    type = TransientMultiApp
    app_type = whaleApp
    input_files = subapps/fluid.i
    execute_on = 'TIMESTEP_END'
  [../]
[]

# Which variables need to be transferred to and from where, and when/how
[Transfers]
  # Solve the solid displacements, take solution into master app (this)
  [./take_disp_from_solid_x]
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Solid
    source_variable = disp_x
    variable = solid_bc_store_x
    execute_on = 'TIMESTEP_BEGIN'
  [../]
  [./take_disp_from_solid_y]
    type = MultiAppInterpolationTransfer
    direction = from_multiapp
    multi_app = Solid
    source_variable = disp_y
    variable = solid_bc_store_y
    execute_on = 'TIMESTEP_BEGIN'
  [../]

  # Regularize fluid mesh and export displacements to fluid subapp
  [./send_mesh_disp_to_fluid_x]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = Fluid
    source_variable = mesh_disp_x
    variable = disp_x
    execute_on = 'TIMESTEP_END'
  [../]
  [./send_mesh_disp_to_fluid_y]
    type = MultiAppCopyTransfer
    direction = to_multiapp
    multi_app = Fluid
    source_variable = mesh_disp_y
    variable = disp_y
    execute_on = 'TIMESTEP_END'
  [../]

  # Solve the fluid tractions along boundary, send from fluid to solid
  [./take_traction_from_fluid_x]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = Fluid
    source_variable = fluid_traction_x
    variable = fluid_bc_store_x
    execute_on = 'TIMESTEP_END'
  [../]
  [./take_traction_from_fluid_y]
    type = MultiAppCopyTransfer
    direction = from_multiapp
    multi_app = Fluid
    source_variable = fluid_traction_y
    variable = fluid_bc_store_y
    execute_on = 'TIMESTEP_END'
  [../]
  [./send_traction_to_solid_x]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Solid
    source_variable = fluid_bc_store_x
    variable = sigma_x
    execute_on = 'TIMESTEP_END'
  [../]
  [./send_traction_to_solid_y]
    type = MultiAppInterpolationTransfer
    direction = to_multiapp
    multi_app = Solid
    source_variable = fluid_bc_store_y
    variable = sigma_y
    execute_on = 'TIMESTEP_END'
  [../]
[]

## Everything below here will be done in between transfers (mesh regularizer)
# Global parameters that will be set for all kernels in the simulation
[GlobalParams]
[]

# Load or build mesh file for this problem.
[Mesh]
  type = FileMesh
  file = mesh/fluid.msh
[]

# Set material parameters based on mesh regions
[Materials]
[]

# Variables in the problem's governing equations which must be solved
[Variables]
  [./mesh_disp_x]
    family = LAGRANGE
    order = SECOND
  [../]
  [./mesh_disp_y]
    family = LAGRANGE
    order = SECOND
  [../]
[]

# Auxiliary variables used for postprocessing and passing data between apps
[AuxVariables]
  [./solid_bc_store_x]
    family = LAGRANGE
    order = SECOND
  [../]
  [./solid_bc_store_y]
    family = LAGRANGE
    order = SECOND
  [../]
  [./fluid_bc_store_x]
    family = MONOMIAL
    order = CONSTANT
  [../]
  [./fluid_bc_store_y]
    family = MONOMIAL
    order = CONSTANT
  [../]

  # Additional variable to keep track of mesh quality
  [./mesh_quality]
    family = MONOMIAL
    order = CONSTANT
  [../]
[]

# All the terms in the weak form that need to be solved in this simulation
[Kernels]
  # These will diffuse the fluid mesh to preserve mesh quality. Even though the
  # executioner is transient, these will be solved to steady state, since there
  # are no time-dependent kernels included here, so the equation will simply
  # look like Lap(u) = 0
  [./diffuse_mesh_x]
    type = Diffusion
    variable = mesh_disp_x
    use_displaced_mesh = true
  [../]
  [./diffuse_mesh_y]
    type = Diffusion
    variable = mesh_disp_y
    use_displaced_mesh = true
  [../]
[]

# Operations defined on auxiliary variables that will be computed at end
[AuxKernels]
  [./mesh_quality]
    type = ElementQualityAux
    variable = mesh_quality
    metric = SHAPE
  [../]
[]

# Model boundary conditions that need to be enforced
[BCs]
  # These are the boundaries of the fluid that do not defrom due to solid
  [./fluid_fix_x]
    type = DirichletBC
    variable = mesh_disp_x
    boundary = 'inlet outlet no_slip'
    value = 0
  [../]
  [./fluid_fix_y]
    type = DirichletBC
    variable = mesh_disp_y
    boundary = 'inlet outlet no_slip'
    value = 0
  [../]

  # These are the fluid boundaries subject to displacement due to solid
  [./fsi_boundary_x]
    type = BCfromAux
    variable = mesh_disp_x
    aux_variable = solid_bc_store_x
    boundary = 'dam_left dam_top dam_right'
  [../]
  [./fsi_boundary_y]
    type = BCfromAux
    variable = mesh_disp_y
    aux_variable = solid_bc_store_y
    boundary = 'dam_left dam_top dam_right'
  [../]
[]

# Define postprocessor operations that can be used for viewing data/statistics
[Postprocessors]
[]

# Set up matrix preconditioner to improve convergence
[Preconditioning]
  [./smp]
    type = SMP
    full = true
  [../]
[]

# Type of algorithm and convergence parameters used to solve the matrix problem
[Executioner]
  # Set solver to transient, with Newton-Raphson nonlinear solver
  type = Transient
  solve_type = NEWTON

  # Nonlinear solver parameters for nonlinear iterations and linear subiterations
  nl_rel_tol = 1e-6
  nl_abs_tol = 1e-10
  nl_max_its = 30
  l_tol = 1e-6
  l_max_its = 300
  dt = 1e-4
  end_time = 0.2e-1

  # PETSc solver options
  # petsc_options = '-snes_converged_reason -ksp_converged_reason'
  petsc_options_iname = '-pc_type -pc_factor_mat_solver_package '
  petsc_options_value = 'lu       superlu_dist'
[]

# Output files for viewing after model finishes
[Outputs]
  interval = 1
  print_linear_residuals = true
[]

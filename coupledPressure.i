#
# Pressure Test
#
# This test is designed to compute pressure loads on three faces of a unit cube.
# The pressure is computed as an auxiliary variable. It should give the same result
# as pressure_test.i
#
# The mesh is composed of one block with a single element.  Symmetry bcs are
# applied to the faces opposite the pressures.  Poisson's ratio is zero,
# which makes it trivial to check displacements.
#


[GlobalParams]
  displacements = 'disp_x disp_y'
[]

[Mesh]
  type = GeneratedMesh
  dim = 2
  nx = 10
  ny = 10
[]

[AuxVariables]
  [./pressure_1]
  [../]
  [./pressure_2]
  [../]
[]

[AuxKernels]
  [./top_x_aux]
    type = FunctionAux
    variable = pressure_1
    boundary = 'top'
    function = '1'
  [../]
  [./top_y_aux]
    type = FunctionAux
    variable = pressure_2
    boundary = 'top'
    function = '0'
  [../]
[]

[Modules]
  [./TensorMechanics]
    [./Master]
      [./all]
        strain = SMALL
        add_variables = true
      [../]
    [../]
  [../]
[]

[BCs]
  [./no_x]
    type = DirichletBC
    variable = disp_x
    boundary = 'bottom'
    value = 0.0
  [../]
  [./no_y]
    type = DirichletBC
    variable = disp_y
    boundary = 'bottom'
    value = 0.0
  [../]
  [./top_x]
    type = CoupledPressureBC
    variable = 'disp_x'
    boundary = 'top'
    pressure = pressure_1
    component = 0
    displacements = 'disp_x disp_y'
  [../]
  [./top_y]
    type = CoupledPressureBC
    variable = 'disp_y'
    boundary = 'top'
    pressure = pressure_2
    component = 1
    displacements = 'disp_x disp_y'
  [../]

[]

[Materials]
  [./Elasticity_tensor]
    type = ComputeElasticityTensor
    fill_method = symmetric_isotropic
    C_ijkl = '0 0.5e6'
  [../]
  [./stress]
    type = ComputeLinearElasticStress
  [../]
[]

[Executioner]
  type = Transient
  solve_type = PJFNK
  nl_abs_tol = 1e-10
  l_max_its = 20
  start_time = 0.0
  dt = 1.0
  num_steps = 2
  end_time = 2.0
[]

[Outputs]
  [./out]
    type = Exodus
  [../]
[]

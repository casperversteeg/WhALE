  dim = 2
[]

[Variables]
[vel_x]
[]
[vel_y]
[]
[p]
[]
[]

[Kernels]
[momentum_x]
   type = INSMomentumLaplaceForm
   variable = vel_x
   u = vel_x
   v = vel_y
   p = p
   component = 0
[]
[momentum_y]
   type = INSMomentumLaplaceForm
   variable = vel_y
   u = vel_x
   v = vel_y
   p = p
   component = 1
[]
[mass]
   type = INSMass
   variable = p
   u = vel_x
   v = vel_y
   p = p
[]
[]

[Materials]
[fluid]
   type = GenericConstantMaterial
   prop_names = 'rho mu'
   prop_values = ' 1  1'
[]
[]

[BCs]
[no_slip_x]
   type = DirichletBC
   variable = vel_x
   value = 0.0
   boundary = 'no_slip'
[]
[no_slip_y]
   type = DirichletBC
   variable = vel_y
   value = 0.0
   boundary = 'no_slip'
[]
[p_in]
   type = DirichletBC
   variable = p
   value = 100e3
   boundary = 'inlet'
[]
[p_out]
   type = DirichletBC
   variable = p
   value = 0.0
   boundary = 'outlet'
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

l_max_its = 100
nl_abs_tol = 1e-6
[]

[Postprocessors]
[Q]
   type = VolumetricFlowRate
   vel_x = vel_x
   boundary = 'outlet'
[]
[]

[Outputs]
csv = true
exodus = true
print_linear_residuals = false
[]

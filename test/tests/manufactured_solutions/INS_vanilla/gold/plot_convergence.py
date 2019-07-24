#!/usr/bin/env python

#* This file is part of the MOOSE framework
#* https://www.mooseframework.org
#*
#* All rights reserved, see COPYRIGHT for full restrictions
#* https://github.com/idaholab/moose/blob/master/COPYRIGHT
#*
#* Licensed under LGPL 2.1, please see LICENSE for details
#* https://www.gnu.org/licenses/lgpl-2.1.html

# To create convergence plots for the INS variables for different alphas,
# run the navier stokes tests with --all and then run this script

import numpy as np
import matplotlib.pyplot as plt

# Use fonts that match LaTeX
from matplotlib import rcParams
rcParams['font.family'] = ['serif']
rcParams['font.size'] = 17
rcParams['font.serif'] = ['Computer Modern Roman']
rcParams['text.usetex'] = True

# Small font size for the legend
from matplotlib.font_manager import FontProperties
fontP = FontProperties()
fontP.set_size('x-small')

h_array = np.array([.25, .0625, 0.015625, 0.0078125, 0.00390625, 0.000976562])
variable_names = ['L2p', 'L2vel_x', 'L2vel_y', 'L2vxx']
for name in variable_names:
    data_array = np.array([])
    for h in h_array:
        n = int(1 / h)
        data_file = "%sx%s.csv" % (n, n)
        data = np.genfromtxt(data_file, dtype=float, names=True, delimiter=',')
        data_array = np.append(data_array, data[name])
    z = np.polyfit(np.log10(h_array), np.log10(data_array), 1)
    p = np.poly1d(z)
    plt.plot(np.log10(h_array), p(np.log10(h_array)), '-')
    equation = "y=%.1fx+%.1f" % (z[0],z[1])
    plt.scatter(np.log10(h_array), np.log10(data_array), label=r"$%s$" % equation)
    plt.xlabel(r"$\log_{10} h$")
    plt.ylabel(r"$\log_{10} L_2$")
    plt.legend(prop=fontP)
    plt.tight_layout()
    plt.savefig("convergence_plot_%s.eps" % name, format='eps')
    plt.close()

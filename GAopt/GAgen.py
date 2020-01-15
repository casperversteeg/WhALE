#!/usr/bin/env python3

import numpy as np
import math
import subprocess as sub
import os
import csv

def generateVecLtNorm(R):
    x = (2*np.random.rand()-1) * R
    r = math.sqrt(math.pow(R,2) - math.pow(x,2))
    y = (2*np.random.rand()-1) * r
    return [x,y]

def computeVecNorm(x,y):
    return math.sqrt(math.pow(float(x),2) + math.pow(float(y),2))

def meshFileName(gen,popID):
    return "mesh" + str(gen) + "_" + str(popID) + ".msh"

def inputFileName(gen,popID):
    return "gen" + str(gen) +"/input" + str(gen) + "_" + str(popID) + ".i"

def outputCSVFileName(gen,popID):
    return "gen" + str(gen) + "/input" + str(gen) + "_" + str(popID) + "_out.csv"

def outputExodusFileName(gen,popID):
    return "gen" + str(gen) + "/input" + str(gen) + "_" + str(popID) + "_out.e"

def makeMeshFile(gen, popID, x, y):
    sub.check_call(["gmsh geom.geo -2 -o gen" + str(gen) + "/"+ meshFileName(gen,popID) +" -setnumber X " + str(x) + " -setnumber Y " + str(y)], shell=True)

def makeInputFile(gen, popID):
    temp1 = open("template1.i","r")
    temp2 = open("template2.i","r")
    dt1 = temp1.read()
    dt2 = temp2.read()
    temp1.close()
    temp2.close()
    os.makedirs(os.path.dirname(inputFileName(gen,popID)),exist_ok=True)
    infile = open(inputFileName(gen,popID), "w+")
    infile.write(dt1)
    infile.write("\tfile=" + meshFileName(gen,popID) + "\n")
    infile.write(dt2)
    infile.close()

def runMoose(gen,popID):
    sub.check_call(["mpirun -n 2 ../whale-opt -i " + inputFileName(gen,popID)], shell=True)

def getSimulationResultCSV(gen,pop):
    with open(outputCSVFileName(gen,pop)) as resultFile:
        resultReader = csv.reader(resultFile, delimiter=',')
        line_count = 0
        for row in resultReader:
            if line_count == 2:
                return row[1]
            line_count += 1

def runGeneration(gen, X):
    os.makedirs(os.path.dirname(inputFileName(gen,0)),exist_ok=True)
    with open("gen" + str(gen) + ".csv", mode="w") as gen_results:
        gen_writer = csv.writer(gen_results, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        for pop_ID in range(len(X)):
            print(str(pop_ID))
            makeMeshFile(gen, pop_ID, X[pop_ID][0], X[pop_ID][1])
            makeInputFile(gen, pop_ID)
            runMoose(gen, pop_ID)
            X[pop_ID].append(getSimulationResultCSV(gen, pop_ID))
        gen_writer.writerows(X)

def printNestedList(nList):
    print('\n'.join([str(lst) for lst in nList]))

def geneticAlgorithmNextGen(prev, eliteFrac = 0.05, crossoverFrac = 0.3):
    X = []
    p_size = len(prev)
    elite_ind = math.ceil(p_size * eliteFrac)
    co_ind = math.floor((p_size - elite_ind) * crossoverFrac) + elite_ind

    elite = prev[:elite_ind]
    CO = prev[elite_ind:co_ind]
    mutate = prev[co_ind:]

    X += elite
    X += computeCrossOver(elite, CO)
    X += computeMutation(mutate)
    return X

def diffRandomInRange(L):
    i = np.random.randint(0,L)
    j = np.random.randint(0,L)
    if i == j:
        return diffRandomInRange(L)
    else:
        return [i, j]

def computeCrossOver(elite, CO):
    temp = elite + CO
    ans = []
    L = len(CO)
    T = len(temp)
    for asdf in range(0,L):
        [i,j] = diffRandomInRange(T)
        # [x,y] = diffRandomInRange(2)
        while not isSuitableIndividual([temp[i][0], temp[j][1]], 0.1):
            [i,j] = diffRandomInRange(T)
            # [x,y] = diffRandomInRange(2)
        ans.append([temp[i][0], temp[j][1]])
    return ans

def isSuitableIndividual(indv,R):
    return (computeVecNorm(indv[0], indv[1]) < R)

def listAdd(L1, L2):
    return [float(L1[i]) + float(L2[i]) for i in range(len(L1))]

def listSubtract(L1, L2):
    return [float(L1[i]) - float(L2[i]) for i in range(len(L1))]

def computeMutation(mutate):
    ans = []
    for indv in mutate:
        norm_x = 10000
        xn = 0
        yn = 0
        while norm_x >= 0.1:
            [x,y] = generateVecLtNorm(0.01)
            [xn, yn] = listAdd([x,y],indv)
            norm_x = computeVecNorm(xn,yn)
        ans.append([xn,yn])
    return ans


def readCSVandSort(fileName):
    p = []
    with open(fileName, mode = "r") as prev_results:
        prev_reader = csv.reader(prev_results, delimiter = ',')
        for row in prev_reader:
            p.append(row)
        prev_results.close()
    p.sort(key = lambda x : x[2], reverse = True)
    return p

def computeFitness(gen):
    if gen == 0:
        return 1000000
    else:
        curr = readCSVandSort("gen" + str(gen) + ".csv")
        for row in curr:
            row.pop()
        max = curr[0]
        ans = 0
        d = []
        for row in curr[1:]:
            [x1,x2] = listSubtract(row,max)
            d.append(computeVecNorm(x1,x2))
        for e in d:
            ans += e
        print(ans/len(d))
        return ans/len(d)

pop_size = 20
tol = 1e-10
gen = 0

sub.check_call(["rm -rf gen*"], shell=True)

while True:
    if gen == 0:
        X = []
        for pop in range(pop_size):
            X.append(generateVecLtNorm(0.1))

    runGeneration(gen, X)
    R = computeFitness(gen)
    if R < tol:
        print("Found solution within tolerance: "+ str(R) + " < " + str(tol))
        break
    print("Reading generation " + str(gen) + " results:")
    p = readCSVandSort("gen" + str(gen) + ".csv")
    for row in p:
        row.pop()
    printNestedList(p)
    X = geneticAlgorithmNextGen(p)
    print("Next generation will be:")
    printNestedList(X)
    gen += 1

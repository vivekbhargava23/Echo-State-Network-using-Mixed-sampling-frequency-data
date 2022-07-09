#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 11 15:21:35 2019

@author: vaishalibhargava
"""

import numpy as np
from numpy.linalg import inv

import statsmodels.api as sm

import pandas as pd
import statsmodels.formula.api as sm2
def olsfun(X,Y):
    """
    olsfun(X,Y)
    
    compute OLS and cov mat
    
    Parameters
    ---------
    X: (n,k) numpy.ndarray
        regressors, n observations , k number of paramaters
        
    Y: (n,1) numpy.ndarray
        dependent variables
        
    Returns
    beta: (k,1) np.ndarray
        OLS estimate
    
    V: 9k,k) numpy.ndarray
    covariance matrix of beta (simple form)
    
    Vw: (k,k) numpy.ndarray
        cv matrix, heteroskedasticity robust
        
    
    """
    
    # OLS estimate
    beta = inv(X.transpose() @ X) @ X.transpose() @ Y
    
    n,k = X.shape
    
    #residuals
    resid = Y - X @ beta
    
    #error variance
    sig2 = 1/(n-k)*np.sum(resid**2)
    
    
    #simple cov matrix
    V = sig2*inv(X.transpose() @ X)
    
    #Heteroscedasticity robust cov mat
    D = np.diag(resid.flatten()**2)
    Vw = inv(X.transpose() @ X) @ X.transpose() @ D @ X @ \
    inv(X.transpose() @ X)
    
    return beta, V, Vw

# b)
Data = pd.read_csv('hprice1.csv')
Y = np.array(Data.Price).reshape((-1,1))
X = np.array(Data)[:,[0,2,3,4]] #only columns 0,2,3,4
X = sm.add_constant(X)

#OLS Estimates
beta_OLS, V_OLS, V_white = olsfun(X,Y)

# Standard errors
std_OLS = np.sqrt(np.diag(V_OLS))
std_white = np.sqrt(np.diag(V_white))

# c)
B = 1000 # 1000 iterations

# make array and save the data
beta_boot = np.zeros((5,B)) # we want to save all our 5 estimates. Also it doesnt matter if you write B,5 or 5,B
t_boot = np.zeros((5,B))

for b in range (B):
    ind = np.random.choice(88,88)
    Xi = X[ind,:]
    Yi = Y[ind,:]
    
    betai, Vi, Vwi = olsfun(Xi,Yi)
    beta_boot[:,b] = betai.flatten() #if we dont use flatten - error, flatten makes it one dimension maybe
    
    stdi = np.sqrt(np.diag(Vwi))
    t_boot[:,b] = (betai - beta_OLS).flatten() /stdi
    
    
#d) 
std_boot = np.sqrt(np.var(beta_boot, axis=1))


#e)

#OLS
CI_OLS = np.array([beta_OLS.flatten() - 1.96 * std_OLS, beta_OLS.flatten() +1.96 * std_OLS]) #confidence interval

#white 
CI_white = np.array([beta_OLS.flatten() - 1.96 * std_white, beta_OLS.flatten() +1.96 * std_white])

#percentile
CI_percentile = np.quantile(beta_boot, [0.025, 0.975], axis=1)

#percentile t
CI_percentile_t = np.array([beta_OLS.flatten() - np.quantile(t_boot, 0.025, axis=1)*std_white,
                            beta_OLS.flatten() - np.quantile(t_boot, 0.975, axis=1)*std_white])






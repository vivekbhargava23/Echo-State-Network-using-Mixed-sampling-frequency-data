function [criterion_value,index,Lag_order] = lag_order_v2(y,m,intercept)

%{   
y -  k x (T+p) - matrix of y values
m max - number of lags in the VAR p process
intercept  - dummy value - 1 to include intercept and 0 for no intercept
%}
K = size(y,1);



for i = 1:m+1 % the values of m goes from 0 to m and hence loop is from 1 to m+1
    
    dat = y(:, m-i+2:end); % to ensure same quantity of data is used for estimation for different values of lag
    
    
    [B_hat,residual_covariance_hat_LS, t_ratio] = VAR_est(dat',(i-1),intercept); % the function VAR_est takes y' values, so we need to match the dimensions
    
    
    
    T1 = size(dat,2) - (i-1);
    residual_covariance_hat_MLE = residual_covariance_hat_LS * ((T1-(size(B_hat,2))) / T1); % we obtained residual covariance LS from the var_est function 
    % However, we require residual caovariance MLE, so we use values of T,m
    % and residual cov LS to get residual cov MLE
    
    Determinant_Residual_cov_MLE = det(residual_covariance_hat_MLE);
    
    % FPE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    DOF = (size(B_hat,2)); % = km + 1, this takes into account for intercept or no intercept case too. ex without intercept it should be only km and not km + 1
    penalty = (T1 + DOF)/(T1-DOF);
    
    FPE_m(i,:) = (penalty^K) * Determinant_Residual_cov_MLE;
    
    
    % AIC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    log_det_residual_cov_MLE = log(Determinant_Residual_cov_MLE);
    Second_term_AIC = 2*(K^2)*(i-1)/T1;
    
    AIC_m(i,:) = log_det_residual_cov_MLE + Second_term_AIC;
    
    
    % HQ
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Second_term_HQ = Second_term_AIC * log(log(T1)); % just multiplying log(log T)) to 2K^2.m/T (already calculated this term above)
    
    HQ_m(i,:) = log_det_residual_cov_MLE + Second_term_HQ;
    
    
    % SC
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    Second_term_SC = log(T1) * ((K^2)*(i-1)/T1);
    
    SC_m(i,:) = log_det_residual_cov_MLE + Second_term_SC;
    
end
  
criterion_value = [FPE_m, AIC_m, HQ_m, SC_m];

[~,index] = min(criterion_value);
Lag_order = index - 1;




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%






end


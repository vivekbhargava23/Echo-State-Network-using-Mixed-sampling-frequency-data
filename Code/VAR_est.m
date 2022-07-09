function [B_hat,residual_covariance_hat, t_ratio,ZZ_prime,ZZ_prime_by_T,U_hat] = VAR_est(y,p,intercept)
%VAR_EST Summary of this function goes here
%{
INPUTS - 
y  - (T+p) x k - matrix of y values   NOTE: the dimensions are different
(transposed) than the ones used in the main code or in other functions
p - number of lags in the VAR p process
intercept  - dummy value - 1 to include intercept and 0 for no intercept
%}


T = size(y,1) - p;

if p==0
    Z = ones(1,T);
    
else
    
    
    for i = 1:T
        Zt = [];
        for j = 1:p

            Zt = [Zt, y(p+i-j,:)];

        end

        Z(:,i) = Zt;
    end
    % Accomodating for the intercept
    if intercept == 1
        
        row_one = ones(1,T);
        Z = [row_one;Z];
    end
    
end
    
Y = y(p+1:p+T,:)';

% Estimating the parameter matrix B

B_hat = Y * Z' * inv (Z*Z');


% Estimating residual covariance matrix
U_hat = Y - B_hat * Z;

DOF = T - size(Z,1);
residual_covariance_hat = (1/DOF) * U_hat * U_hat';

% Calculating t-ratios
Diag = diag(kron (inv(Z*Z'),residual_covariance_hat));
std1 = sqrt(Diag);
% vecB = B_hat(:);
% t_ratio = vecB ./ std1

K = size(B_hat,1);
secdim = size(Z,1);
t_ratio = B_hat./ reshape(std1, K, secdim);


ZZ_prime =  (Z * Z');

ZZ_prime_by_T = ZZ_prime/T;

end


function [W_out] = train_ESN(ESN,X,Y_target)
%TRAIN_ESN Summary of this function goes here
%{
inputs:
 - X: Nx x T x N_reservoirs, contains the states 
 - Y_target: Ny x T
 - ESN: a struct files which contains the weights for the reservoirs

output:
 - W_out: Ny x 1+(Nx x N_reservoirs)
%}

if size(X,2)~=size(Y_target,2)
    disp("error in train_ESN: size doesnt match for states and target")
end

T_length = size(Y_target,2);

% concatenating all the columns in different reservoir states
Concatendated_X = Concatenate_layers(ESN,X);
% row of ones for bias

%Concatendated_X_with_bias = [ESN.bias * ones(1,T_length);Concatendated_X];
Concatendated_X_with_bias = [ones(1,T_length);Concatendated_X];

%removing the burning values
% Concatendated_X_after_burning_with_bias = Concatendated_X_with_bias(:,ESN.burn+1:end);
% Y_target_after_burning = Y_target(:,ESN.burn+1:end);

% Training Readout
W_out = Y_target * Concatendated_X_with_bias' / (Concatendated_X_with_bias*Concatendated_X_with_bias'+ ESN.regularization *eye(size(Concatendated_X_with_bias ,1)));


end


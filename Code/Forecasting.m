function [Y_pred] = Forecasting(ESN,states)
%FORECASTING Summary of this function goes here
%   Detailed explanation goes here

%{
input:
 - states: Nx x T_length x N_reservoir  ; 
where Nx is no of neurons
where T_length could be one for a vector or train/test length
output:

%}

T_length = size(states,2);

X_concatenated = Concatenate_layers(ESN,states);
X_concatenated_add_bias = [ones(1,T_length);X_concatenated];

%Concatendated_X_after_burning_with_bias = X_concatenated_add_bias(:,ESN.burn+1:end);


Y_pred = ESN.W_out * X_concatenated_add_bias;





end


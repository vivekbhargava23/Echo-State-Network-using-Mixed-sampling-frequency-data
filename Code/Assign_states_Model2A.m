function [X_combined,ESN_Quarterly,ESN_Monthly] = Assign_states_Model2A(input,ESN_Quarterly,ESN_Monthly)

% The function takes in input values and creates States space
% input = input_train

%{
inputs:
 - input: Nz x T, contains the value of the input 
 - ESN_Quarterly: a struct files which contains the weights for the reservoirs
 - ESN_Quarterly: a struct files which contains the weights for the reservoirs

output:
 - X: Nx x T x N_reservoirs, this returns the states space for the ESN
%}

T = size(input,2);

Unstacked_data = Data_sort_High_Freq(input,ESN_Quarterly.N_Monthly,ESN_Quarterly.N_Quarterly);
data_Quarterly = input(1:ESN_Quarterly.N_Quarterly,:);
data_Monthly = Unstacked_data(ESN_Quarterly.N_Quarterly+1:end,:);


[ESN_Quarterly.X,ESN_Quarterly.Last_state_layer] = Assign_states(ESN_Quarterly, data_Quarterly,ESN_Quarterly.Last_state_layer);

[ESN_Monthly.X,ESN_Monthly.Last_state_layer] = Assign_states(ESN_Monthly, data_Monthly,ESN_Monthly.Last_state_layer);

% Pre allocating Memory
M2Q_states = zeros(ESN_Monthly.Nx,T,ESN_Monthly.N_reservoirs);
X_combined = zeros((ESN_Quarterly.Nx + ESN_Monthly.Nx),T,ESN_Monthly.N_reservoirs);
for i = 1:T
    M2Q_states(:,i,:) = ESN_Monthly.X(:,i*3,:); % collecting all the last quarter states

end

for i = 1:ESN_Monthly.N_reservoirs
    X_combined(:,:,i) = [ESN_Quarterly.X(:,:,i);M2Q_states(:,:,i)]; % stacking Quarterly states and above collected monthly2Q states according to N_reservoirs
end





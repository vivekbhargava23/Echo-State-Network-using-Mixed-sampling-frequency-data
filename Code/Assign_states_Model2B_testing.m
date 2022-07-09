function [X_combined_2B,ESN_Quarterly,ESN_Monthly] = Assign_states_Model2B_testing(input,ESN_Quarterly,ESN_Monthly)

% The function takes in input values and creates States space
% input = input_test

%{
inputs:
 - input: Nz x T, contains the value of the input 
 - ESN_Quarterly: a struct files which contains the weights for the reservoirs
 - ESN_Quarterly: a struct files which contains the weights for the reservoirs

output:
 - X: Nx x T x N_reservoirs, this returns the states space for the ESN
%}
first_testing_Q_state = ESN_Quarterly.X(:,end,:);


len = size(input,2);

data_Quarterly = input(1:ESN_Quarterly.N_Quarterly,2:end); % value starts from 2 because for the first state we use directly from the ESn_Quarterly.Last layer
data_Monthly = input(ESN_Quarterly.N_Quarterly+1:end,:);

data_Quarterly_Qfreq = zeros(ESN_Quarterly.N_Quarterly,(len)/3);

for i = 1:(len)/3
    data_Quarterly_Qfreq(:,i) = data_Quarterly(:,(i-1)*3+1);
end


[ESN_Quarterly.X,ESN_Quarterly.Last_state_layer] = Assign_states(ESN_Quarterly, data_Quarterly_Qfreq,ESN_Quarterly.Last_state_layer);

[ESN_Monthly.X,ESN_Monthly.Last_state_layer] = Assign_states(ESN_Monthly, data_Monthly,ESN_Monthly.Last_state_layer);

% Pre allocating Memory
X_combined_2B = zeros((ESN_Quarterly.Nx + ESN_Monthly.Nx),len,ESN_Monthly.N_reservoirs);

for i = 1:len
    if (i==1)
        
        X_combined_2B(:,i,:) = [first_testing_Q_state;ESN_Monthly.X(:,i,:)];
    else
        idx = ceil((i-1)/3);
        X_combined_2B(:,i,:) = [ESN_Quarterly.X(:,idx,:);ESN_Monthly.X(:,i,:)];
    
    end
    %X_combined_2B(:,i,:) = [ESN_Quarterly.X(:,idx,:);ESN_Monthly.X(:,i,:)] % stacking Quarterly states and above collected monthly2Q states according to N_reservoirs
end





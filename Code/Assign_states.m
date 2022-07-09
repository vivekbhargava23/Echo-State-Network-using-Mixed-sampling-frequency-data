function [X,last_state_layer] = Assign_states(ESN, input, last_state_input)

% The function takes in input values and creates States space

%{
ESN =ESN_Model3, input = input_train,last_state_input);
inputs:
 - input: Nz x T, contains the value of the input 
 - ESN: a struct files which contains the weights for the reservoirs

output:
 - X: Nx x T x N_reservoirs, this returns the states space for the ESN
%}


%last_state_layer = ESN.Last_state_layer;
last_state_layer = last_state_input;

% This last state of layer is a Nx x N_reservoir matrix that contains the
% last state of each layer. For instance, column 2 contains the last state
% of 2nd layer


x = last_state_layer;

T_length = size(input,2);
X = zeros(ESN.Nx,T_length,ESN.N_reservoirs);

for i = 1:T_length
    
    for j = 1:ESN.N_reservoirs
        
        if j==1
            z = input(:,i);
            x(:,j) = (1-ESN.alpha)*x(:,j) + ESN.alpha * tanh(ESN.C_in * [1;z] + ESN.A_layer(:,:,j)*x(:,j));
        else
            z = x(:,j-1);
            x(:,j) = (1-ESN.alpha)*x(:,j) + ESN.alpha * tanh(ESN.C_inter_layer(:,:,j-1)*[1;z]+ESN.A_layer(:,:,j)*x(:,j));
        end

        X(:,i,j) = x(:,j);
        last_state_layer(:,j) = x(:,j);

    end
    
end
last_state_layer;
% ESN.Last_state_layer = last_state_layer;

% Be careful, if training and testing is done for more than one pair then
% make ESN.Last_state_layer = 0 or change it accordingly

end






























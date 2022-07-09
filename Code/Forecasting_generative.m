function [test_states_generative,Y_test_forecast_generative] = Forecasting_generative(ESN,input_test_vector,lags_to_predict)
%FORECASTING_GENERATIVE Summary of this function goes here
%   Detailed explanation goes here

%{
ESN = ESN_Model1
z = input_test_vector;
if size(z,2)>1
    disp('It should be a vector/one time period value for generative case')
end
%}

%last_state_input = ESN.Last_state_layer; % Nx x N_Reservoir just the last columns of a state Matrix put in 2 dimension

%{

no_of_input_variables = size(z,1);
random_noise = normrnd(0,1,[no_of_input_variables,lags_to_predict]);
%}


Y_test_forecast_generative = zeros(size(input_test_vector,1),size(input_test_vector,2),lags_to_predict);
test_states_generative = zeros(ESN.Nx,lags_to_predict,ESN.N_reservoirs);

for k = 1:size(ESN.test_states_predictive,2)
    last_state_input = ESN.test_states_predictive(:,k);
    %z = input_test_vector(:,k);

    %test_states_generative(:,i,:) = ESN.test_states_predictive(:,k);
    test_states_generative = ESN.test_states_predictive(:,k);

    for i = 1:lags_to_predict
        
        Y_test_forecast_generative(:,k,i) = Forecasting(ESN,test_states_generative);
        z = Y_test_forecast_generative(:,k,i) ;


        % Generating states 
        [test_states_generative,last_state_input] = Assign_states(ESN,z,last_state_input);
    
        %Y_test_forecast_generative(:,i) = Forecasting(ESN,test_states_generative(:,i,:));
        
        
        % + random_noise(:,i); % can remove the random noise
    
    end

end

% C(1,:) = Y_test_forecast_generative(1,1,:)




end


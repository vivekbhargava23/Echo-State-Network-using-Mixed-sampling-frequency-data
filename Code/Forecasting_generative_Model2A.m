function [test_states_generative,Y_test_forecast_generative] = Forecasting_generative_Model2A(ESN_model2A,input_test_vector,lags_to_predict,ESN_Quarterly,ESN_Monthly)
%FORECASTING_GENERATIVE Summary of this function goes here
%   Detailed explanation goes here


%z = input_test_vector;

%{
if size(z,2)>1
    disp('It should be a vector/one time period value for generative case')
end
%}
%Last_state_layer_generative = reshape(ESN.Last_state_layer,ESN.Nx,1,ESN.N_reservoirs) % Nx x 1 x N_reservoir matrix, basically just first column of a state matrix type dimension
%last_state_input = ESN.Last_state_layer; % Nx x N_Reservoir just the last columns of a state Matrix put in 2 dimension
% this ESN.Last_state_layer is still the last layer states from training,
% so it contains the state of Tth value

%{
no_of_input_variables = size(z,1);
random_noise = normrnd(0,1,[no_of_input_variables,lags_to_predict]);
%}

Y_test_forecast_generative = zeros(size(input_test_vector,1),size(ESN_model2A.test_states_predictive,2),lags_to_predict);

%test_states_generative = zeros((ESN_Quarterly.Nx+ESN_Monthly.Nx),T_length,ESN_Quarterly.N_reservoirs);



for k = 1:size(ESN_model2A.test_states_predictive,2)

    
    [test_states_generative,ESN_Quarterly,ESN_Monthly] = Assign_states_Model2A(input_test_vector(:,k),ESN_Quarterly,ESN_Monthly);
    ESN_Quarterly_temp = ESN_Quarterly;
    ESN_Monthly_temp = ESN_Monthly;


    %test_states_generative = ESN_model2A.test_states_predictive(:,k);
    %last_state_input = ESN_model2A.test_states_predictive(:,k);

    for i = 1:lags_to_predict

        Y_test_forecast_generative(:,k,i) = Forecasting(ESN_model2A,test_states_generative);

        z = Y_test_forecast_generative(:,k,i);



        
        % Generating states 
        [test_states_generative,ESN_Quarterly_temp,ESN_Monthly_temp] = Assign_states_Model2A(z,ESN_Quarterly_temp,ESN_Monthly_temp);
    
        %Y_test_forecast_generative(:,i) = Forecasting(ESN_model2A,test_states_generative(:,i,:));
        
        
        %z = Y_test_forecast_generative(:,i);% + random_noise(:,i); % can remove the random noise
    
    end
end






end


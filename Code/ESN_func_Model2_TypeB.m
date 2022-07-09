function [Y_test_forecast_predictive,Y_training_pred_Stacked,MSE_Training_Model2B,MSE_Testing_predictive,Y_test_forecast_generative] = ESN_func_Model2_TypeB(data,T,ESN_Quarterly, ESN_Monthly)
%ESN_FUNC Summary of this function goes here
%{
data = Total_kfold_data
data = rolling_data
data = Total_kfold_data
data = Stacked_data
data = data(:,1:12)
T=80
T = training_length-1
ESN_Quarterly = ESN_hyper_Quarter
ESN_Monthly = ESN_hyper_Month

ESN_Quarterly = ESN_Quarterly_2B
ESN_Monthly = ESN_Monthly_2B


Detailed explanation goes here
data: Nz x Total_length (training_testing)
T - number of inputs used in preparing states
T+1 - total training data
    so 1:T data used for X input
    and 2:T+1 data is used for target

ESN_Quarterly: is a struct file having parameters that have been optimized
using cross validation
Similarly for ESN_Monthly

Note:
We will write two state equations hence we need 2 ESNs
%}
%Training_length = (T+1)*3;
%Testing_length = size(data,2) * 3 - Training_length;
%T = Training_length - 1;

% Unstacking Data
Unstacked_data = Data_sort_High_Freq(data,ESN_Quarterly.N_Monthly,ESN_Quarterly.N_Quarterly);



% Training Data
input_train =  Unstacked_data(:,1:T*3); % Nz x T


Y_target =  Unstacked_data(:,3+1:(T+1)*3); % Ny x T
%Y_target =  data(1,2:T+1); % Ny x T   % this was used lately WHY!!

% Testing Data
input_test = Unstacked_data(:,T*3+1:end-3);
Y_testing = Unstacked_data(:,(T+1)*3+1:end);





%
% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Quarterly
ESN_Quarterly.Last_state_layer = zeros(ESN_Quarterly.Nx,ESN_Quarterly.N_reservoirs);

% Monthly
ESN_Monthly.Last_state_layer = zeros(ESN_Monthly.Nx,ESN_Monthly.N_reservoirs);

% Assigning States - Training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assigning states
[ESN_model2B.X,ESN_Quarterly.Last_state_layer,ESN_Monthly.Last_state_layer] = Assign_states_Model2B(input_train,ESN_Quarterly,ESN_Monthly,ESN_Quarterly.Last_state_layer,ESN_Monthly.Last_state_layer);
%Last_state_layer_Quarter_training = ESN_Quarterly.Last_state_layer
%Last_state_layer_Monthly_training = ESN_Monthly.Last_state_layer

ESN_model2B.burn = ESN_Quarterly.burn * 3;
ESN_model2B.N_reservoirs = ESN_Quarterly.N_reservoirs;
ESN_model2B.regularization = ESN_Quarterly.regularization;
ESN_model2B.N_Quarterly = ESN_Monthly.N_Quarterly;
ESN_model2B.N_Monthly = ESN_Monthly.N_Monthly;

% Training read-out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removing the first few burnouts
ESN_model2B.X = ESN_model2B.X(:,ESN_model2B.burn+1:end,:); % Note model2b has burn x 3 values compared to ESN_Quarterly burn # BE CAREFUL
Y_target = Y_target(:,ESN_model2B.burn+1:end);

% Training the Model
ESN_model2B.W_out = train_ESN(ESN_model2B,ESN_model2B.X,Y_target);


% Predicting Training states
ESN_model2B.Y_training_pred = Forecasting(ESN_model2B,ESN_model2B.X);
%Y_training_pred = ESN_model2B.Y_training_pred;
%Y_training_pred = Forecasting(ESN_model2A,ESN_model2A.X);


% Forecasting  PREDICTIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assigning States - Testing
ESN_model2B.test_states_predictive = Assign_states_Model2B(input_test,ESN_Quarterly,ESN_Monthly,ESN_Quarterly.Last_state_layer,ESN_Monthly.Last_state_layer);

% Forecasting
ESN_model2B.Y_test_forecast_predictive = Forecasting(ESN_model2B,ESN_model2B.test_states_predictive);
%Y_test_forecast_predictive = ESN_model2B.Y_test_forecast_predictive;
Y_test_forecast_predictive = High_freq_to_Low_freq(ESN_model2B.Y_test_forecast_predictive,ESN_Quarterly);

% Forecasting GENERATIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
lags_to_predict = 4; % 

stacked_test_length = size(input_test,2)/3;

Y_test_forecast_generative = zeros(size(data,1),stacked_test_length,lags_to_predict);

for k =1:stacked_test_length

    input_test_vector = input_test(:,(k-1)*3+1:k*3);

    [generative_states,ESN_Quarterly.Last_state_layer,ESN_Monthly.Last_state_layer] = Assign_states_Model2B(input_test_vector,ESN_Quarterly,ESN_Monthly,ESN_Quarterly.Last_state_layer,ESN_Monthly.Last_state_layer);
    
    generative_last_layer_Quarterly = ESN_Quarterly.Last_state_layer;
    generative_last_layer_Monthly = ESN_Monthly.Last_state_layer;

    for i = 1:lags_to_predict
        %[generative_states,generative_last_layer_Quarterly,generative_last_layer_Monthly] = Assign_states_Model2B(input_test_vector,ESN_Quarterly,ESN_Monthly,generative_last_layer_Quarterly,generative_last_layer_Monthly);
        z = Forecasting(ESN_model2B,generative_states);
        Y_test_forecast_generative(:,k,i) = High_freq_to_Low_freq(z,ESN_model2B);
        
        [generative_states,generative_last_layer_Quarterly,generative_last_layer_Monthly] = Assign_states_Model2B(z,ESN_Quarterly,ESN_Monthly,generative_last_layer_Quarterly,generative_last_layer_Monthly);

    end
end



% Calculating Training and Testing Error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y_target_Stacked = data(:,2:T+1);
Y_target_Stacked = Y_target_Stacked(:,ESN_Quarterly.burn+1:end);
Y_training_pred_Stacked = High_freq_to_Low_freq(ESN_model2B.Y_training_pred,ESN_model2B);

MSE_Training_Model2B = Error_MSE(Y_target_Stacked,Y_training_pred_Stacked); 

% Testing Error
Y_testing_Stacked = High_freq_to_Low_freq(Y_testing,ESN_Quarterly);
MSE_Testing_predictive = Error_MSE(Y_testing_Stacked, Y_test_forecast_predictive);





%{
figure
plot(data(1,1:T))
hold on
plot(data(2,1:T))
hold off
%}



%{
n=1;
range = size(Y_target,2);
figure
plot(Y_target(n,1:range))
hold on
plot(ESN.Y_training_pred(n,1:range))
hold on
%scatter(1:range,ESN.Y_training_pred(n,1:range))
legend('Original','Predictive')
title('training')


n=1;
figure
plot(Y_testing(n,:))
hold on
plot(ESN.Y_test_forecast_predictive(n,:))
hold on
legend('Original','Predictive')
title('testing')
%plot(ESN.Y_test_forecast_generative(n,:))
%legend('Original','Predictive','Generative')



%{
n=2
range = size(Y_target,2);
figure
plot(Y_target(n,1:range))
hold on
plot(ESN.Y_training_pred(n,1:range))
legend('Original','Predictive')
title('training')


n=2
range = size(input_test,2)
figure
plot(Y_testing(n,1:range))
hold on
plot(ESN.Y_test_forecast_predictive(n,1:range))
legend('Original','Predictive')
title('testing')
%hold on
%plot(ESN.Y_test_forecast_generative(n,1:range))
%legend('Original','Predictive','Generative')

%}
%}


%}




%{
figure
plot(Y_testing(2,:))
hold on
plot(ESN.Y_test_forecast_predictive(2,:))
hold off
%plot(ESN.Y_test_forecast_generative(2,:))


%}




end




































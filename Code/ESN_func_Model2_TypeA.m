function [Y_test_forecast_predictive,Y_training_pred,MSE_Training,MSE_Testing_predictive,Y_test_forecast_generative] = ESN_func_Model2_TypeA(data,T,ESN_Quarterly, ESN_Monthly)
%ESN_FUNC Summary of this function goes here
%{
data=Total_kfold_data
T = training_length-1
ESN_Quarterly = ESN_hyper_Quarter
ESN_Monthly = ESN_hyper_Month

ESN_Quarterly = ESN_Quarterly_2A
ESN_Monthly = ESN_Monthly_2A

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


ESN_struct: contains the struct file with OPTIMIZED parameters other ESN
parameters will be defined in here

%}

% ESN = ESN_struct

%{
v4:
things to do -

1. Multistep training of the model and making predictions- like a rolling
window training 

%}

% Segregating data into Quarterly and Monthly time series



%}


% Seggregating Data into Quarterly and Monthly frequency



% Understanding Time period
%Training_length = T+1; % T+1 data
%Testing_length = size(data,2)-Training_length;

% Training Data
input_train =  data(:,1:T); % Nz x T
%input_train_Quarter = data_Quarterly(:,1:T);
%input_train_Monthly = data_Monthly(:,1:T*3)

Y_target =  data(:,2:T+1); % Ny x T
%Y_target =  data(1,2:T+1); % Ny x T   % this was used lately WHY!!

% Testing Data
input_test = data(:,T+1:end-1);
Y_testing = data(:,T+2:end);





%
% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% parameter common to Quarterly and Monthly ESN

%ESN.Ny = size(Y_target,1); % Ny is the number of output
%ESN.T = size(input_train,2);
%ESN.Test_length = Testing_length;
%ESN.Last_state_layer = zeros(ESN.Nx,ESN.N_reservoirs);


%}
% Quarterly

ESN_Quarterly.Last_state_layer = zeros(ESN_Quarterly.Nx,ESN_Quarterly.N_reservoirs);


% Monthly
ESN_Monthly.Last_state_layer = zeros(ESN_Monthly.Nx,ESN_Monthly.N_reservoirs);

% Assigning States - Training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Assigning states
[ESN_model2A.X,ESN_Quarterly,ESN_Monthly] = Assign_states_Model2A(input_train,ESN_Quarterly,ESN_Monthly);
%Last_state_layer_Quarter_training = ESN_Quarterly.Last_state_layer
%Last_state_layer_Monthly_training = ESN_Monthly.Last_state_layer

ESN_model2A.burn = ESN_Quarterly.burn;
ESN_model2A.N_reservoirs = ESN_Quarterly.N_reservoirs;
ESN_model2A.regularization = ESN_Quarterly.regularization;

% Training read-out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removing the first few burnouts
ESN_model2A.X = ESN_model2A.X(:,ESN_model2A.burn+1:end,:);
Y_target = Y_target(:,ESN_model2A.burn+1:end);

% Training the Model
ESN_model2A.W_out = train_ESN(ESN_model2A,ESN_model2A.X,Y_target);


% Predicting Training states
ESN_model2A.Y_training_pred = Forecasting(ESN_model2A,ESN_model2A.X);
Y_training_pred = ESN_model2A.Y_training_pred;
%Y_training_pred = Forecasting(ESN_model2A,ESN_model2A.X);


% Forecasting  PREDICTIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assigning States - Testing
ESN_model2A.test_states_predictive = Assign_states_Model2A(input_test,ESN_Quarterly,ESN_Monthly); % note if train and test is done for more than 1 iteration, See msg in fn Assign states

% Forecasting
ESN_model2A.Y_test_forecast_predictive = Forecasting(ESN_model2A,ESN_model2A.test_states_predictive);
Y_test_forecast_predictive = ESN_model2A.Y_test_forecast_predictive;

% Forecasting GENERATIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_test_vector = input_test;%(:,1);
lags_to_predict = 4;
[ESN_model2A.test_states_generative, Y_test_forecast_generative] = Forecasting_generative_Model2A(ESN_model2A, input_test_vector,lags_to_predict,ESN_Quarterly,ESN_Monthly);


% Calculating Training and Testing Error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MSE_Training = Error_MSE(Y_target,ESN_model2A.Y_training_pred);
MSE_Testing_predictive = Error_MSE(Y_testing, ESN_model2A.Y_test_forecast_predictive);
% MSE_Testing_generative = Error_MSE(Y_testing, ESN_model2A.Y_test_forecast_generative); 
% MSE for generative depends on no of lags to predict, use this accordingly




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




































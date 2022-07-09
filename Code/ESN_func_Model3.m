function [Y_test_forecast_predictive,Y_training_pred_Stacked,MSE_Training_Model3,MSE_Testing_predictive,Y_test_forecast_generative] = ESN_func_Model3(data,T,ESN_Model3)
%ESN_FUNC Summary of this function goes here
%{
T=9
data =Training_data 
data =Stacked_data
data = data(:,1:12)
ESN_Model3 = ESN_hyper
data = Total_kfold_data(:,1:12)
data = Total_kfold_data
T = training_length-1

Detailed explanation goes here
data: Nz x Total_length (training_testing)
data has first few rows are Quarterly data and remaining rows are Monthly
data

T - number of inputs used in preparing states
T+1 - total training data
    so 1:T data used for X input
    and 2:T+1 data is used for target

ESN: contains the struct file with necessary parameters

%}
Training_length = (T+1)*3;
Testing_length = size(data,2) * 3 - Training_length;
%T = Training_length - 1;

% Unstacking Data
Unstacked_data = Data_sort_High_Freq(data,ESN_Model3.N_Monthly,ESN_Model3.N_Quarterly);


% Training Data
input_train =  Unstacked_data(:,1:T*3); % Nz x T

Y_target =  Unstacked_data(:,3+1:(T+1)*3); % Ny x T
%Y_target =  data(1,2:T+1); % Ny x T   % this was used lately WHY!! -
%because input_train will be from 1:T and Y_target will be from 2:T+1 in
%normal ESN, In model 3 lets check

% Testing Data
input_test = Unstacked_data(:,T*3+1:end-1*3);
Y_testing = Unstacked_data(:,(T+1)*3+1:end);



%
% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ESN_Model3.Last_state_layer = zeros(ESN_Model3.Nx,ESN_Model3.N_reservoirs);



% Assigning States - Training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
last_state_input = ESN_Model3.Last_state_layer;
[ESN_Model3.X,ESN_Model3.Last_state_layer] = Assign_states(ESN_Model3, input_train,last_state_input);


% Training read-out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% removing the first few burnouts
ESN_Model3.X = ESN_Model3.X(:,ESN_Model3.burn*3+1:end,:);
Y_target = Y_target(:,ESN_Model3.burn*3+1:end);

% Training the Model
ESN_Model3.W_out = train_ESN(ESN_Model3,ESN_Model3.X,Y_target);


% Predicting Training states
ESN_Model3.Y_training_pred = Forecasting(ESN_Model3,ESN_Model3.X);
%Y_training_pred = Forecasting(ESN_Model3,ESN_Model3.X);
% Instead above use
%Y_training_pred = ESN_Model3.Y_training_pred; 


% Forecasting  PREDICTIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assigning States - Testing
ESN_Model3.test_states_predictive = Assign_states(ESN_Model3,input_test,ESN_Model3.Last_state_layer); % note if train and test is done for more than 1 iteration, See msg in fn Assign states

% Forecasting
ESN_Model3.Y_test_forecast_predictive = Forecasting(ESN_Model3,ESN_Model3.test_states_predictive);
%Y_test_forecast_predictive = Forecasting(ESN_Model3,ESN_Model3.test_states_predictive);
Y_test_forecast_predictive = High_freq_to_Low_freq(ESN_Model3.Y_test_forecast_predictive,ESN_Model3);

% Forecasting GENERATIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_test_vector = input_test(:,1:3);
lags_to_predict = 4; % 
generative_last_layer = ESN_Model3.Last_state_layer;
%Y_test_forecast_generative = zeros(size(data,1),lags_to_predict);

stacked_test_length = Testing_length/3;

Y_test_forecast_generative = zeros(size(data,1),stacked_test_length,lags_to_predict);



for k =1:stacked_test_length
    
    test_states_generative = ESN_Model3.test_states_predictive(:,(k-1)*3 +1:k*3);
    last_state_input = ESN_Model3.test_states_predictive(:,k*3);


    for i = 1:lags_to_predict
    
        z = Forecasting(ESN_Model3,test_states_generative);
        Y_test_forecast_generative(:,k,i) = High_freq_to_Low_freq(z,ESN_Model3);

        [test_states_generative,last_state_input] = Assign_states(ESN_Model3,z,last_state_input);



        %[generative_states,generative_last_layer] = Assign_states(ESN_Model3,input_test_vector,generative_last_layer);
        %input_test_vector = Forecasting(ESN_Model3,generative_states);
        %Y_test_forecast_generative(:,i) = High_freq_to_Low_freq(input_test_vector,ESN_Model3);
    end

end









% Calculating Training and Testing Error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Y_target_Stacked = data(:,2:T+1);
Y_target_Stacked = Y_target_Stacked(:,ESN_Model3.burn+1:end);
Y_training_pred_Stacked = High_freq_to_Low_freq(ESN_Model3.Y_training_pred,ESN_Model3);

MSE_Training_Model3 = Error_MSE(Y_target_Stacked,Y_training_pred_Stacked); 

% Testing Error
Y_testing_Stacked = High_freq_to_Low_freq(Y_testing,ESN_Model3);
MSE_Testing_predictive = Error_MSE(Y_testing_Stacked, Y_test_forecast_predictive);
%data(:,T+2:end)


% MSE_Testing_generative = Error_MSE(Y_testing_Stacked, Y_test_forecast_generative);
% Y_test_forecast_generative has more columns = no of lags to predict hence
% in order to calculate the MSE generative do it using
% Y_test_forecast_generative outside the function














end




































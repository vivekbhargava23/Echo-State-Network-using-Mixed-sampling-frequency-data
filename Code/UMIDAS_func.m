function [Y_test_forecast_predictive,Y_training_pred,MSE_Training,MSE_Testing_predictive,Y_test_forecast_generative] = ESN_func(data,T,ESN)
%ESN_FUNC Summary of this function goes here
%{
Detailed explanation goes here
data: Nz x Total_length (training_testing)
T - number of inputs used in preparing states
T+1 - total training data
    so 1:T data used for X input
    and 2:T+1 data is used for target
data = Stacked_data
ESN_struct: contains the struct file with necessary parameters
ESN = UMIDAS
%}

Training_length = T+1; % T+1 data
Testing_length = size(data,2)-Training_length;

% Training Data
input_train =  data(:,1:T); % Nz x T
Y_target =  data(:,2:T+1); % Ny x T
%Y_target =  data(1,2:T+1); % Ny x T

% Testing Data
input_test = data(:,T+1:end-1);
Y_testing = data(:,T+2:end);





%Training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
X = input_train;
ESN.Last_state_layer = input_train(:,end);
% Training read-out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Training the Model
ESN.W_out = train_ESN(ESN,X,Y_target);


% Predicting Training states
ESN.Y_training_pred = Forecasting(ESN,X);
Y_training_pred = ESN.Y_training_pred;


% Forecasting  PREDICTIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assigning States - Testing
ESN.test_states_predictive = input_test; %Assign_states(ESN,input_test,ESN.Last_state_layer); % note if train and test is done for more than 1 iteration, See msg in fn Assign states

% Forecasting
ESN.Y_test_forecast_predictive = Forecasting(ESN,ESN.test_states_predictive);
%Y_test_forecast_predictive = Forecasting(ESN,ESN.test_states_predictive);
% Similarly from above. use
Y_test_forecast_predictive = ESN.Y_test_forecast_predictive;

% Forecasting GENERATIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

lags_to_predict = 4;

Y_test_forecast_generative = zeros(size(input_test,1),size(input_test,2),lags_to_predict);



for k = 1:size(input_test,2)

    z = input_test(:,k);

    for i = 1:lags_to_predict
        
        Y_test_forecast_generative(:,k,i) = Forecasting(ESN,z);
        z = Y_test_forecast_generative(:,k,i);
        
    end
end


% Calculating Training and Testing Error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MSE_Training = Error_MSE(Y_target,ESN.Y_training_pred);
MSE_Testing_predictive = Error_MSE(Y_testing, ESN.Y_test_forecast_predictive);
%MSE_Testing_generative = Error_MSE(Y_testing, Y_test_forecast_generative);




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




































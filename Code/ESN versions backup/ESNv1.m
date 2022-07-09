




% Loading Data


clc
clear all
close all


rng('default')

%{
Data 1
data = load('MackeyGlass_t17.txt');

%}


%
% Data 2

data = load('MackeyGlass_t17.txt');

burn = 500;
T = 10000 + burn;
A1 = 0.8; % coefficient

% Generating error terms
err = normrnd(0,1,[T,1]);

demo_series = zeros(T,1);

for i = 2:T
    %demo_series(i,:) = A1 * demo_series(i-1,:) + err(i);
    demo_series(i,:) = 0.5 + 0.001*i +A1 * demo_series(i-1,:) + err(i);
end

y_t = demo_series(burn+1: end,:);

% data=y_t;
data = [data,y_t];

%define total data
%1000 data
Total_data = 2000
data = data(1001:1000+Total_data,:)';

%define training data
T = 1500
%rest will be testing data




%}

%{
%data = csvread('DFF.csv',1,1);
%data = data(5000:9100)'
data = csvread('GDPC1.csv',1,1);
%data=data'
data = log(data)'
%}


% T = 200
%data = data(1001:1000+(T+T/4),:)';
%}




Training_length = T+1 % T+1 data
Testing_length = size(data,2)-Training_length

% Training Data
input_train =  data(:,1:T); % Nz x T
Y_target =  data(:,2:T+1); % Ny x T

% Testing Data
input_test = data(:,T+1:end-1);
Y_testing = data(:,T+2:end);






% Initialize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ESN.Nx = 10;  %T/4; % Nx is the number of neurons in each layer or in each reservoir
ESN.Nz = size(input_train,1); % Nz is the number of inputs
ESN.Ny = size(Y_target,1); % Ny is the number of output
ESN.N_reservoirs = 2; % Number of reservoirs
ESN.alpha = 0.8;
ESN.spec_radius = 1.2;
ESN.T = size(input_train,2);
ESN.burn = 0;
ESN.regularization = 1e-8;
ESN.Test_length = Testing_length;

ESN.Last_state_layer = zeros(ESN.Nx,ESN.N_reservoirs);



% Assigning weights to Matrices in the reservoirs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assigning random weight matrices for input to reservoir -> Matrix C_in
ESN.C_in = 2*rand(ESN.Nx,1+ESN.Nz)-1;

% Assigning weights between reservoirs -> Matrix C_layer
for i = 1:ESN.N_reservoirs-1
    ESN.C_inter_layer(:,:,i) = 2*rand(ESN.Nx,1+ESN.Nx)-1;
end

% Assigning weights to neurons within a reservoir -> Matrix A_layer
for i = 1:ESN.N_reservoirs
    ESN.A_layer(:,:,i) = 2*rand(ESN.Nx,ESN.Nx)-1;

    % Normalizing wrt the spectral radius
    eigen_values = eig(ESN.A_layer(:,:,i));
    max_abs_eig_value = max(abs(eigen_values));
    ESN.A_layer(:,:,i) = ESN.spec_radius * ESN.A_layer(:,:,i) / max_abs_eig_value;
end



% Assigning States - Training
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
last_state_input = ESN.Last_state_layer;
[ESN.X,ESN.Last_state_layer] = Assign_states(ESN, input_train,last_state_input);


% Training read-out
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
ESN.W_out = train_ESN(ESN,ESN.X,Y_target);
% Predicting Training states
ESN.Y_training_pred = Forecasting(ESN,ESN.X);

% Forecasting  PREDICTIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Assigning States - Testing
ESN.test_states_predictive = Assign_states(ESN,input_test,ESN.Last_state_layer); % note if train and test is done for more than 1 iteration, See msg in fn Assign states

% Forecasting
ESN.Y_test_forecast_predictive = Forecasting(ESN,ESN.test_states_predictive);

% Forecasting GENERATIVE MODE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
input_test_vector = input_test(:,1);
lags_to_predict = ESN.Test_length;
[ESN.test_states_generative, ESN.Y_test_forecast_generative] = Forecasting_generative(ESN, input_test_vector,lags_to_predict);


% Calculating Training and Testing Error
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
MSE_Training = Error_MSE(Y_target,ESN.Y_training_pred)
MSE_Testing_predictive = Error_MSE(Y_testing, ESN.Y_test_forecast_predictive)
MSE_Testing_generative = Error_MSE(Y_testing, ESN.Y_test_forecast_generative)




%{
figure
plot(data(1,1:T))
hold on
plot(data(2,1:T))
hold off
%}

n=1
range = 100


figure
plot(Y_testing(n,:))
hold on
plot(ESN.Y_test_forecast_predictive(n,:))
hold on
plot(ESN.Y_test_forecast_generative(n,:))
legend('Original','Predictive','Generative')

 % size(input_test,2)
figure
plot(Y_testing(n,1:range))
hold on
plot(ESN.Y_test_forecast_predictive(n,1:range))
hold on
plot(ESN.Y_test_forecast_generative(n,1:range))
legend('Original','Predictive','Generative')


figure
plot(Y_target(n,1:range))
hold on
plot(ESN.Y_training_pred(n,1:range))


%{
figure
plot(Y_testing(2,:))
hold on
plot(ESN.Y_test_forecast_predictive(2,:))
hold off
%plot(ESN.Y_test_forecast_generative(2,:))


%}





































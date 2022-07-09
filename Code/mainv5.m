%{
16 Feb folder
15 feb night- fixed window empirical results in word
all models working decently - check 15 feb folder
%}



% Loading Data

clc
clear all
%close all

rng('default')


%
%Data 4
%load('example.mat')


start_date = datetime('1985-02-02')
end_date = datetime('2011-02-02')
number_of_lags = 1

[Stacked_data,Quarter_wise_data,quarter_name,N_Monthly,N_Quarterly]= Loading_data_v2(start_date,end_date,number_of_lags);

Stacked_data = table2array(Stacked_data);

%}

% Defining Training and Testing
% Training data = T+1
% Testing Data is remaining
T = 80 % refers to training data for states; although total training data is T+1
Window_length = T+2 % T=60 refers to 15 years of quarterly value and 2 corresponds to 1 extra value for target and 1 extra value for testing
Training_data = Stacked_data(:,1:T+1);
Testing_data = Stacked_data(:,T+2:end);

%{
For Rolling Window
1:T are inputs used for initiallizing states
2:T+1 are T values used for target
and Window_length is (T+1) + 1
T+1 total training data
1 testing data

For normal one time purpose
Window_length = total data; size(data,2)
%}

% Hyperparameter Optimization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Model 1 Initiallization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data_Mod1 = Stacked_data;
Data_Mod1_training = Stacked_data(:,1:T+1);
%%%%%%
ESN_Model1 = Hyperparameter_selection1(Data_Mod1_training,N_Monthly,N_Quarterly)
%%%%%%


% Model 2 Initiallization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data_Mod2_training = Stacked_data(:,1:T+1);
[ESN_Quarterly_2A,ESN_Monthly_2A] = Hyperparameter_selection2A(Data_Mod2_training,N_Monthly,N_Quarterly)
[ESN_Quarterly_2B,ESN_Monthly_2B] = Hyperparameter_selection2B(Data_Mod2_training,N_Monthly,N_Quarterly)


% Model 3 Initiallization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data_Mod3_training = Stacked_data(:,1:T+1);
ESN_Model3 = Hyperparameter_selection3(Data_Mod3_training,N_Monthly,N_Quarterly);

% Model 4 - Benchmark - UMIDAS Initiallization
%%%%%%%%%%%%%%%%%%%%%%%%%%%%


UMIDAS.N_reservoirs = 1        
UMIDAS.alpha = 1
UMIDAS.bias = 1
UMIDAS.A_layer = 0;
UMIDAS.C_in = 1;
UMIDAS.C_inter_layer = 1;
UMIDAS.burn = 0;
UMIDAS.regularization = 0;
UMIDAS.Nx = size(Stacked_data,1)
%UMIDAS.Nx = size(Stacked_data,1)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%
% Rolling Window
number_of_lags = 4
Rolling_Training_target = zeros(size(Stacked_data,1),T,size(Stacked_data,2)-Window_length+1);
%Rolling_Training_pred = zeros(size(data,1),T-ESN_struct.burn,size(data,2)-Window_length+1);
Rolling_test_pred = [];
Rolling_Training_pred = [];
Rolling_MSE_Training = [];
Rolling_MSE_Pred = [];
Y_gen = [];
lag_wise_forecast = [];
Rolling_Test_input = [];


for i = 1:size(Stacked_data,2)-Window_length+1 % these many rolling windows will run

    index = i:i+Window_length-1;
    rolling_data = Stacked_data(:,index);
    
    Rolling_Training_target(:,:,i) = rolling_data(:,2:end-1);
    Rolling_Test_input(:,i) = rolling_data(:,end);
    
    
    %[Rolling_test_pred(:,i),Rolling_Training_pred(:,:,i),Rolling_MSE_Training(:,i),Rolling_MSE_Pred(:,i),Y_gen(:,i,:)] = ESN_func(rolling_data,T,ESN_Model1);
    %[Rolling_test_pred(:,i),Rolling_Training_pred(:,:,i),Rolling_MSE_Training(:,i),Rolling_MSE_Pred(:,i),Y_gen(:,i,:)] = ESN_func_Model2_TypeA(rolling_data,T,ESN_Quarterly_2A,ESN_Monthly_2A);
    %[Rolling_test_pred(:,i),Rolling_Training_pred(:,:,i),Rolling_MSE_Training(:,i),Rolling_MSE_Pred(:,i),Y_gen(:,i,:)] = ESN_func_Model2_TypeB(rolling_data,T,ESN_Quarterly_2B,ESN_Monthly_2B);
    [Rolling_test_pred(:,i),Rolling_Training_pred(:,:,i),Rolling_MSE_Training(:,i),Rolling_MSE_Pred(:,i),Y_gen(:,i,:)] = ESN_func_Model3(rolling_data,T,ESN_Model3);

    %[Rolling_test_pred(:,i),Rolling_Training_pred(:,:,i),Rolling_MSE_Training(:,i),Rolling_MSE_Pred(:,i),Y_gen(:,i,:)] = UMIDAS_func(rolling_data,T,UMIDAS);
    % 
    
    %lag_wise_forecast(1:number_of_lags,i) = Y_gen(1,1:number_of_lags)'; % row 1 means lag 1, row 2 means lag 2
    
end
%}
% Complete Window - Only one Time training - FIXED TRAINING WINDOW

[Complete_Window_test_pred,Complete_Window_Training_pred,Complete_Window_MSE_Training,Complete_Window_MSE_Pred,Y_genC] = ESN_func(Stacked_data,T,ESN_Model1);
[Complete_Window_test_pred,Complete_Window_Training_pred,Complete_Window_MSE_Training,Complete_Window_MSE_Pred,Y_genC] = ESN_func_Model2_TypeA(Stacked_data,T,ESN_Quarterly_2A,ESN_Monthly_2A);
[Complete_Window_test_pred,Complete_Window_Training_pred,Complete_Window_MSE_Training,Complete_Window_MSE_Pred,Y_genC] = ESN_func_Model2_TypeB(Stacked_data,T,ESN_Quarterly_2B,ESN_Monthly_2B);
[Complete_Window_test_pred,Complete_Window_Training_pred,Complete_Window_MSE_Training,Complete_Window_MSE_Pred,Y_genC] = ESN_func_Model3(Stacked_data,T,ESN_Model3);

[Complete_Window_test_pred_Model_UMIDAS,Complete_Window_Training_pred_Model_UMIDAS,Complete_Window_MSE_Training_Model_UMIDAS,Complete_Window_MSE_Pred_Model_UMIDAS,Y_genC] = UMIDAS_func(Stacked_data,T,UMIDAS);



burn = 2; % Check this burning should be equal to initialize_model value
Y_target =  Stacked_data(:,2:T+1); % Ny x T, it starts from 2 because the first entry is used for making states and second col is the Y_target
Y_target = Y_target(:,burn+1:end);
Date_target = quarter_name(:,2:T+1);
Date_target = Date_target(:,burn+1:end);

Y_testing = Stacked_data(:,T+2:end);
Date_testing = quarter_name(:,T+2:end);
n=1
t_target = datetime(Date_target,'InputFormat','QQQ yyyy');
t_test = datetime(Date_testing,'InputFormat','QQQ yyyy');



%
% Rolling Window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
n=1;
%

training_window = 22; % this could be the anywhere between 1 to total number of rolling_windows since we train the model multiple times

figure
plot(Stacked_data(n,1+burn+training_window:training_window+T)) % Correct - this takes Y_target values for training window 1, there are 32 training windows and for each window this should change
hold on
plot(Rolling_Training_pred(n,1:end,training_window))
hold off
%scatter(1:range,ESN.Y_training_pred(n,1:range))
legend('Original','Predictive')
title('Rolling Window - training')


figure
plot(t_test,Y_testing(n,:))
hold on
plot(t_test,Rolling_test_pred(n,:))
hold off
legend('Original','Predictive')
title('Rolling Window - testing')

% lag wise
test_len = size(Y_testing,2)
for i = 1:number_of_lags
    Lagwise_Y_test = Y_testing(n,i:end);
    Lagwise_Y_test_roll = Y_gen(n,1:end-i+1,i);
    MSE_lag_wise(:,i) = Error_MSE(Lagwise_Y_test, Lagwise_Y_test_roll);
    
end
tableu = array2table(MSE_lag_wise,"RowNames",{'MSE error lag wise - Rolling Window'})

% Plotting for h lags ahead
figure
plot(t_test,Y_testing(n,:),"Color",[0 0 0],"LineWidth",1.2)
hold on
plot(t_test(1:end),Y_gen(n,1:end-1+1,1),"LineWidth",1)
hold on
plot(t_test(2:end),Y_gen(n,1:end-2+1,2),'--',"LineWidth",.75)
hold on
plot(t_test(3:end),Y_gen(n,1:end-3+1,3),':')
hold on
plot(t_test(4:end),Y_gen(n,1:end-4+1,4),'-.')
hold off
legend({'Actual','h = 1','h = 2','h = 3','h = 4'},'Fontsize',20,'Location','southeast')
set(gca,'Fontname','Times')
xlabel('Year')
ax = gca
ax.FontSize = 20;
title('Out-of-sample forecasts - Model 3 - Rolling window training','Fontsize',20)
% model name check #$%#$#
%}

% Fixed Window
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Training
figure
plot(t_target,Y_target(n,:),"Color",[0 0 0],"LineWidth",1)
hold on
plot(t_target,Complete_Window_Training_pred(n,:),"LineWidth",1)
hold off
legend('GDP growth','Fitted','Fontsize',14)
xlabel('Year')
set(gca,'Fontname','Times')
title('In-sample performance - Model 1 - Fixed window training','Fontsize',16) %check model1,2
% set model name



%Testing
n=1;
test_len = size(Y_testing,2);
for i = 1:number_of_lags
    Lagwise_Y_test = Y_testing(n,i:end);
    Lagwise_Y_test_gen = Y_genC(n,1:end-i+1,i);
    MSE_lag_wise_complete(:,i) = Error_MSE(Lagwise_Y_test, Lagwise_Y_test_gen);
end

table_comp3 = array2table(MSE_lag_wise_complete,"RowNames",{'MSE error lag wise - Complete Window'})

% Plotting for h lags ahead

figure
plot(t_test,Y_testing(n,:),"Color",[0 0 0],"LineWidth",1.2)
hold on
plot(t_test(1:end),Y_genC(n,1:end-1+1,1),"LineWidth",1)
hold on
plot(t_test(2:end),Y_genC(n,1:end-2+1,2),'--',"LineWidth",.75)
hold on
plot(t_test(3:end),Y_genC(n,1:end-3+1,3),':')
hold on
plot(t_test(4:end),Y_genC(n,1:end-4+1,4),'-.')
hold off
legend({'Actual','h=1','h=2','h=3','h=4'},'Fontsize',14,'Location','southeast')
set(gca,'Fontname','Times')
xlabel('Year')
ylabel('GDP growth %')
title('Out-of-sample performance - Model 3 - Fixed window training','Fontsize',16)
% set model name


% For UMIDAS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%m=10
%intercept =1
%[criterion_value,index,Lag_order] = lag_order_v2(Training_data,m,intercept)

n=1
burn = 0; %No burning for UMIDAS
Y_target =  Stacked_data(:,2:T+1); % Ny x T, it starts from 2 because the first entry is used for making states and second col is the Y_target
Y_target = Y_target(:,burn+1:end);
Date_target = quarter_name(:,2:T+1);
Date_target = Date_target(:,burn+1:end);
Y_testing = Stacked_data(:,T+2:end);
Date_testing = quarter_name(:,T+2:end);

range = size(Y_target,2);
t_target = datetime(Date_target,'InputFormat','QQQ yyyy')
figure
plot(t_target,Y_target(n,:),"Color",[0 0 0],"LineWidth",1)
hold on
plot(t_target,Complete_Window_Training_pred_Model_UMIDAS(n,:),"LineWidth",1)
hold off
legend('Actual','Fitted','Fontsize',20,'Location','southeast')
xlabel('Year')
set(gca,'Fontname','Times')
ax = gca
ax.FontSize = 20;
title('In-sample predictions - UMIDAS - Fixed window training','Fontsize',20) %check model1,2


t_test = datetime(Date_testing,'InputFormat','QQQ yyyy')
figure
plot(t_test,Y_testing(n,:),"Color",[0 0 0],"LineWidth",1)
hold on
plot(t_test,Complete_Window_test_pred_Model_UMIDAS(n,:),"LineWidth",1)
hold off
legend('Actual','Forecasted')
xlabel('Year')
ylabel('GDP growth %')
set(gca,'Fontname','Times')
title('Fixed window - testing UMIDAS')














%}





%}
%}
%}































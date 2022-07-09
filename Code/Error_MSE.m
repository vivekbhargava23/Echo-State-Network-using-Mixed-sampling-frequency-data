function [MSE] = Error_MSE(Y_actual,Y_pred)
%ERROR_MSE Summary of this function goes here
%   Detailed explanation goes here
%{
Y_actual = Y_target
Y_pred = ESN.Y_training_pred

figure
plot(Y_actual(1,:))
hold on
plot(Y_pred(1,:))

Y_actual: Ny x T_length
Y_pred: Ny x T_length
%}

%(Y_actual - Y_pred)
%(Y_actual - Y_pred).^2
MSE = mean((Y_actual - Y_pred).^2,2);

end


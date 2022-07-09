function [Avg_error] = Cross_validation1(theta3, Training_data, ESN_hyper)
%CROSS_VALIDATION1 Summary of this function goes here
%   Detailed explanation goes here
% ESN=ESN_hyper

ESN_hyper = Scaling('Model1',ESN_hyper, theta3);

Total_length = size(Training_data,2);
kfold = 5;
fold_length = round((0.375*Total_length)/kfold);
training_length = Total_length - kfold * fold_length;
MSE_error_fold_wise = zeros(kfold,1);

for i = 1:kfold

    kfold_window = (i-1)*fold_length+1:training_length+(i*fold_length);
    Total_kfold_data = Training_data(:,kfold_window);
    [~,~,~,MSE_Error] = ESN_func(Total_kfold_data,training_length-1,ESN_hyper);
    
    % Model 3
    %[~,~,~,~] = ESN_func_Model3(Total_kfold_data,training_length-1,ESN_hyper);

    MSE_error_fold_wise(i,:) = MSE_Error(1); % 1 means GDP growth rate OR first variable (first ROW) in the Stacked data


end

Avg_error = mean(MSE_error_fold_wise);

end 
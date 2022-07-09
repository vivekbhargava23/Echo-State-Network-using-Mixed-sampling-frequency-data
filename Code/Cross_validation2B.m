function [Avg_error_2B] = Cross_validation2B(theta3, Training_data, ESN_hyper_Quarter,ESN_hyper_Month)
%CROSS_VALIDATION1 Summary of this function goes here
%   Detailed explanation goes here
% 
[~,ESN_hyper_Quarter,ESN_hyper_Month,~] = Scaling('Model2',ESN_hyper_Quarter,theta3,ESN_hyper_Month);


Total_length = size(Training_data,2);
kfold = 5;
fold_length = round((0.375*Total_length)/kfold);

%kfold = 3;
%fold_length = round((0.3*Total_length)/kfold);

training_length = Total_length - kfold * fold_length;


%MSE_error_fold_wise_2A = zeros(kfold,1);
MSE_error_fold_wise_2B = zeros(kfold,1);

for i = 1:kfold

    kfold_window = (i-1)*fold_length+1:training_length+(i*fold_length);
    Total_kfold_data = Training_data(:,kfold_window);
    %[~,~,~,MSE_Error_2A] = ESN_func_Model2_TypeA(Total_kfold_data,training_length-1,ESN_hyper_Quarter,ESN_hyper_Month);
    [~,~,~,MSE_Error_2B] = ESN_func_Model2_TypeB(Total_kfold_data,training_length-1,ESN_hyper_Quarter,ESN_hyper_Month);

    %MSE_error_fold_wise_2A(i,:) = MSE_Error_2A(1);
    MSE_error_fold_wise_2B(i,:) = MSE_Error_2B(1);


end

%Avg_error_2A = mean(MSE_error_fold_wise_2A);
Avg_error_2B = mean(MSE_error_fold_wise_2B);

end

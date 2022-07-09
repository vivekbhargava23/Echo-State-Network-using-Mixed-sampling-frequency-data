function [Stacked_data] = High_freq_to_Low_freq(test_data,ESN_Quarterly)
%  test_data = Y_test_forecast_predictive
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

len = size(test_data,2);
low_freq_length = len/3;
Stacked_data = zeros((ESN_Quarterly.N_Quarterly + ESN_Quarterly.N_Monthly*3),low_freq_length);

for i = 1:low_freq_length
    
    Stacked_data(1:ESN_Quarterly.N_Quarterly,i) = mean(test_data(1:ESN_Quarterly.N_Quarterly,(i-1)*3 +1:i*3),2);

    for j = 1:ESN_Quarterly.N_Monthly
        Stacked_data(ESN_Quarterly.N_Quarterly + (j-1)*3 +1 : ESN_Quarterly.N_Quarterly + j*3,i) = test_data(ESN_Quarterly.N_Quarterly+j,(i-1)*3 +1:i*3)';
    end
end


end


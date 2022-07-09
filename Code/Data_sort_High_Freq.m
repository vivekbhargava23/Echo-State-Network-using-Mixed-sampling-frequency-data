function [output_data] = Data_sort_High_Freq(data,N_Monthly,N_Quarterly)
%DATA_SORT_HIGH_FREQ Summary of this function goes here
%   Detailed explanation goes here ESN = ESN_Mod3
%{
data: (N_Quarterly + N_Monthly*3) x t
N_Quarterly rows represent no of Quarterly freq variables

N_Monthly represent no of variables with monthly frequency
N_Monthly*3 rows represent these monthly values for corresponding quarter
for each Monthly_freq variable

For examples, N_Quarterly: 2, means GDP growth and IP is taken at Quarterly
frequency

N_Monthly:2, means Unemployment and int rates are taken which have Monthly
data available

so a particular column will look like
Q2_GDP
Q2_IP
M1_Unemp
M2_Unemp
M3_Unemp
M1_Int
M2_Int
M3_Int

output_data: (N_Quarterly + N_Monthly) x (tx3)
output column will be like
Q2_GDP          Q2_GDP
Q2_Ip           Q2_IP
M1_Unemp        M2_Unemp
M1_Int          M2_Int          .........

data = data(:,1:5)
output_data = zeros(4,15)
%}

t_length = size(data,2);
output_data = zeros((N_Monthly+N_Quarterly),t_length*3);
Q_data = data(1:N_Quarterly,:);
M_data = data(N_Quarterly+1:end,:);

for i = 1:t_length

    output_data(1:N_Quarterly,3*(i-1)+1:3*i) = Q_data(:,i) .* ones(N_Quarterly,3);
    
    for m = 1:N_Monthly

        output_data(N_Quarterly+m,3*(i-1)+1:3*i) = M_data(3*(m-1)+1:3*m,i)';
    end
end













end


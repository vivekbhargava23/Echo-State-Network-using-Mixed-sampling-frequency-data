function [Final_data,Quarter_wise_data,Corresponding_dates,no_of_variables_Monthly,no_of_variables_Quarterly] = Loading_data_v2(start_date,end_date,number_of_lags)

% Start_value : start value should ensure that in that .csv file all the
% variables have some value after that start value and hence the row vector
% doesnt contain NaN for any of the variables

% Using Only quarterly and monthly data



%start_date = datetime('1985-02-02')
%end_date = datetime('2011-02-02')

%number_of_lags = 2 % number of lags for Y_t as well as X_t

% these lags mean that a low frequency variable Y depends on 2 previous
% lags on variables of same frequency, AS WELL AS, it also depends on lags
% of EQUIVALENT high frequency variable. 

% Example - Low freq variable - GDP and CPI (quarterly values) and 
% high freq - unemploy and income
% Sp 2 lags mean, that GDP depends on two lags of itself and CPI (same
% freq) and also depends on 6 lags of unemploy and 6 lags of income


% these dates correspond to low frequency target data

% Loading Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% daily_SnP = readtable('Daily_Close.csv');



%{
daily  = readtable('Daily.csv');
start_value_daily = 6263
daily = daily(start_value_daily:end,:);
%}

start_value_monthly = 79; %12;
start_value_quarterly = 52;


%monthly = readtable('Monthly.csv'); % OLD data
%monthly = monthly(start_value_monthly:end,:);

%1 monthly = readtable('Monthly_new.csv');
%1 monthly = monthly(start_value_monthly:end,1:end-1); % removing treasury data
%monthly = monthly(start_value_monthly:end,:); % include treasury new monthly data



%quarterly = readtable('Quarterly2.csv'); % OLD data
%quarterly = readtable('Quarterly_new.csv'); % UNIT - growth rate previous period - Consumer Price Index: Total All Items for the United States, Growth Rate Previous Period, Not Seasonally Adjusted (CPALTT01USM657N)
%1 quarterly = readtable('Quarterly_new1.csv');  %UNIT % change - MONTHLY - Consumer Price Index for All Urban Consumers: All Items in U.S. City Average, Index 1982-1984=100, Seasonally Adjusted (CPIAUCSL)

%1 quarterly = quarterly(start_value_quarterly:end,:);
%quarterly = quarterly(start_value_quarterly:end,1:end-1); % removing last CPI


% Monthly4 GDP - quarterly, CPI, UNempl, FFR - Monthly
monthly = readtable('Monthly4.csv');
monthly = monthly(start_value_monthly:end,1:end-1);
quarterly = readtable('Quarterly_new1.csv');
quarterly = quarterly(start_value_quarterly:end,1:end-1);

% Removing NaNs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%{
daily_oil = str2double(table2array(daily(:,2)));
daily_values_double = [daily_oil,table2array(daily(:,3))];

% Removing NaNs
daily_values_double_wNaN = fillmissing(daily_values_double,'previous');
%}

monthly_values_double = table2array(monthly(:,2:end));
monthly_values_double_wNaN = fillmissing(monthly_values_double,'previous');
no_of_variables_Monthly = size(monthly_values_double,2)

quarterly_value_double = table2array(quarterly(:,2:end));
quarterly_value_double_wNaN = fillmissing(quarterly_value_double,'previous');
no_of_variables_Quarterly = size(quarterly_value_double,2)

% Making Timetable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TT_quarterly = table2array(quarterly(:,1));
TT_monthly = table2array(monthly(:,1));
% TT_daily = table2array(daily(:,1));

Discretized_quarterly = string(discretize(TT_quarterly,'quarter','categorical'));
Discretized_monthly = string(discretize(TT_monthly,'quarter','categorical'));
%Discretized_daily = string(discretize(TT_daily,'quarter','categorical'));


% Concatenating series according to quarter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



start_index_name = string(discretize(start_date,'quarter','categorical'));
end_index_name = string(discretize(end_date,'quarter','categorical'));

start_index = find(start_index_name == Discretized_quarterly);
end_index = find(end_index_name == Discretized_quarterly);


quarter_series_start_date = TT_quarterly(1); %table2array(quarterly(1,1))
month_series_start_date = TT_monthly(1); %table2array(monthly(1,1))

%daily_series_start_date = TT_daily(1) %table2array(daily(1,1))

%{
% finding min frequency of daily data for each quarter
S = timerange(start_date,end_date,'quarters');
timetable_daily = table2timetable(daily);
daily_data_for_timerange = timetable_daily(S,:);

converting_to_table = timetable2table(daily_data_for_timerange(:,1));
daily_datetime_data_for_timerange = table2array(converting_to_table(:,1));
A = discretize(daily_datetime_data_for_timerange,'quarter','categorical');

uv = unique(A);
figure
hist(A)
title('Daily data  in each quarter')
n=hist(A,uv);
[min_frequency,i] = min(n);
%}



Concatenate_quarterly_data = zeros(size(quarterly_value_double_wNaN,2),(end_index-start_index+1));
Concatenate_monthly_data = zeros(3*size(quarterly_value_double_wNaN,2),(end_index-start_index+1));
quarter_name = strings(1,(end_index-start_index+1));


if start_date>=quarter_series_start_date && start_date>=month_series_start_date %&&  start_date>=daily_series_start_date
    
    for t = 1:(end_index-start_index+1)
        quarter_name(1,t) = Discretized_quarterly(start_index+t-1,1); %string(discretize(TT_quarterly(start_index+t-1,1),'quarter','categorical'))
        to_find = string(quarter_name(1,t));
        %
        Concatenate_quarterly_data(:,t)  = quarterly_value_double_wNaN(start_index+t-1,:)';
        %{
        for q = 1:size(quarterly_value_double_wNaN,2)
            
            Concatenate_quarterly_data(q,t) = quarterly_value_double_wNaN(start_index+t-1,q)
        end
        %}
        
        for m = 1:size(monthly_values_double_wNaN,2)
            
            %to_find = string(quarter_name(1,t))
            index = find(to_find == string(discretize(TT_monthly,'quarter','categorical')));

            Concatenate_monthly_data((m-1)*3+1:m*3,t) = monthly_values_double_wNaN(index,m);
        end
        %}
        %{
        for d = 1:size(daily_values_double_wNaN,2)
            %to_find = string(quarter_name(1,t));
            index = find(to_find == Discretized_daily);
            final_index = index(1:min_frequency);
            Concatenate_daily_data((d-1)*min_frequency+1:d*min_frequency,t) = daily_values_double_wNaN(final_index,d);
        end
        %}
    end
else
    disp("ERROR in Loading Data: Values for some higher frequency data are missing for the quarterly data")
end



Concatendated_quarter_wise = [Concatenate_quarterly_data;Concatenate_monthly_data]; %;Concatenate_daily_data];
table_with_headers = array2table(Concatendated_quarter_wise,"VariableNames",quarter_name);


Concatenated_lags_wise = [];

for t = 1:(end_index-start_index+1)-number_of_lags+1
    
    dummy_column_collector = [];
    for j = 1:number_of_lags

        dummy_column_collector = [Concatendated_quarter_wise(:,t+j-1);dummy_column_collector];

    end

    Concatenated_lags_wise(:,t) = dummy_column_collector;

end

Corresponding_dates = quarter_name(number_of_lags:end);

Final_data = array2table(Concatenated_lags_wise,"VariableNames",Corresponding_dates);

Quarter_wise_data = array2table(Concatendated_quarter_wise,"VariableNames",quarter_name);


%save('Concatendated_lags.mat',"Final_data")


%}
%}
%}
%}















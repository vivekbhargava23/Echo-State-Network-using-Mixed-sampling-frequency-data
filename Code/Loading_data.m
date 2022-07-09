
clc
clear all
close all

% Start_value : start value should ensure that in that .csv file all the
% variables have some value after that start value and hence the row vector
% doesnt contain NaN for any of the variables

% Loading Data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daily_SnP = readtable('Daily_Close.csv');


daily  = readtable('Daily.csv');
start_value_daily = 6263
daily = daily(start_value_daily:end,:);



monthly = readtable('Monthly.csv');
start_value_monthly = 12
monthly = monthly(start_value_monthly:end,:);


quarterly = readtable('Quarterly2.csv');
start_value_quarterly = 85
quarterly = quarterly(start_value_quarterly:end,:);



% Removing NaNs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
daily_oil = str2double(table2array(daily(:,2)));
daily_values_double = [daily_oil,table2array(daily(:,3))];

% Removing NaNs
daily_values_double_wNaN = fillmissing(daily_values_double,'previous');


monthly_values_double = table2array(monthly(:,2:end));
monthly_values_double_wNaN = fillmissing(monthly_values_double,'previous');


quarterly_value_double = table2array(quarterly(:,2:end));
quarterly_value_double_wNaN = fillmissing(quarterly_value_double,'previous');


% Making Timetable
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

TT_quarterly = table2array(quarterly(:,1));
TT_monthly = table2array(monthly(:,1));
TT_daily = table2array(daily(:,1));

Discretized_quarterly = string(discretize(TT_quarterly,'quarter','categorical'));
Discretized_monthly = string(discretize(TT_monthly,'quarter','categorical'));
Discretized_daily = string(discretize(TT_daily,'quarter','categorical'));


% Concatenating series according to quarter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start_date = datetime('1986-04-07')
end_date = datetime('2019-06-13')

start_index_name = string(discretize(start_date,'quarter','categorical'))
end_index_name = string(discretize(end_date,'quarter','categorical'))

start_index = find(start_index_name == Discretized_quarterly)
end_index = find(end_index_name == Discretized_quarterly)


quarter_series_start_date = TT_quarterly(1) %table2array(quarterly(1,1))
month_series_start_date = TT_monthly(1) %table2array(monthly(1,1))
daily_series_start_date = TT_daily(1) %table2array(daily(1,1))

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




Concatenate_quarterly_data = [];
Concatenate_monthly_data = [];



if start_date>=quarter_series_start_date && start_date>=month_series_start_date &&  start_date>=daily_series_start_date
    a=1
    for t = 1:(end_index-start_index+1)
        quarter_name(1,t) = Discretized_quarterly(start_index+t-1,1) %string(discretize(TT_quarterly(start_index+t-1,1),'quarter','categorical'))
        to_find = string(quarter_name(1,t))
        %
        for q = 1:size(quarterly_value_double_wNaN,2)
            
            Concatenate_quarterly_data(q,t) = quarterly_value_double_wNaN(start_index+t-1,q);
        end

        
        %
        for m = 1:size(monthly_values_double_wNaN,2)
            
            %to_find = string(quarter_name(1,t))
            index = find(to_find == string(discretize(TT_monthly,'quarter','categorical')));

            Concatenate_monthly_data((m-1)*3+1:m*3,t) = monthly_values_double_wNaN(index,m);


        end
        %}

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



Final_data = [Concatenate_quarterly_data;Concatenate_monthly_data;Concatenate_daily_data];
table_with_headers = array2table(Final_data,"VariableNames",quarter_name)


save('example.mat',"table_with_headers")
%{


col1 = table2array(daily(:,1))
col2 = table2array(monthly(:,1))
col3 = table2array(quarterly(:,1))

daily_value = table2array(daily(:,2:end))
monthly_value = table2array(monthly(:,2:end))
qtr_value = table2array(quarterly(:,2:end))


A1=table2timetable(daily)
A2=table2timetable(monthly)
A3=table2timetable(quarterly)


[Y1,E] = discretize(col1,'quarter') 


[Y1,E1] = discretize(table2array(daily(:,1)),'quarter','categorical')

figure
hist(Y2)

[Y2,E2] = discretize(table2array(monthly(:,1)),'quarter','categorical') 
[Y3,E3] = discretize(col3,'quarter','categorical') 


for i = 1:size(quarterly,1)

idx = (find(string(Y3(33))==string(Y1)))




AA = string(Y2(1))
AB = string(Y2(2))



S = timerange('2018-01-01','2018-02-01','quarters') %starts with quarter of first date and end with quarter of second date

S = timerange('2018-01-01','2018-02-01','years')

YY = num2str(YY)

S = timerange(YY,'years')



A2 = A(S,:)


col1_wNaN = fillmissing(col1,'previous')


%}
%}
%}
%}















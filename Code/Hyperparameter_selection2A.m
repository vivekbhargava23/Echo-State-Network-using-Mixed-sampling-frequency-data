function [ESN_Quarterly_2A,ESN_Monthly_2A] = Hyperparameter_selection2A(Training_data,N_Monthly,N_Quarterly,neurons)
%CROSS_VALIDATION_MODELS Summary of this function goes here
%   Detailed explanation goes here

% Sorting data into high and low frequency

rng('default')
neurons = [10:5:30,50,100]; % used with maxfuneval as 10000



A = [];
b = [];
Aeq = [];
beq = [];
% theta3 = [gammaQ, rhoQ, alphaQ, lambda, biasQ, gammaM,rhoM,alphaM,biasM]

lb = [-10000,0.1,0.001,0,-10000000,-10000,0.1,0.001,-1000000];
ub = [100000,4,1,1000000000,1000000,100000,4,1,1000000];

nonlcon = [];


Min_error = 10^20;



for i = 1:size(neurons,2)
    
    no_of_neuronsQ = neurons(i);
    no_of_neuronsM = neurons(i);
    rhoQ = 1;
    rhoM = 1;
    
    [~,ESN_hyper_Quarter,ESN_hyper_Month] = Initialize_Models('Model2',N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ,rhoM,no_of_neuronsM);
    
    fun3 = @(theta3) Cross_validation2A(theta3, Training_data, ESN_hyper_Quarter,ESN_hyper_Month);
    % theta3 = [gammaQ, rhoQ, alphaQ, lambda, biasQ, gammaM,rhoM,alphaM,biasM] optimizing 4 params
    theta3_initial =[1.2,1.1,0.18,.36,2,1.2,1.1,0.18,2];
    

    
    %options = optimset('Display','iter','PlotFcns',@optimplotfval,'MaxFunEvals',1000);
    options = optimset('MaxFunEvals',10000);
    [theta_star, fval] = fminsearch(fun3,theta3_initial,options);
    %'MaxIter',500
    %[theta_star, fval] = fminsearch(fun3,theta3_initial);

    %[theta_star, fval] = fmincon(fun3,theta3_initial,A,b,Aeq,beq,lb,ub,nonlcon,options);
    %[theta_star, fval] = fmincon(fun3,theta3_initial,A,b,Aeq,beq,lb,ub,nonlcon);

    

    %neurons
    %tab1 = array2table([theta_star;x],"RowNames",{'unbounded','bounded rho'},"VariableNames",{'gamma', 'rho', 'alpha', 'lambda', 'bias'})
    theta_archive(i,:) = theta_star;
    fval_archive(i,:) = fval;
    

    if fval < Min_error
        Min_error = fval; 
        
        ESN_temp_Quarter = ESN_hyper_Quarter;
        ESN_temp_Monthly = ESN_hyper_Month;
        theta_temp = theta_star
    end

    
end

[~,ESN_Quarterly_2A,ESN_Monthly_2A,~] = Scaling('Model2',ESN_temp_Quarter,theta_temp,ESN_temp_Monthly);

                                                                                            % theta3 = [gammaQ, rhoQ, alphaQ, lambda, biasQ, gammaM,rhoM,alphaM,biasM]
tab1 = array2table([neurons',fval_archive,theta_archive],"VariableNames",{'neurons','validation error','gammaQ', 'rhoQ', 'alphaQ', 'lambda', 'biasQ','gammaM', 'rhoM', 'alphaM', 'biasM'})

%{
for ii_Q = 1:size(neurons,2)
    
    no_of_neuronsQ = neurons(ii_Q)

    for ii_M = 1:size(neurons,2)

        no_of_neuronsM = neurons(ii_M)

        for i_Q = 1:size(rho,2)
            
            rhoQ = rho(i_Q);

            for i_M = 1:size(rho,2)

                rhoM = rho(i_M); 
                
                [~,ESN_hyper_Quarter,ESN_hyper_Month] = Initialize_Models('Model2',N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ,rhoM,no_of_neuronsM);
        
                for j_Q = 1:size(alpha,2)
                    ESN_hyper_Quarter.alpha = alpha(j_Q);

                    for j_M = 1:size(alpha,2)
                        ESN_hyper_Month.alpha = alpha(j_M);

                        for k = 1:size(lambda,2)
                            ESN_hyper_Quarter.regularization = lambda(k);
                            ESN_hyper_Month.regularization = lambda(k);

                            iterations_remaining = total_loops_to_run_Model2A - counter
                            counter = counter + 1;

                            [error_2A,error_2B] = Cross_validation2(Training_data,ESN_hyper_Quarter,ESN_hyper_Month);


                            if (error_2A < Min_error_2A)
                                Min_error_2A = error_2A;
                                ESN_Quarterly_2A = ESN_hyper_Quarter
                                ESN_Monthly_2A = ESN_hyper_Month
                            end

                            if (error_2B < Min_error_2B)
                                Min_error_2B = error_2B;
                                ESN_Quarterly_2B = ESN_hyper_Quarter
                                ESN_Monthly_2B = ESN_hyper_Month
                            end


                        end
                    end
                end
            end
        end
    end
%}
end

                            






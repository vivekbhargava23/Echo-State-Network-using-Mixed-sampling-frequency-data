function [ESN_Model3] = Hyperparameter_selection3(Training_data,N_Monthly,N_Quarterly,neurons)
%CROSS_VALIDATION_MODELS Summary of this function goes here
%   Detailed explanation goes here

%neurons = [10:10:100]

rng('default')
neurons = [10:5:30,50];


A = [];
b = [];
Aeq = [];
beq = [];
% theta3 = [gamma, rho, alpha, lambda, bias] 
lb = [-10000,0.5,0.001,0,-100000];
ub = [100000,2,1,1000000000,10000];
nonlcon = [];


Min_error = 10^20;


for i = 1:size(neurons,2)
    
    no_of_neuronsQ = neurons(i);
    rhoQ = 1;
    [~,~,~,ESN_hyper] = Initialize_Models('Model3',N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ);
    
    fun3 = @(theta3) Cross_validation3(theta3, Training_data, ESN_hyper);
    % theta3 = [gamma, rho, alpha, lambda, bias] optimizing 4 params
    theta3_initial =[1.2,1.1,0.18,.36,2];
    

    
    %options = optimset('Display','iter','PlotFcns',@optimplotfval);
    options = optimset('MaxFunEvals',10000);
    %[theta_star, fval] = fminsearch(fun3,theta3_initial,options);
    %[theta_star, fval] = fminsearch(fun3,theta3_initial);

    [theta_star, fval] = fmincon(fun3,theta3_initial,A,b,Aeq,beq,lb,ub,nonlcon,options);
    %[theta_star, fval] = fmincon(fun3,theta3_initial,A,b,Aeq,beq,lb,ub,nonlcon);

    

    %neurons
    %tab1 = array2table([theta_star;x],"RowNames",{'unbounded','bounded rho'},"VariableNames",{'gamma', 'rho', 'alpha', 'lambda', 'bias'})
    theta_archive(i,:) = theta_star;
    fval_archive(i,:) = fval;


    if fval < Min_error
        Min_error = fval; 
        
        ESN_temp = ESN_hyper;
        theta_temp = theta_star
    end

end

[~,~,~,ESN_Model3] = Scaling('Model3',ESN_temp, theta_temp);

tab1 = array2table([neurons',fval_archive,theta_archive],"VariableNames",{'neurons','validation error','gamma', 'rho', 'alpha', 'lambda', 'bias'})

    

    %{
    for i = 1:size(rho,2)
        
        %rhoQ = rho(i);
        %[~,~,~,ESN_hyper] = Initialize_Models('Model3',N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ);
        
        for j = 1:size(alpha,2)
            ESN_hyper.alpha = alpha(j);
    
            for k = 1:size(lambda,2)
                ESN_hyper.regularization = lambda(k);
                
                iterations_remaining_Model1 = total_loops_to_run_Model1 - counter
                counter = counter + 1;
                
                error = Cross_validation3(Training_data,ESN_hyper);

    
                if (error < Min_error)
                    Min_error = error;
                    ESN = ESN_hyper;
                end
    
    
            end
        end
        
    end
    %}






end


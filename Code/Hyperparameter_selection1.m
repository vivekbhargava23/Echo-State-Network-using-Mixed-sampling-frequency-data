function [ESN_Model1] = Hyperparameter_selection1(Training_data,N_Monthly,N_Quarterly,neurons)
%CROSS_VALIDATION_MODELS Summary of this function goes here
%   Detailed explanation goes here
rng('default')
neurons = [15:5:30,50,100];

A = [];
b = [];
Aeq = [];
beq = [];
% theta3 = [gamma, rho, alpha, lambda, bias]
lb = [-1000,0.1,0.001,0,-100000];
ub = [100000,2,1,1000000000,10000];
nonlcon = [];

Min_error = 10^20;


for i = 1:size(neurons,2)
    no_of_neuronsQ = neurons(i);
    rhoQ = 1;
    ESN_hyper = Initialize_Models('Model1',N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ);

    fun3 = @(theta3) Cross_validation1(theta3, Training_data, ESN_hyper);
    % theta3 = [gamma, rho, alpha, lambda, bias] optimizing 4 params
    theta3_initial =[1.2,1.1,0.18,.36,2];
    
    %options = optimset('PlotFcns',@optimplotfval,'MaxFunEvals',1000000);
    %options = optimset('Display','iter','PlotFcns',@optimplotfval);
    %[theta_star, fval] = fminsearch(fun3,theta3_initial,options);
    [theta_star, fval] = fminsearch(fun3,theta3_initial);

    %x = fmincon(fun3,theta3_initial,A,b,Aeq,beq,lb,ub,nonlcon,options);
    %[theta_star, fval] = fmincon(fun3,theta3_initial,A,b,Aeq,beq,lb,ub,nonlcon);

    theta_archive(i,:) = theta_star;
    fval_archive(i,:) = fval;


    if fval < Min_error
        Min_error = fval; 
        
        ESN_temp = ESN_hyper;
        theta_temp = theta_star
    end

end

ESN_Model1 = Scaling('Model1',ESN_temp, theta_temp);

tab1 = array2table([neurons',fval_archive,theta_archive],"VariableNames",{'neurons','validation error','gamma', 'rho', 'alpha', 'lambda', 'bias'})


    %{
    
    no_of_neuronsQ = neurons(ii);

    for i = 1:size(rho,2)
        i;
        rhoQ = rho(i);
        ESN_hyper = Initialize_Models('Model1',N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ);
        
        for j = 1:size(alpha,2)
            ESN_hyper.alpha = alpha(j);
    
            for k = 1:size(lambda,2)
                ESN_hyper.regularization = lambda(k);
                
                iterations_remaining_Model1 = total_loops_to_run_Model1 - counter
                counter = counter + 1;
                
                error = Cross_validation1(Training_data,ESN_hyper);

    
                if (error < Min_error)
                    Min_error = error;
                    ESN = ESN_hyper;
                end
    
    
            end
        end
    end

    %}
end






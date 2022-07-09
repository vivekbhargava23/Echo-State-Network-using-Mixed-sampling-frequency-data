function [ESN_Model1,ESN_Model2_Quarter,ESN_Model2_Month,ESN_Model3] = Scaling(model,ESN,theta,ESN_M)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here

% theta = [gamma, rho, alpha, lambda, bias]

ESN_Model1 = [];
ESN_Model2_Quarter = [];
ESN_Model2_Month = [];
ESN_Model3 = [];


if model =="Model1"

    % Scaling Model1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gamma = theta(1);
    rho = theta(2);
    alpha = theta(3);
    lambda = theta(4);
    bias = theta(5);
    
    % Using bias
    ESN.bias = bias;

    % Scaling Input mask
    %ESN.C_in = gamma * ESN.C_in;
    ESN.C_in(:,2:end) = gamma * ESN.C_in(:,2:end);
    ESN.C_in(:,1) = bias * ESN.C_in(:,1);
    
    
    if ESN.N_reservoirs>1
        ESN.C_inter_layer(:,2:end) = gamma * ESN.C_inter_layer(:,2:end);
        ESN.C_inter_layer(:,1) = bias * ESN.C_inter_layer(:,1);
    end
    
    % Scaling reservoir
    ESN.A_layer = rho * ESN.A_layer;
    ESN.alpha = alpha;
    ESN.regularization = lambda;

    ESN_Model1 = ESN;


elseif model=="Model2"

    %Initializing Model2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % theta3 = [gammaQ, rhoQ, alphaQ, lambda, biasQ, gammaM,rhoM,alphaM,biasM]
    gammaQ = theta(1);
    rhoQ = theta(2);
    alphaQ = theta(3);
    lambda = theta(4);
    biasQ = theta(5);

    gammaM = theta(6);
    rhoM = theta(7);
    alphaM = theta(8);
    biasM = theta(9);

    % Quarterly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Scaling Input mask
    %ESN.C_in = gamma * ESN.C_in;
    ESN.C_in(:,2:end) = gammaQ * ESN.C_in(:,2:end);
    ESN.C_in(:,1) = biasQ * ESN.C_in(:,1);

    if ESN.N_reservoirs>1
        ESN.C_inter_layer(:,2:end) = gammaQ * ESN.C_inter_layer(:,2:end);
        ESN.C_inter_layer(:,1) = biasQ * ESN.C_inter_layer(:,1);
    end

    % Scaling reservoir
    ESN.A_layer = rhoQ * ESN.A_layer;
    ESN.alpha = alphaQ;
    ESN.regularization = lambda;
    
    ESN_Model2_Quarter = ESN;

    % Monthly
    %%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Scaling Input mask
    %ESN.C_in = gamma * ESN.C_in;
    ESN_M.C_in(:,2:end) = gammaM * ESN_M.C_in(:,2:end);
    ESN_M.C_in(:,1) = biasM * ESN_M.C_in(:,1);

    if ESN_M.N_reservoirs>1
        ESN_M.C_inter_layer(:,2:end) = gammaM * ESN_M.C_inter_layer(:,2:end);
        ESN_M.C_inter_layer(:,1) = biasM * ESN_M.C_inter_layer(:,1);
    end

    % Scaling reservoir
    ESN_M.A_layer = rhoM * ESN_M.A_layer;
    ESN_M.alpha = alphaM;
    
    ESN_Model2_Month = ESN_M;


elseif model =="Model3"
    % disp('Initializing Model3')

    %Initializing Model3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    gamma = theta(1);
    rho = theta(2);
    alpha = theta(3);
    lambda = theta(4);
    bias = theta(5);
    
    % Using bias
    ESN.bias = bias;
    
    % Scaling Input mask
    %ESN.C_in = gamma * ESN.C_in;
    ESN.C_in(:,2:end) = gamma * ESN.C_in(:,2:end);
    ESN.C_in(:,1) = bias * ESN.C_in(:,1);
    
    if ESN.N_reservoirs>1
        ESN.C_inter_layer(:,2:end) = gamma * ESN.C_inter_layer(:,2:end);
        ESN.C_inter_layer(:,1) = bias * ESN.C_inter_layer(:,1);
    end
    
    % Scaling reservoir
    ESN.A_layer = rho * ESN.A_layer;
    ESN.alpha = alpha;
    ESN.regularization = lambda;
    
    ESN_Model3 = ESN;

else
    disp('Error: Wrong model name input')

end


end








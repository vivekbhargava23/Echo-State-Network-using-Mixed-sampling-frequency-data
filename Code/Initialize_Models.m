function [ESN_Model1,ESN_Model2_Quarter,ESN_Model2_Month,ESN_Model3,UMIDAS] = Initialize_Models(model,N_Monthly,N_Quarterly,rhoQ,no_of_neuronsQ,rhoM,no_of_neuronsM)
%INITIALIZE_MODELS Summary of this function goes here
%   Detailed explanation goes here
% model = 'Model1'


burn = 2;
N_reservoirs = 1;
%neurons = no_of_neurons;
ESN_Model1 = [];
ESN_Model2_Quarter = [];
ESN_Model2_Month = [];
ESN_Model3 = [];
UMIDAS = [];

if model =="Model1"

    %Initializing Model1
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ESN_Model1.Nx = no_of_neuronsQ;
    ESN_Model1.Nz = N_Quarterly + 3*N_Monthly;
    ESN_Model1.N_reservoirs = N_reservoirs;
    ESN_Model1.spec_radius = rhoQ;
    ESN_Model1.burn = burn;
    
    % Assigning random weight matrices for input to reservoir -> Matrix C_in
    ESN_Model1.C_in = 2*rand(ESN_Model1.Nx,1+ESN_Model1.Nz)-1;
    ESN_Model1.C_in = ESN_Model1.C_in/norm(ESN_Model1.C_in);
    
    % Assigning weights between reservoirs -> Matrix C_layer
    for i = 1:ESN_Model1.N_reservoirs-1
        ESN_Model1.C_inter_layer(:,:,i) = 2.*rand(ESN_Model1.Nx,1+ESN_Model1.Nx)-1; 
        %ESN.C_inter_layer(:,:,i) = rand(ESN.Nx,1+ESN.Nx)-0.5;
        ESN_Model1.C_inter_layer(:,:,i) = ESN_Model1.C_inter_layer(:,:,i)/norm(ESN_Model1.C_inter_layer(:,:,i));
    end

    % Assigning weights to neurons within a reservoir -> Matrix A_layer
    for i = 1:ESN_Model1.N_reservoirs
        %ESN_Model1.A_layer(:,:,i) = 2*rand(ESN_Model1.Nx,ESN_Model1.Nx)-1;
        ESN_Model1.A_layer(:,:,i) = full(sprandn(ESN_Model1.Nx,ESN_Model1.Nx,0.1));
    
        % Normalizing wrt the spectral radius 
        eigen_values = eig(ESN_Model1.A_layer(:,:,i));
        max_abs_eig_value = max(abs(eigen_values));
        ESN_Model1.A_layer(:,:,i) = ESN_Model1.spec_radius * ESN_Model1.A_layer(:,:,i) / max_abs_eig_value;
    end

 
elseif model=="Model2"

    %Initializing Model2
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Initiallizing ESN for Quarterly Frequency
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ESN_Model2_Quarter.Nx = no_of_neuronsQ;
    ESN_Model2_Quarter.Nz = N_Quarterly;
    ESN_Model2_Quarter.N_reservoirs = N_reservoirs;
    ESN_Model2_Quarter.spec_radius = rhoQ;
    ESN_Model2_Quarter.burn = burn;
    ESN_Model2_Quarter.N_Quarterly = N_Quarterly;
    ESN_Model2_Quarter.N_Monthly = N_Monthly;
    
    
    % Assigning random weight matrices for input to reservoir -> Matrix C_in
    ESN_Model2_Quarter.C_in = 2*rand(ESN_Model2_Quarter.Nx,1+ESN_Model2_Quarter.Nz)-1;
    ESN_Model2_Quarter.C_in = ESN_Model2_Quarter.C_in/norm(ESN_Model2_Quarter.C_in);

    % Assigning weights between reservoirs -> Matrix C_layer
    for i = 1:ESN_Model2_Quarter.N_reservoirs-1
        ESN_Model2_Quarter.C_inter_layer(:,:,i) = 2.*rand(ESN_Model2_Quarter.Nx,1+ESN_Model2_Quarter.Nx)-1; 
        %ESN.C_inter_layer(:,:,i) = rand(ESN.Nx,1+ESN.Nx)-0.5;
        ESN_Model2_Quarter.C_inter_layer(:,:,i) = ESN_Model2_Quarter.C_inter_layer(:,:,i)/norm(ESN_Model2_Quarter.C_inter_layer(:,:,i));
    end

    % Assigning weights to neurons within a reservoir -> Matrix A_layer
    for i = 1:ESN_Model2_Quarter.N_reservoirs
        %ESN_Model2_Quarter.A_layer(:,:,i) = 2*rand(ESN_Model2_Quarter.Nx,ESN_Model2_Quarter.Nx)-1;
        ESN_Model2_Quarter.A_layer(:,:,i) = full(sprandn(ESN_Model2_Quarter.Nx,ESN_Model2_Quarter.Nx,0.1));
        %ESN.A_layer(:,:,i) = rand(ESN.Nx,ESN.Nx)-0.5;
    
        % Normalizing wrt the spectral radius
        eigen_values = eig(ESN_Model2_Quarter.A_layer(:,:,i));
        max_abs_eig_value = max(abs(eigen_values));
        ESN_Model2_Quarter.A_layer(:,:,i) = ESN_Model2_Quarter.spec_radius * ESN_Model2_Quarter.A_layer(:,:,i) / max_abs_eig_value;
    end



    % Initiallizing ESN for Monthly Frequency
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    ESN_Model2_Month.Nx = no_of_neuronsM;
    ESN_Model2_Month.Nz = N_Monthly;
    ESN_Model2_Month.N_reservoirs = N_reservoirs;
    ESN_Model2_Month.spec_radius = rhoM;
    ESN_Model2_Month.N_Quarterly = N_Quarterly;
    ESN_Model2_Month.N_Monthly = N_Monthly;
    
    
    % Assigning random weight matrices for input to reservoir -> Matrix C_in
    ESN_Model2_Month.C_in = 2*rand(ESN_Model2_Month.Nx,1+ESN_Model2_Month.Nz)-1;
    ESN_Model2_Month.C_in = ESN_Model2_Month.C_in/norm(ESN_Model2_Month.C_in);

    % Assigning weights between reservoirs -> Matrix C_layer
    for i = 1:ESN_Model2_Month.N_reservoirs-1
        ESN_Model2_Month.C_inter_layer(:,:,i) = 2.*rand(ESN_Model2_Month.Nx,1+ESN_Model2_Month.Nx)-1; 
        %ESN.C_inter_layer(:,:,i) = rand(ESN.Nx,1+ESN.Nx)-0.5;
        ESN_Model2_Month.C_inter_layer(:,:,i) = ESN_Model2_Month.C_inter_layer(:,:,i)/norm(ESN_Model2_Month.C_inter_layer(:,:,i));
    end

    % Assigning weights to neurons within a reservoir -> Matrix A_layer
    for i = 1:ESN_Model2_Month.N_reservoirs
        %ESN_Model2_Month.A_layer(:,:,i) = 2*rand(ESN_Model2_Month.Nx,ESN_Model2_Month.Nx)-1;
        ESN_Model2_Month.A_layer(:,:,i) = full(sprandn(ESN_Model2_Month.Nx,ESN_Model2_Month.Nx,0.1));
        %ESN.A_layer(:,:,i) = rand(ESN.Nx,ESN.Nx)-0.5;
    
        % Normalizing wrt the spectral radius
        eigen_values = eig(ESN_Model2_Month.A_layer(:,:,i));
        max_abs_eig_value = max(abs(eigen_values));
        ESN_Model2_Month.A_layer(:,:,i) = ESN_Model2_Month.spec_radius * ESN_Model2_Month.A_layer(:,:,i) / max_abs_eig_value;
    end



elseif model =="Model3"
    % disp('Initializing Model3')

    %Initializing Model3
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    ESN_Model3.Nx = no_of_neuronsQ;
    ESN_Model3.Nz = N_Quarterly + N_Monthly;
    ESN_Model3.N_reservoirs = N_reservoirs;
    ESN_Model3.spec_radius = rhoQ;
    ESN_Model3.burn = burn;
    ESN_Model3.N_Quarterly = N_Quarterly;
    ESN_Model3.N_Monthly = N_Monthly;
    
    % Assigning random weight matrices for input to reservoir -> Matrix C_in
    ESN_Model3.C_in = 2*rand(ESN_Model3.Nx,1+ESN_Model3.Nz)-1;
    ESN_Model3.C_in = ESN_Model3.C_in/norm(ESN_Model3.C_in); %%%%%%%%%
    %check this
    
    % Assigning weights between reservoirs -> Matrix C_layer
    for i = 1:ESN_Model3.N_reservoirs-1
        ESN_Model3.C_inter_layer(:,:,i) = 2.*rand(ESN_Model3.Nx,1+ESN_Model3.Nx)-1; 
        %ESN.C_inter_layer(:,:,i) = rand(ESN.Nx,1+ESN.Nx)-0.5;
        ESN_Model3.C_inter_layer(:,:,i) = ESN_Model3.C_inter_layer(:,:,i)/norm(ESN_Model3.C_inter_layer(:,:,i));
    end

    % Assigning weights to neurons within a reservoir -> Matrix A_layer
    for i = 1:ESN_Model3.N_reservoirs
        %ESN_Model3.A_layer(:,:,i) = 2*rand(ESN_Model3.Nx,ESN_Model3.Nx)-1;
        ESN_Model3.A_layer(:,:,i) = full(sprandn(ESN_Model3.Nx,ESN_Model3.Nx,0.1));
        %ESN.A_layer(:,:,i) = rand(ESN.Nx,ESN.Nx)-0.5;
    
        % Normalizing wrt the spectral radius
        eigen_values = eig(ESN_Model3.A_layer(:,:,i));
        max_abs_eig_value = max(abs(eigen_values));
        ESN_Model3.A_layer(:,:,i) = ESN_Model3.spec_radius * ESN_Model3.A_layer(:,:,i) / max_abs_eig_value;
    end

    

else
    disp('Error: Wrong model name input')

end


end


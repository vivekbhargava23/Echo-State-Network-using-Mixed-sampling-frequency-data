function Concatenated_X = Concatenate_layers(ESN,X)
%CONCATENATE_LAYERS Summary of this function goes here
% X: Nx x T x N_reservoirs
Concatenated_X = [];


for i = 1:ESN.N_reservoirs
    Concatenated_X = [Concatenated_X;X(:,:,i)];
end


end


function [a2] = insert_vector(a,value,position)

    a2 = [a , value ];
    ind_a2 = [ 1:numel(a) , position+0.5 ];
    [~,ind_a2] = sort(ind_a2);
    a2 = a2(ind_a2);
    
end



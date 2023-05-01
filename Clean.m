% This function cleans the corrupted signal and generates fresh signal
function fresh = Clean(Received)    
    
    bit_length=length(Received);         
    y=[];
    for i=1:bit_length
        if Received(i)>=0
            y(i) = 1;    
        else
            y(i)= -1;    
        end
    end
    
    fresh=y;
end
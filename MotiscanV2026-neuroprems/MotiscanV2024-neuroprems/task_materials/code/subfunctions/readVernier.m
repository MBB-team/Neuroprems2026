function [grip,Tgrip] = readVernier(Handle,offset)

    if nargin<2
        offset = 0;
    end

    try
        grip = Handle.read();
        grip = grip - offset;
    catch
        grip = NaN;
    end
    Tgrip = GetSecs;
end
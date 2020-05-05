function [ out ] = kdstruct_to_2d( in_fiber,in_face )
%kdstruct_to_2d Convert knockdown struct to 2d histogram struct

fields = fieldnames(in_fiber);

for f=1:2:length(fields)
    out.(fields{f}).D  = in_fiber.(fields{f});
    out.(fields{f}).rD = in_fiber.(fields{f+1});
    out.(fields{f}).fD  = in_face.(fields{f});
    out.(fields{f}).frD = in_face.(fields{f+1});
    out.(fields{f}).pixelSize = 1;
end

end


function [ out ] = kdstruct_to_2d( in_fiber,in_face )
%kdstruct_to_2d Convert knockdown struct to 2d histogram struct
%     laminNPCAnalysis - Analyze Lamin Fibers and Nuclear Pore Complexes
%     Copyright (C) 2020 Mark Kittisopikul, Northwestern University
% 
%     This program is free software: you can redistribute it and/or modify
%     it under the terms of the GNU General Public License as published by
%     the Free Software Foundation, either version 3 of the License, or
%     (at your option) any later version.
% 
%     This program is distributed in the hope that it will be useful,
%     but WITHOUT ANY WARRANTY; without even the implied warranty of
%     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
%     GNU General Public License for more details.
% 
%     You should have received a copy of the GNU General Public License
%     along with this program.  If not, see <https://www.gnu.org/licenses/>.
fields = fieldnames(in_fiber);

for f=1:2:length(fields)
    out.(fields{f}).D  = in_fiber.(fields{f});
    out.(fields{f}).rD = in_fiber.(fields{f+1});
    out.(fields{f}).fD  = in_face.(fields{f});
    out.(fields{f}).frD = in_face.(fields{f+1});
    out.(fields{f}).pixelSize = 1;
end

end


function mask = maskFromSteerable(steerable)
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
    if(~isstruct(steerable) && ~isa(steerable,'OrientationSpaceResponse'))
        % if not a steerable output structure, assume an image was given
        % and run the steerable detector
        I = steerable;
        clear steerable;
        [steerable.res, steerable.theta, steerable.nms] = steerableDetector(double(I),4,5);
    end
%     thresh = thresholdRosin(steerable.res(:));
%     threshOtsu = thresholdOtsu(steerable.nms( steerable.nms ~= 0));
%     threshNms = thresholdRosin(steerable.nms( steerable.nms ~= 0));
    justNms = steerable.nms( steerable.nms ~= 0);
%    mask = steerable.res > thresh;
%    mask = mask | steerable.nms > thresh/2;
    mask = hysteresisThreshold(steerable.res,prctile(justNms,95),prctile(justNms,70));
    mask = imclose(mask,strel('disk',10));
    mask = imfill(mask,'holes');
    mask = imopen(mask,strel('disk',50));
    cc = bwconncomp(mask);
    rp = regionprops(cc,'Area');
    [maxArea,maxIdx] = max([rp.Area]);
    mask(:) = 0;
    % if the largest area detected is less than 70% of total area
    if(maxArea < 0.7*numel(steerable.res))
        mask(cc.PixelIdxList{maxIdx}) = 1;
    end
end

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
nuc = locmax2d(I_npc,ones(5));
thresh = thresholdOtsu(nuc(nuc > 0));
nucThreshed = nuc > thresh / 2;
[r,c] = find(nucThreshed);
s = r > 10 & r < 1024-10 & c > 10 & c < 1024-10;
r = r(s);
c = c(s);
maskch = regionprops(mask,'ConvexHull');
s =  inpolygon(c,r,maskch.ConvexHull(:,1),maskch.ConvexHull(:,2));
r = r(s);
c = c(s);
[X,Y] = ndgrid(-10:10,-10:10);
% [Xch,Ych] = ndgrid(chebpts(5,-1:1),chebpts(5,-1:1));
mv = zeros(length(r),1);
mx = zeros(length(r),2);
parfor ii=1:length(r)
    G = griddedInterpolant(X,Y,double(I_npc(r(ii)+(-10:10),c(ii)+(-10:10))),'spline');
    [mx(ii,:),mv(ii)] = fminsearch(@(x) -G(x(1),x(2)),[0 0]);
%     ch = chebfun2(G(Xch,Ych),[-1 1],[-1 1]);
%     [mv(ii),mx{ii}] = max2(ch);
%     disp(ii);
end
mx = mx+[r c];

tri = delaunayTriangulation(mx(-mv > 1000,2),mx(-mv > 1000,1));
triX = tri.Points(:,1);
triY = tri.Points(:,2);

figure; imshow(I_npc,[]);

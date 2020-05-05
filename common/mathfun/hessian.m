function varargout=hessian(data)
% HESSIAN compute the hessian of data
%
% SYNOPSIS  [FXX, FXY,FXZ,FYX,FYY,FYZ,FZX,FZY,FZZ]=curvature3D(img,pnt)
%
% INPUT data   : 2D or 3D data
% OUTPUT  FXX...FZZ   : hessian entries for all positions

% c: 7/12/01	dT
delta=1;
if (ndims(data)==3)
    [FX,FY,FZ] = gradient(data,delta);
    [FXX,FXY,FXZ] = gradient(FX,delta);
    [FYX,FYY,FYZ] = gradient(FY,delta);
    [FZX,FZY,FZZ] = gradient(FZ,delta);
    varargout(1:9)={FXX,FXY,FXZ,FYX,FYY,FYZ,FZX,FZY,FZZ};
elseif(ndims(data)==3)
    [FX,FY] = gradient(data,delta);
    [FXX,FXY] = gradient(FX,delta);
    [FYX,FYY] = gradient(FY,delta);
    varargout(1:4)={FXX,FXY,FYX,FYY};
end;

function out = getNthOutput(funHan,iOut,varargin)
%GETNTHOUTPUT returns one of the outputs from a multi-output funciton 
%
% out = getNthOutput(funHan,iOut,varargin)
%
%       funHan - handle to function to evaluyate
%       iOut - the index of the output
%       varargin - any inputs to be passed to the function.
%
% Hunter Elliott 
% 9/2013

[allOut{1:iOut}] = funHan(varargin{:});

out = allOut{iOut};


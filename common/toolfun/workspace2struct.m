function [ S, variables, values ] = workspace2struct(ws,varargin)
%workspace2struct packs variables in the indicated workspace into a
%struct for later use
%
% INPUT
% ws (optional) is a char string that is either
% 1) 'caller' (default)
% 2) 'base'
%
% additional arguments are based on to who
%
% OUTPUT
% S is a struct with fieldnames corresponding the variables in ws
%
% USAGE:
% S = evalin('caller','workspace2struct');
% base = workspace2struct('base');
%
% See also evalin, who

if(nargin < 1)
    ws = 'caller';
end

% get list of variable names
variables = evalin(ws,['who(''' strjoin(varargin,''',''') ''');']);
varList = strjoin(variables,',');
values = cell(length(variables),1);

% obtain variable values
[values{:}] = evalin(ws,[ 'deal(' varList ')']);

% pack into a struct
S = cell2struct(values,variables);


end


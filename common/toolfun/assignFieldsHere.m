function assignFieldsHere(S,varargin)
%assignFieldsHere assign fields from S to the current workspace
%
% INPUT
% S - struct containing fields to assign in the current workspace
% fieldnames - list of strings naming fields to assign
%
% OUTPUT
% None (Fields are assigned in the current workspace)
%
% EXAMPLE
% S.a = 1;
% S.b = 2;
% assignFieldsHere(S);
% S.a = -1;
% assignFieldsHere(S,'a');

% Mark Kittisopikul, December 2014
    if(nargin < 2)
        fields = fieldnames(S);
    else
        fields = varargin;
        assert( all(isfield(S,fields)), ...
            'Field names must be fields of the structure');
    end

    for i=1:length(fields)
        assignin('caller',fields{i},S.(fields{i}));
    end
end


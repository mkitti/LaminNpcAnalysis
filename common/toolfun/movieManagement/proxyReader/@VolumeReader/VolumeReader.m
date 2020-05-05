classdef VolumeReader < CellReader
% VolumeReader Reads XYZ matrices as if arranged in a cell array
%

    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    methods
        function obj = VolumeReader(varargin)
            obj = obj@CellReader(varargin{:});
        end
        function s = getSize(obj)
            s = [obj.reader.getSizeC
                 obj.reader.getSizeT]';
        end
        function matrix = toMatrix(obj)
            matrix = reshape(obj.to3D,[obj.getSizeY obj.getSizeX obj.getSizeZ obj.size]);
        end
        function out = toCell(obj)
            S.type = '{}';
            S.subs = {':',':'};
            S = obj.expandSubs(S);
            out = obj.loadCell(S.subs{:});
        end
    end
    methods ( Access = protected )
        function images = loadCell(obj,varargin)
            varargin(nargin :3) = {NaN};
            [cv,tv,zv] = deal(varargin{:});
            ndim = nargin - 1;
            images = cell([length(cv) length(tv) 1]);
            for c = 1:length(cv)
                for t = 1:length(tv)
                     sub = { cv(c) tv(t) zv};
                     images{c,t} = obj.loadStack(sub{1:ndim});
                 end
             end
        end
        function R = getSubIndexReader(obj,S)
            S.subs = obj.getLinSub(S.subs{:});
            S.subs{3} = 1: obj.getSizeZ;
            R = obj.getSubIndexReader@CellReader(S);
        end
    end
end

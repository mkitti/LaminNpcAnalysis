classdef CellReader < LinearReader
    %CellReader Reader proxy class that presents a cell like interface
    %
    % The goal of this implementation is to match Matlab's built-in cell
    % class in terms of interface.
    % NB: "cell" refers to a data structure, not a biological structure
    %
    % CellReader implements the Reader interface and supports all the
    % standard reader interface functions but also allows once to use
    % Matlab style indexing using () and {}.
    %
    % The smooth braces, "()", return a single cell array with the
    % requested dimensions.
    %
    % The curly braces, "{}", returns image planes as 2D matrices as
    % determined by the parent reader given in the construtor. It is
    % possible for this sort of indexing to return multiple values as a
    % commas separated list.
    %
    % CellReader supports the use of Matlab indexing facilities such as
    % 1) ":", which expands to the entire range of the dimension
    % 2) "end", which indicates the maximum index of the dimension
    % 3) Linear indexing is also supporting where fewer dimensions can be
    % indexed and the real dimensions are collapsed.
    %
    % CellReader assumes that the parent loadImage function uses the c,t,z
    % order and depends on the parent loadImage for all underlying
    % function.
    %
    % CellReader is meant to replace the following sort code blocks:
    %
    %     nc = reader.getSizeC;
    %     nt = reader.getSizeT;
    %     nz = reader.getSizeZ;
    %     cellData = cell(nc,nt,nz);
    %     for c=1:nc
    %         for t=1:nt
    %             for z=1:nz
    %                 cellData{c,t,z} = reader.loadImage(c,t,z);
    %             end
    %         end
    %     end  
    %     % obtain a zStack as a cell array
    %     zStack = cellData(3,1,:);
    %     timeSeries = cellData(1,:,3);
    %     channel = cellData();
    %     % etc...
    %     % rather an instance of CellReader should act as a drop in replacement:
    %     cellData = CellReader(reader);
    %                 
    % Initialization requires just the parent Reader to which to provide
    % the cell interface:
    % cellreader = CellReader(parentReader);
    %
    % The following cell behaviors are supported
    %
    % Indexing:
    % singleton cell array at c=4, t=1, z=3
    % singleton = cellreader(4,1,3);
    % obtain a single image plane as a matrix
    % equivalent to reader.loadImage(4,1,3);
    % I = cellreader{4,1,3};
    %
    % Any behaviors that do not match the celldata is a bug. Please report.
    % 
    % Additional supported behaviors beyond a standard cell:
    %
    % 1) Named dimension subindexing using .c() , .t(), or .z()
    % % Subindex to channel 2
    % chanTwoReader = cellreader.c(2)
    % % Get z stack at c=4, t=2
    % zStack = cellreader.c(4).t(2)
    %
    % 2) Convert to a matrix with dimensions YXCTZ
    % matrix = cellreader(1:2,1,2).toMatrix
    %
    % 3) Convert to a 3D matrix with dimensions YXN, N = CxTxZ
    % colorStack = cellreader(:,5,3).to3D
    %
    % 4) Convert to a standard cell
    % realCell = cellreader.toCell
    
    % Mark Kittisopikul
    % mark.kittisopikul@utsouthwestern.edu
    % Lab of Khuloud Jaqaman
    % UT Southwestern
    
    properties
    end
    
    methods
        % Initialize
        function obj = CellReader(varargin)
            obj = obj@LinearReader(varargin{:});
        end

        
        function s = getDimensionOrder(obj)
            s = 'CTZ';
        end
             
        % override subscripting
        function varargout = subsref(obj,S)
            switch(S(1).type)
            case '.'
                % Allow for named indexing
                if(regexp(S(1).subs,'^[ctz]$'))
                    Q = obj.translateNamedIndex(S);
                    [varargout{1:nargout}] = obj.subsref(Q);
                else
                    % nargout bump from 0 to 1
                    % http://blogs.mathworks.com/loren/2009/04/14/convenient-nargout-behavior/
                    % Use the default behavior for '.'
                    [varargout{1:nargout}] = builtin('subsref',obj,S);
                end
            case '()'
                if(isempty(S(1).subs))
                    % if no index given, return this instance
                    varargout{1} = obj;
                else
                    [S,otherS] = expandSubs(obj,S);
                    % create a new class of the same type
                    varargout{1} = obj.getSubIndexReader(S);
                    % recurse
                    if(~isempty(otherS))
                        varargout{1} = varargout{1}.subsref(otherS);
                    end
                end
            case '{}'
                [S,otherS] = expandSubs(obj,S);
                % obtain a cell representation
                images = obj.loadCell(S.subs{:});
                % with curly braces, do a csv assignment
                [varargout{1:nargout}] = images{:};
                if(~isempty(otherS))
                    % if multiple values returned, no further subscripting!
                    assert(nargout==1,'CellReader{}: Bad cell reference operation.')
                    % recurse (only if one element is selected)
                    varargout{1} = builtin('subsref',varargout{1},otherS);
                end
            otherwise
                    % NOT USED , smooth braces subindex
                    % with smooth braces return the cell array
                    error('CellReader: Unimplementing indexing behavior');
            end
        end

        function obj = subsasgn(obj, S, B)
            switch(S.type)
            case '.'
                obj = builtin('subsasgn',obj,S,B);
            otherwise
                error('CellReader is read-only. Subscript assignment is not allowed');
            end
        end

        % The size follows the CTZ convention
        function varargout = size(obj,dim)
            s = obj.getSize;
            if(nargin > 1)
                s = s(dim);
            end
            % If multiple outputs are reuqested provide them
            if(nargout > 1)
                s = num2cell(s);
                [varargout{1:nargout}] = s{1:nargout};
            else
                varargout{1} = s;
            end
        end

        % When using {}, determine the number of elements to output
        function e = numel(obj,varargin)
            S.subs = varargin;
            % Expand colon operators
            S = expandSubs(obj,S);
            % Use the builtin operator
            e = builtin('numel',obj,S.subs{:});
        end

        % Expand the colon operator when indexing
        function [S,tail] = expandSubs(obj,S)
            % save tail for recursive indexing
            tail = S(2:end);
            S = S(1);

            % if the subindex is a cell array, use contents
            if(length(S.subs) == 1 && iscell(S.subs{1}))
                S.subs = S.subs{1};
            end

            % expand colon operators
            ndim = length(S.subs);
            for s = 1:ndim;
                if(S.subs{s} == ':')
                    S.subs{s} = 1:obj.end(s,ndim);
                end
            end
            % convert non-numeric items to indicies
            notNumeric = ~cellfun(@isnumeric,S.subs);
            S.subs(notNumeric) = cellfun(@(o) subsindex(o)+1, ...
                S.subs(notNumeric),'UniformOutput',false);
        end

        % Determine the number of elements for a certain dimension
        % Also, factor in linear indexing
        function ind = end(obj,idim,ndim)
            linSize = obj.getLinearSize(ndim);
            ind = linSize(idim);
        end

        % Convert to a cell
        function out = toCell(obj)
            S.type = '{}';
            S.subs = {':',':',':'};
            S = obj.expandSubs(S);

            %out = cell(obj.size());
            %[out{:}] = obj.subsref(S);
            out = obj.loadCell(S.subs{:});
        end

        function out = to3D(obj)
            cellBase = obj.toCell;
            out = cat(3,cellBase{:});
        end

        % Convert to a matrix
        function out = toMatrix(obj)
            out = reshape(obj.to3D,[obj.getSizeY obj.getSizeX obj.size]);
        end
        
        function c = num2cell(obj,varargin)
            % num2cell: Emulate the builtin num2cell by creating a cell array along a particular dimension
            c = cell(size(obj));
            % numel does not give the correct answer in this situation
            s = prod(size(obj));
            for i=1:s
                c{i} = obj.subsref(struct('type','()','subs',{{i}}));
            end
            if(nargin > 1)
                c = num2cell(c,varargin{:});
            end
        end

        % implement other cell functions by converting to cell
        function out = cell2mat(obj)
            realCell = obj.toCell;
            out = cell2mat(realCell);
        end

        function out = cell2table(obj,varargin)
            realCell = obj.toCell;
            out = cell2table(realCell,varargin{:});
        end
    
        function out = cell2dataset(obj,varargin)
            realCell = obj.toCell;
            out = cell2dataset(realCell,varargin{:});
        end

        % Only a partial implementation
        % Basically we need to do a full linearization
        % Used by squeeze
        function out = reshape(obj,varargin)
            S.type = '()';
            if(nargin == 2)
                S.subs = num2cell(varargin{1});
            else
                S.subs = varargin;
                e = cellfun(@isempty,S.subs);
                if(any(e))
                    S.subs{e} = numel(obj)/prod([S.subs{:}]);
                end
            end
            S.subs = cellfun(@(n) 1:n,S.subs,'UniformOutput',false);
            out = obj.subsref(S);
        end
        function varargout = cellfun(varargin)
         % CellReader.cellfun allows cellfun to be called directly to
         % access each image by converting the data to to a cell
         %
         % See also cellfun
            for i=1:length(varargin)
                if(isa(varargin{i},'CellReader'))
                    varargin{i} = varargin{i}.toCell;
                end
            end
            [varargout{1:nargout}] = cellfun(varargin{:});
        end
        function varargout = cellfun_lowmem(varargin)
            % CellReader.cellfun_lowmem emulates the built-in cellfun but
            % only loads a single 2D image plane at a time
            %
            % See also CellReader.cellfun, cellfun, arrayfun
            if(ischar(varargin{1}))
                warning('cellfun_lowmem cannot allow for the function to be a string. Using normal cellfun instead', 'CellReader:cellfun_lowmem::FuncIsString');
                [varargout{1:nargout}] = cellfun(varargin{:});
                return;
            end
            for i=1:length(varargin)
                if(isa(varargin{i},'CellReader'))
                    varargin{i} = num2cell(varargin{i});
                end
            end
            fxn = varargin{1};
            varargin{1} = @loadImages;
            [varargout{1:nargout}] = cellfun(varargin{:});
            function varargout = loadImages(varargin)
                for j=1:length(varargin)
                    if(isa(varargin{j},'CellReader'))
                        varargin{j} = varargin{j}.loadImage(1,1);
                    end
                end
                [varargout{1:nargout}] = fxn(varargin{:});
            end
        end
    end

    methods( Access = protected )
%    methods( Access = public )
        function images = loadCell(obj,varargin)
            % mark unused dimensions with a NaN flag
            % varargin will have length 3
            varargin(nargin :3) = {NaN};
            [cv,tv,zv] = deal(varargin{:});
            ndim = nargin - 1;
            images = cell([length(cv) length(tv) length(zv) 1]);
            for c = 1:length(cv)
                for t = 1:length(tv)
                    for z = 1:length(zv)
                        sub = { cv(c) tv(t) zv(z) };
                        % LinearReader deals with linearizing subindices
                        images{c,t,z} = obj.loadImage_(sub{1:ndim});
                     end
                 end
             end
        end
        function R = getSubIndexReader(obj,S)
            % support subclasses of CellReader
            classfcn = str2func(class(obj));
            R = classfcn(SubIndexReader(obj,S(1).subs{:}));
        end
        function Q = translateNamedIndex(obj,S)
            % build a smooth brace subindex structure
            Q.type = '()';
            Q.subs = {':' ':' ':'};
            % map dimensions
            map = struct('c',1,'t',2,'z',3);
            if(length(S) > 1 && strcmp(S(2).type,'()'))
                Q.subs(map.(S(1).subs)) = S(2).subs;
                Q = [Q S(3:end)];
            else
                % no index given
                % do nothing? no, fail!
                error('CellReader: Named subindex requires subindex.')
                Q = [Q S(2:end)];
            end
        end
    end
    
end



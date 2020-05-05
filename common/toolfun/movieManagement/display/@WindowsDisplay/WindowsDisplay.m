classdef WindowsDisplay < MovieDataDisplay
    %Concrete class for displaying windows
    properties
        Color='r';
        FaceAlpha=.2;
        showNum=5;
        ButtonDownFcn = [];
    end
    methods
        function obj=WindowsDisplay(varargin)
            obj@MovieDataDisplay(varargin{:});
        end
        
        function h=initDraw(obj, data, tag, varargin)
            
            windowArgs = {obj.Color,'FaceAlpha',obj.FaceAlpha};
            h = plotWindows(data, windowArgs, obj.showNum);
            set(h, 'Tag', tag, 'ButtonDownFcn', obj.ButtonDownFcn);
        end
        
        function updateDraw(obj, h, data)
            tag = get(h(1), 'Tag');
            delete(h);
            obj.initDraw(data, tag);
        end
    end
    
    methods (Static)
        function params=getParamValidators()
            params(1).name='Color';
            params(1).validator=@ischar;
            params(2).name='FaceAlpha';
            params(2).validator=@isscalar;
            params(3).name='showNum';
            params(3).validator=@isscalar;
            params(4).name='ButtonDownFcn';
            params(4).validator=@(x) isempty(x) || isa(x, 'function_handle');
            
        end
        function f=getDataValidator()
            f=@iscell;
        end
    end
end

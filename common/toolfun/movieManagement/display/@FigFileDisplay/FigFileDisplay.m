classdef FigFileDisplay < MovieDataDisplay
    %Concreate class to display external fig-file
    
    methods
        function obj=FigFileDisplay(varargin)
            obj@MovieDataDisplay(varargin{:})
        end
        
        function h=initDraw(obj,data,tag,varargin)
            % Plot the image and associate the tag
            h=gcf;         
            clf;
            h2= hgload(data, struct('visible','off'));
            copyobj(get(h2,'Children'),h);
            set(h,'Tag',tag);
        end
        function updateDraw(obj,h,data)
            h2= hgload(data, struct('visible','off'));
            copyobj(get(h2,'Children'),h);
        end  
    end 

    methods (Static)
        function params=getParamValidators()
            params=[];
        end
        function f=getDataValidator()
            f=@ischar;
        end
    end    
end
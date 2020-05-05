classdef NameableProcess < Process
    %NameableProcess A process whose name can be set
    
    properties (Access = protected)
    end
    
    methods
        function setName(obj,name)
            obj.name_ = name;
        end
        function name = getConcreteName(obj)
            if(isempty(obj) || isempty(obj.name_))
                name =  obj.getName();
                return;
            end
            name = obj.name_;
        end
    end
    
end


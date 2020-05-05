function status = isConcreteClass(classname)
%ISSUBCLASS check if a classname is a concrete class
%
% Synopsis  status = isConcreteClass(classname)
%
% Input:
%   classname - a string giving the name of the class
%
% Output
%   status - boolean. Return true if class is concrete (can be instantiated)

% Sebastien Besson, Jan 2012

% Input check
ip =inputParser;
ip.addRequired('classname',@ischar);
ip.parse(classname);


% Check validity of child class
class_meta = meta.class.fromName(classname);
assert(~isempty(class_meta),' %s is not a valid class',classname);

if isprop(class_meta, 'MethodList')
    metaMethods = class_meta.MethodList;
else
    metaMethods = [class_meta.Methods{:}];
end
status = ~any([metaMethods.Abstract]);



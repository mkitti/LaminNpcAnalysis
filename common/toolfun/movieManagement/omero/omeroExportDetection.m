function roi = omeroExportDetection(movieData,movieInfo)
% omeroExportDetection export the output of a detection to the OMERO server
%
% omeroExportDetection export the output of any detection process
% (generating a movieInfo like structure into OMERO. After creates a single
% ROI, the function creates as many Point shapes as the number of detected
% objects and sets the timepoints and x,y coordinates of this point shape
% using the detection information. Finally, the roi is attached to the
% image on the server.
%
% omeroExportDetection(movieData,movieInfo)
%
% Input:
%
%   movieData - A MovieData object
%
%   movieInfo - The output of a detection process
%
% Output:
%
%   roi - A detection ROI uploaded to the server

% Sebastien Besson, Jun 2012 (last modified Oct 2012)

ns = getLCCBOmeroNamespace('detection');

% Input check
ip=inputParser;
ip.addRequired('movieData', @(x) isa(x,'MovieData') && x.isOmero() && x.canUpload());
ip.addRequired('movieInfo', @isstruct);
ip.parse(movieData, movieInfo);

% Retrieve image and update service
image = movieData.getReader().getImage();
roiService = movieData.getOmeroSession().getRoiService();
updateService = movieData.getOmeroSession().getUpdateService();

% Get previously saved ROIs with same namespace
roiOptions = omero.api.RoiOptions();
roiOptions.namespace = omero.rtypes.rstring(ns);
rois = roiService.findByImage(movieData.getOmeroId(), roiOptions).rois();

if rois.size()> 0
    % Create a list of detection ROIs to remove
    fprintf('Deleting %g existing ROI(s) with namespace %s\n', rois.size(), ns);
    list = javaArray('omero.api.delete.DeleteCommand', 1);
    for i = 1:rois().size()
        roiId = rois.get(i-1).getId().getValue;
        list(i) = omero.api.delete.DeleteCommand('/Roi', roiId, []);
    end
    
    %Delete the ROIs
    movieData.getOmeroSession().getDeleteService().queueDelete(list);
end

% Create a new ROI to attach to the image
fprintf('Creating detection ROI for Image %u with namespace %s\n', ...
    image.getId().getValue(), ns);
roi = omero.model.RoiI();
roi.setImage(image);
roi.setNamespaces(ns);

% Create point shapes and add them to the detection ROI
progressText(0, 'Adding detection results frame-by-frame')
for t=1:size(movieInfo,1)
    
    for i = 1:size(movieInfo(t).xCoord,1)
        point = setShapeCoordinates(createPoint(movieInfo(t).xCoord(i,1),...
            movieInfo(t).yCoord(i,1)), 0, 0, t-1);
        roi.addShape(point);
    end
    
    progressText(t/size(movieInfo,1))
end

% Upload ROI to server
fprintf('Uploading ROI to server\n');
groupId = image.getDetails().getGroup().getId().getValue();
context = java.util.Hashmap;
context.put('omero.group', java.lang.String(num2str(groupId)));
updateService.saveAndReturnObject(roi, context);
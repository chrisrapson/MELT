function bbox = get_active_bbox(app, image_dir, image_name)
bbox = [];

%1. load list of bboxes
bbox_list = load_bbox_list(image_dir, image_name);

if ~isempty(bbox_list)
	%2. get indices of active bbox
	bbox_ix = app.KleverImageLabellingToolKILTUIFigure.UserData.bbox_ix;
	if isempty(bbox_ix)
		bbox_ix = 1;
	end
	if bbox_ix > length(bbox_list)
		warning(['bbox_ix=',num2str(bbox_ix)])
	end

	%3. crop image to bbox
	bbox = bbox_list(bbox_ix,:);
end
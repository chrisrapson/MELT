function bbox = get_active_bbox(app, image_dir, image_name, max_dims)
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

	%3. select coordinates of active bbox
	bbox = bbox_list(bbox_ix,:);

	%check none of the indices are 0
	bbox(bbox==0) = 1;
	%check none of the indices are larger than the image size
	if bbox(3) > max_dims(2)
		bbox(3) = max_dims(2);
	end
	if bbox(4) > max_dims(1)
		bbox(4) = max_dims(1);
	end
end
function bbox = get_active_bbox(app, image_dir, image_name, max_dims)
bbox = [];

%1. load list of bboxes
bbox_list = load_bbox_list(image_dir, image_name);

if ~isempty(bbox_list)
	%2. get indices of active bbox
	bbox_ix = app.MoreEfficientLabellingToolMELTUIFigure.UserData.bbox_ix;
	if isempty(bbox_ix)
		bbox_ix = 1;
	end

	%3. select coordinates of active bbox
	if bbox_ix > 0 && bbox_ix <= size(bbox_list,1)
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
end
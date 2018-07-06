function bbox_list = load_bbox_list(image_dir, image_name)
%KITTI format
[parent_dir, images_dir] = fileparts(image_dir);
labels_dir = fullfile(parent_dir, strrep(images_dir, 'image','label'));
[~,fname, fext] = fileparts(image_name);

bbox_list = [];
if exist(fullfile(labels_dir,[fname, '.txt']), 'file')
	tmp = importdata(fullfile(labels_dir, [fname, '.txt']));
	bbox_list = tmp.data(:,4:7); %bboxes only. See file format description https://github.com/umautobots/vod-converter/blob/master/vod_converter/kitti.py
	bbox_list = bbox_list + 1; %labels are 0-based pixel numbers. Add 1 to give matlab indices
	for ii=size(bbox_list,1):-1:1
		if strcmpi(tmp.rowheaders{ii}, 'Car') ...
				|| strcmpi(tmp.rowheaders{ii}, 'Truck') ...
				|| strcmpi(tmp.rowheaders{ii}, 'Vehicle') ...
				|| strcmpi(tmp.rowheaders{ii}, 'Bus') ...
				|| strcmpi(tmp.rowheaders{ii}, 'SUV') ...
				|| strcmpi(tmp.rowheaders{ii}, 'Van') ...
				|| strcmpi(tmp.rowheaders{ii}, 'Misc') ...
				|| strcmpi(tmp.rowheaders{ii}, 'DontCare')
			%round to pixel indices
			bbox_list(ii,1) = floor(bbox_list(ii,1));
			bbox_list(ii,2) = floor(bbox_list(ii,2));
			bbox_list(ii,3) = ceil(bbox_list(ii,3));
			bbox_list(ii,4) = ceil(bbox_list(ii,4));
		else
			bbox_list(ii,:) = [];
		end
	end
else
	warning(['labels file not found: ',fullfile(labels_dir, [fname, '.txt'])])
end
	
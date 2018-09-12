function bbox_list = load_bbox_list(image_dir, image_name)
if strcmp(image_dir(end-5:end),'masked')
	[image_dir,~,~] = fileparts(image_dir);
end
[parent_dir, images_dir] = fileparts(image_dir);
labels_dir = fullfile(parent_dir, strrep(images_dir, 'image','label'));
[~,fname, ~] = fileparts(image_name);

%Cityscapes format
% relevant_labels_cityscapes = [26,27,28,29,30];
% %26= car
% %27= truck
% %28= bus
% %29= caravan
% %30= trailer
relevant_cat_labels_cityscapes = [0, 7]; %vehicle. Includes unwanted train, motocycle, bicycle, license plate

bbox_list = [];

if contains(parent_dir, 'darknet')
	%darknet might be a subfolder of KITTI/Berkeley etc so check it first
	tmp = importdata(fullfile(labels_dir, [fname, '.txt']));
	bbox_list = tmp.data(:,2:5); %bboxes only
	I = imread(fullfile(image_dir, image_name));
	[w_img, h_img] = size(I);
	for ii=size(bbox_list,1):-1:1
		w_bbox = bbox_list(3);
		h_bbox = bbox_list(4);
		bbox_list(ii,1) = floor((bbox_list(ii,1) - w_bbox/2)*w_img);
		bbox_list(ii,2) = floor((bbox_list(ii,2) - h_bbox/2)*h_img);
		bbox_list(ii,3) = ceil((bbox_list(ii,1) + w_bbox/2)*w_img);
		bbox_list(ii,4) = ceil((bbox_list(ii,2) + h_bbox/2)*h_img);
	end
elseif contains(parent_dir, 'KITTI')
	if contains(parent_dir, 'videos')
		labels_dir = strrep(parent_dir, 'image','label');
		fid = fopen(fullfile(labels_dir, [images_dir, '.txt']), 'r');
% 		tmp = fscanf(fid,'%d%d%s%d%d%f%f%f %f%f%f %f%f%f %f%f%f');
		frame_ix = -1;
		while frame_ix < str2double(fname)
			tmp_split = split(fgetl(fid));
			frame_ix = str2double(tmp_split{1});
		end
		while frame_ix == str2double(fname)
			class = tmp_split{3};
			if strcmpi(class, 'Car') ...
						|| strcmpi(class, 'Truck') ...
						|| strcmpi(class, 'Vehicle') ...
						|| strcmpi(class, 'Bus') ...
						|| strcmpi(class, 'SUV') ...
						|| strcmpi(class, 'Van') ...
						|| strcmpi(class, 'Misc') ...
						|| strcmpi(class, 'DontCare')
				x1 = str2double(tmp_split{7});
				y1 = str2double(tmp_split{8});
				x2 = str2double(tmp_split{9});
				y2 = str2num(tmp_split{10});
				bbox_list = [bbox_list; floor(x1), floor(y1), ceil(x2), ceil(y2)];
			end
			tmp_split = split(fgetl(fid));
			frame_ix = str2double(tmp_split{1});
		end
		fclose(fid);
	elseif contains(parent_dir, 'images')
		tmp = importdata(fullfile(labels_dir, [fname, '.txt']));
		if ~isempty(tmp)
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
		end
	else
		error('path to groundtruth file must include the substring ''images'' or ''videos'' so that I know what I''m dealing with')
	end
elseif contains(parent_dir, 'Foggy')
	tmp = importdata(fullfile(labels_dir, [fname, '.txt']));
	if ~isempty(tmp)
		bbox_list = tmp(:,2:5); %bboxes only
% 		bbox_list = bbox_list + 1; %labels are 0-based pixel numbers. Add 1 to give matlab indices
		for ii=size(bbox_list,1):-1:1
			if ismember(tmp(ii,1), relevant_cat_labels_cityscapes)
% 				%round to pixel indices
% 				bbox_list(ii,1) = floor(bbox_list(ii,1));
% 				bbox_list(ii,2) = floor(bbox_list(ii,2));
% 				bbox_list(ii,3) = ceil(bbox_list(ii,3));
% 				bbox_list(ii,4) = ceil(bbox_list(ii,4));
			else
				bbox_list(ii,:) = [];
			end
		end
	end
elseif contains(parent_dir, 'Berkeley')
	if exist(fullfile(labels_dir,[fname, '.json']), 'file')
		fid = fopen(fullfile(labels_dir,[fname, '.json']));
		raw = fread(fid, inf);
		fclose(fid);
		str = char(raw');
		data = jsondecode(str);

		objects = data.frames.objects;
		for ii = 1:length(objects)
			if iscell(objects)
				tmp = objects{ii};
			elseif isstruct(objects)
				tmp = objects(ii);
			end
			
			if strcmp(tmp.category, 'car') || ...
				 strcmp(tmp.category, 'truck') || ...
				 strcmp(tmp.category, 'bus')  || ...
				 strcmp(tmp.category, 'motor') 
				bbox = tmp.box2d;
				bbox_list = [bbox_list;   floor(bbox.x1), floor(bbox.y1), ceil(bbox.x2), ceil(bbox.y2)];
			elseif (strcmp(tmp.category, 'person') || ...
							 strcmp(tmp.category, 'rider') || ...
							 strcmp(tmp.category, 'bike') || ...
							 strcmp(tmp.category, 'train') || ...
							 strcmp(tmp.category, 'lane/single white') || ...
							 strcmp(tmp.category, 'lane/double white') || ...
							 strcmp(tmp.category, 'lane/single yellow') || ...
							 strcmp(tmp.category, 'lane/double yellow') || ...
							 strcmp(tmp.category, 'lane/single other') || ...
							 strcmp(tmp.category, 'lane/road curb') || ...
							 strcmp(tmp.category, 'lane/crosswalk') || ...
							 strcmp(tmp.category, 'area/drivable') || ...
							 strcmp(tmp.category, 'lane/double yellow') || ...
							 strcmp(tmp.category, 'area/alternative') || ...
							 strcmp(tmp.category, 'traffic sign') || ...
							 strcmp(tmp.category, 'traffic light') ...
						  )
				%do nothing
			else
				disp(tmp.category);
			end
		end
	end
	
elseif contains(parent_dir, 'Cityscapes') || contains(parent_dir, 'Wilddash')
	fname = strrep(fname, 'leftImg8bit','gtFine_polygons');
	if ~exist(fullfile(labels_dir,[fname, '.json']), 'file')
		fname = [fname,'_polygons'];
	end
	if exist(fullfile(labels_dir,[fname, '.json']), 'file')
		fid = fopen(fullfile(labels_dir,[fname, '.json']));
		raw = fread(fid, inf);
		fclose(fid);
		str = char(raw');
		data = jsondecode(str);
		objects = data.objects;
		for ii = 1:length(objects)
			if (strcmp(objects(ii).label, 'car') || ...
				  strcmp(objects(ii).label, 'truck') || ...
				  strcmp(objects(ii).label, 'truckgroup') || ...
				  strcmp(objects(ii).label, 'trailer') || ...
				  strcmp(objects(ii).label, 'bus') || ...
				  strcmp(objects(ii).label, 'caravan') ...
					)
				poly = objects(ii).polygon;
				x_mm = minmax(poly(:,1)');
				y_mm = minmax(poly(:,2)');
				bbox_list = [bbox_list; x_mm(1), y_mm(1), x_mm(2), y_mm(2)];
			elseif (strcmp(objects(ii).label, 'road') || ...
							 strcmp(objects(ii).label, 'ground') || ...
							 strcmp(objects(ii).label, 'sidewalk') || ...
							 strcmp(objects(ii).label, 'wall') || ...
							 strcmp(objects(ii).label, 'fence') || ...
							 strcmp(objects(ii).label, 'rail track') || ...
							 strcmp(objects(ii).label, 'tunnel') || ...
							 strcmp(objects(ii).label, 'parking') || ...
							 strcmp(objects(ii).label, 'sky') || ...
							 strcmp(objects(ii).label, 'terrain') || ...
							 strcmp(objects(ii).label, 'building') || ...
							 strcmp(objects(ii).label, 'bridge') || ...
							 strcmp(objects(ii).label, 'vegetation') || ...
							 strcmp(objects(ii).label, 'guard rail') || ...
							 strcmp(objects(ii).label, 'pole') || ...
							 strcmp(objects(ii).label, 'polegroup') || ...
							 strcmp(objects(ii).label, 'traffic sign') || ...
							 strcmp(objects(ii).label, 'traffic light') || ...
							 strcmp(objects(ii).label, 'bicycle') || ...
							 strcmp(objects(ii).label, 'bicyclegroup') || ...
							 strcmp(objects(ii).label, 'motorcycle') || ...
							 strcmp(objects(ii).label, 'motorcyclegroup') || ...
							 strcmp(objects(ii).label, 'cargroup') || ...
							 strcmp(objects(ii).label, 'person') || ...
							 strcmp(objects(ii).label, 'persongroup') || ...
							 strcmp(objects(ii).label, 'rider') || ...
							 strcmp(objects(ii).label, 'ridergroup') || ...
							 strcmp(objects(ii).label, 'train') || ...
							 strcmp(objects(ii).label, 'on rails') || ...
							 strcmp(objects(ii).label, 'ego vehicle') || ...
							 strcmp(objects(ii).label, 'license plate') || ...
							 strcmp(objects(ii).label, 'static') || ...
							 strcmp(objects(ii).label, 'dynamic') || ...
							 strcmp(objects(ii).label, 'rectification border') || ...
							 strcmp(objects(ii).label, 'out of roi') ...
						  )
				%do nothing
			else
				I = imread(fullfile(image_dir,'unmasked', image_name));
				figure
				imagesc(I)
				poly = objects(ii).polygon;
				hold all
				plot([poly(:,1); poly(1,1)], [poly(:,2); poly(1,2)],'m-')
				title(objects(ii).label);
			end
		end
	end
elseif contains(parent_dir, 'SYSU')
	fid = fopen(fullfile(labels_dir, 'groundtruth.txt'), 'r');
	line_number = str2num(image_name(5:7)); %#ok operating on a vector
	tmp = textscan(fid, '%[^\n]', 1, 'HeaderLines', line_number-1);
	fclose(fid);

	tmp_split = split(tmp{1});
	%check match
	if strcmp(tmp_split(1), image_name)
% 		category = tmp_split(2);
		for ii = 6:4:length(tmp_split)
			x = str2double(tmp_split{ii-3});
			y = str2double(tmp_split{ii-2});
			bbox_list = [bbox_list; x, y, x+str2num(tmp_split{ii-1}), y+str2num(tmp_split{ii})];
		end
	else
		disp(['looking for a line matching image ',image_name,' but found ',tmp{1}])
	end
else
	warning(['labels file not found: ',fullfile(labels_dir, [fname, '.txt'])])
end

%TODO: should this depend on the resolution of the image?
min_bbox_area = 1600; %pixels 40x40
for ii=size(bbox_list,1):-1:1
	bbox_area = (bbox_list(ii,3) - bbox_list(ii,1)) * (bbox_list(ii,4) - bbox_list(ii,2));
	if bbox_area < min_bbox_area
		bbox_list(ii,:) = [];
	end
end
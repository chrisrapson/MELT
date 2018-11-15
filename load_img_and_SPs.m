%loads image and superpixels
I = [];
BM = [];
my_title = [];
bbox = [];
	
ax = app.UIAxes;
my_UIFigure = app.MoreEfficientLabellingToolMELTUIFigure; % needed for load_img_and_SPs
filenames = my_UIFigure.UserData.image_files;
file_ix = my_UIFigure.UserData.image_index;

%update
mask_filename = app.maskfilenameEditField_2.Value;

mask = app.MoreEfficientLabellingToolMELTUIFigure.UserData.mask; %should match bbox
if isnumeric(file_ix) && file_ix > 0 && mod(file_ix,1) == 0 ...
		&& file_ix <= length(filenames)
	f = filenames(file_ix);
	file = fullfile(f.folder, f.name);

	I = imread(file);
	
	if app.BboxesonlyCheckBox.Value
		bbox = get_active_bbox(app, f.folder, f.name, size(I));
		
		if isempty(bbox)
			bbox = [1, 1, size(I,2), size(I,1)];
			disp(['no vehicle bounding boxes in image ',f.name])	
		end
	else
		bbox = [1, 1, size(I,2), size(I,1)];
	end
	
	I = I(bbox(2):bbox(4), bbox(1):bbox(3), :);
	
	if isempty(mask)
		mask_file = fullfile(f.folder, mask_filename);
		if exist(mask_file, 'file')
			mask = imread(mask_file); %should match image file
			mask = mask(bbox(2):bbox(4), bbox(1):bbox(3),1);
		end
	end
	if ~(size(mask,1) == size(I,1) && size(mask,2) == size(I,2))
		if ~isempty(mask)
			if any(mask(:))
				warning('mask and image sizes don''t match. Clearing mask')
			end
		end
		mask = zeros(size(I,1), size(I,2));
	end
	
	if strncmp(app.choice_of_algo.Value, 'Superpixels', 11)
		SP_algo = app.choice_of_algo.Value(13:end);
		SP_size = app.SP_or_Brush_size_Spinner.Value;
		SP_compactness = app.SuperpixelcompactnessSpinner.Value;
		SP_size = min(SP_size, floor(numel(I)/2));
		if strncmpi(SP_algo, 'slic', 4)
	 		SP = superpixels(I, SP_size, 'method', SP_algo, 'compactness', SP_compactness);
		else %SNIC
			[SP, ~] = snic_mex(I, SP_size, SP_compactness);
		end
		BM = boundarymask(SP, 4);
	end
	my_title = f.name;
end

app.MoreEfficientLabellingToolMELTUIFigure.UserData.mask = mask;
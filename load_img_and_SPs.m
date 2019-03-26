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

if isnumeric(file_ix) && file_ix > 0 && mod(file_ix,1) == 0 ...
		&& file_ix <= length(filenames)
	f = filenames(file_ix);
	file = fullfile(f.folder, f.name);

	I = imread(file);
	%if the image is grayscale, convert it to RGB, to avoid uncomfortable bugs
	%e.g. no image shown in plot_image.m: ih1 = imagesc(I, 'Parent', ax);
	%TODO: is there a better way?
	if ismatrix(I)
		I = cat(3, I, I, I);
	end
	
	if app.BboxesonlyCheckBox.Value
		bbox = get_active_bbox(app, f.folder, f.name, size(I));
		
		if isempty(bbox)
			bbox = [1, 1, size(I,2), size(I,1)];
			disp(['no vehicle bounding boxes in image ',f.name])	
		end
	else
		bbox = [1, 1, size(I,2), size(I,1)];
	end
	
	full_mask = app.MoreEfficientLabellingToolMELTUIFigure.UserData.full_mask; %should match bbox
	if isempty(full_mask)
		mask_file = fullfile(f.folder, mask_filename);
		if exist(mask_file, 'file')
			full_mask = imread(mask_file); %should match image file
			app.MoreEfficientLabellingToolMELTUIFigure.UserData.full_mask = full_mask;
		else
			full_mask = zeros(size(I,1), size(I,2));
		end
	end
	
	if ~(size(full_mask,1) == size(I,1) && size(full_mask,2) == size(I,2))
		if ~isempty(full_mask)
			if any(full_mask(:))
				warning('mask and image sizes don''t match. Clearing mask')
			end
		end
		full_mask = zeros(size(I,1), size(I,2));
	end
	I = I(bbox(2):bbox(4), bbox(1):bbox(3), :);
	mask = full_mask(bbox(2):bbox(4), bbox(1):bbox(3));
	
	
	if strncmp(app.choice_of_algo.Value, 'Superpixels', 11)
		SP_algo = app.choice_of_algo.Value(13:end);
		SP_size = app.SP_or_Brush_size_Spinner.Value;
		SP_compactness = app.SuperpixelcompactnessSpinner.Value;
		SP_size = min(SP_size, floor(numel(I)/2));
		if strncmpi(SP_algo, 'slic', 4)
	 		SP = superpixels(I, SP_size, 'method', SP_algo, 'compactness', SP_compactness);
		else %SNIC
			if exist('snic_mex','file') == 3
				[SP, ~] = snic_mex(I, SP_size, SP_compactness);
			else
				%link to snic_mex.cpp from Achanta2017
				%https://ivrl.epfl.ch/research-2/research-current/research-superpixels/
				warning('If you do not have the SNIC function on your computer, please download it from https://ivrl.epfl.ch/wp-content/uploads/2018/08/SLIC_mex.zip')
			end
		end
		BM = boundarymask(SP, 4);
	end
	my_title = f.name;
end
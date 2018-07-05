%loads image and superpixels

ax = app.UIAxes;
my_UIFigure = app.KleverImageLabellingToolKILTUIFigure; % needed for load_img_and_SPs
SP_algo = app.choice_of_superpixel_algo.Value;
SP_size = app.NumberofSuperpixelsSpinner.Value;
SP_compactness = app.SuperpixelcompactnessSpinner.Value;
filenames = my_UIFigure.UserData.image_files;
file_ix = my_UIFigure.UserData.image_index;

%update
mask_filename = app.maskfilenameEditField_2.Value;

mask = app.KleverImageLabellingToolKILTUIFigure.UserData.mask;
if isnumeric(file_ix) && file_ix > 0 && mod(file_ix,1) == 0 ...
		&& file_ix <= length(filenames)
	f = filenames(file_ix);
	file = fullfile(f.folder, f.name);

	I = imread(file);
	SP = superpixels(I, SP_size, 'method', SP_algo, 'compactness', SP_compactness);
	BM = boundarymask(SP);
	my_title = f.name;
	
	if isempty(mask)
		mask_file = fullfile(f.folder, mask_filename);
		if exist(mask_file, 'file')
			mask = imread(mask_file);
		end
	end
	if ~(size(mask,1) == size(I,1) && size(mask,2) == size(I,2))
		if ~isempty(mask)
			warning('mask and image sizes don''t match. Clearing mask')
		end
		mask = zeros(size(I,1), size(I,2));
	end
	
else
	I = [];
	BM = [];
	my_title = [];
end

app.KleverImageLabellingToolKILTUIFigure.UserData.mask = mask;
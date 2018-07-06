function save_mask(app)
%save mask to a prescribed file

file_ix = app.KleverImageLabellingToolKILTUIFigure.UserData.image_index;
filenames = app.KleverImageLabellingToolKILTUIFigure.UserData.image_files;
f = filenames(file_ix);
mask_filename = app.maskfilenameEditField_2.Value;

mask_fullfilename = fullfile(f.folder, mask_filename);

mask = app.KleverImageLabellingToolKILTUIFigure.UserData.mask;
if app.BboxesonlyCheckBox.Value
	%load saved mask and overwrite the relevant section of it with the mask for the active_bbox
	if exist(mask_fullfilename, 'file')
		full_mask = imread(mask_fullfilename);
		full_mask = full_mask(:,:,1);
	else
		image_file = fullfile(f.folder, f.name);
		if exist(image_file, 'file')
			I = imread(image_file);
			full_mask = zeros(size(I,1), size(I,2));
		else
			error(['can''t find image file ', image_file, ' or mask file ',mask_fullfilename])
		end
	end
	bbox = get_active_bbox(app, f.folder, f.name);
	if ~isempty(bbox) && ~isempty(mask)
		full_mask(bbox(2):bbox(4), bbox(1):bbox(3)) = mask;
	end
	mask = full_mask;
end

if strcmpi(mask_fullfilename(end-3:end),'.png') || strcmpi(mask_fullfilename(end-3:end),'.jpg')
	imwrite(uint8(mask), mask_fullfilename)
else
	imwrite(uint8(mask), mask_fullfilename, 'png')
end
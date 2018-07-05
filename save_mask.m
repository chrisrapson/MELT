function save_mask(app)
%save mask to a prescribed file

file_ix = app.KleverImageLabellingToolKILTUIFigure.UserData.image_index;
filenames = app.KleverImageLabellingToolKILTUIFigure.UserData.image_files;
f = filenames(file_ix);
mask_filename = app.maskfilenameEditField_2.Value;

file = fullfile(f.folder, mask_filename);

if strcmpi(file(end-3:end),'.png') || strcmpi(file(end-3:end),'.jpg')
	imwrite(uint8(app.KleverImageLabellingToolKILTUIFigure.UserData.mask), file)
else
	imwrite(app.KleverImageLabellingToolKILTUIFigure.UserData.mask, file, 'png')
end
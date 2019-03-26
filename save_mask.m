function save_mask(app)
%save mask to a prescribed file

file_ix = app.MoreEfficientLabellingToolMELTUIFigure.UserData.image_index;
filenames = app.MoreEfficientLabellingToolMELTUIFigure.UserData.image_files;
f = filenames(file_ix);
mask_filename = app.maskfilenameEditField_2.Value;

mask_fullfilename = fullfile(f.folder, mask_filename);

full_mask = app.MoreEfficientLabellingToolMELTUIFigure.UserData.full_mask;

if ~isempty(full_mask)
	if strcmpi(mask_fullfilename(end-3:end),'.png') 
		imwrite(uint8(full_mask), mask_fullfilename)
	elseif strcmpi(mask_fullfilename(end-3:end),'.jpg')
		%don't save as jpg because lossless jpg is not well supported
		%files don't open in gimp or MS Photos 
		mask_fullfilename(end-3:end) = '.png';
		imwrite(uint8(full_mask), mask_fullfilename)%, 'Mode','lossless')
	else
		imwrite(uint8(full_mask), mask_fullfilename, 'png')
	end
end
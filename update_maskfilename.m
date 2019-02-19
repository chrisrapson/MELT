function update_maskfilename(app)
asterix_ix = strfind(app.maskfilenameEditField.Value, '*');
if length(asterix_ix) > 1
		error('please only use 1 wildcard (*) in the mask filename field')
else
		filenames = app.MoreEfficientLabellingToolMELTUIFigure.UserData.image_files;
		file_ix = app.MoreEfficientLabellingToolMELTUIFigure.UserData.image_index;
		if ~isempty(filenames)
				if isnumeric(file_ix) && file_ix > 0 && mod(file_ix,1) == 0 ...
					&& file_ix <= length(filenames)
						f = filenames(file_ix);
						img_filename = f.name;

						%always save mask as png because jpgs are lossy (lossless jpgs not supported)
						[~, img_fn, img_ext] = fileparts(img_filename);
						img_filename = [img_fn, '.png'];
				else
						disp('file not found')
						img_filename = [];
				end
				if isempty(asterix_ix) || length(app.maskfilenameEditField.Value) == 1
						defaut_prefix = 'mask_';
						app.maskfilenameEditField_2.Text = [default_prefix, img_filename];
				elseif asterix_ix == 1
						suffix = app.maskfilenameEditField.Value(2:end);
						[~, img_filename, img_ext] = fileparts(img_filename);
						app.maskfilenameEditField_2.Text = [img_filename, suffix];
				elseif asterix_ix == length(app.maskfilenameEditField.Value)
						prefix = app.maskfilenameEditField.Value(1:end-1);
						app.maskfilenameEditField_2.Value = [prefix, img_filename];
				else
						prefix = app.maskfilenameEditField.Value(1 : asterix_ix-1);
						suffix = app.maskfilenameEditField.Value(asterix_ix+1 : end);
						[~, img_filename, img_ext] = fileparts(img_filename);
						app.maskfilenameEditField_2.Value = [prefix, img_filename, suffix];
				end
		end
end
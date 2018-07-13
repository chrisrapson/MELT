function im_ButtonDownFcn(im, hit, app)

%button_ix is the active label
[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);
selectedButton = app.LabelsButtonGroup.SelectedObject;

if n_buttons > 0
	button_ix = get_button_ix(all_buttons, selectedButton, n_buttons);
	
	load_img_and_SPs;

	mouse_pos = flip(round(hit.IntersectionPoint(1:2)));
	mouse_pos(1) = max(1, min(size(mask,1), mouse_pos(1)));
	mouse_pos(2) = max(1, min(size(mask,2), mouse_pos(2)));

	if strncmp(app.choice_of_algo.Value, 'Superpixels', 11) %matches Slic and Slic0
		%apply label to whole Superpixel
		chosen_SP_index = SP(mouse_pos(1), mouse_pos(2));

		%in the mask, set all of the pixels from this superpixel to button_ix
		if app.EraseButton.Value
			mask(SP == chosen_SP_index) = 0;
		else
			mask(SP == chosen_SP_index) = button_ix;
		end
	elseif strcmp(app.choice_of_algo.Value, 'Polygon')
		disp('im_ButtonDownFcn triggered in polygon mode, but this function hasn''t been implemented yet')
		%TODO: left button add vertex to polygon
		%      right button close polygon, update mask and reset vertices
	elseif strcmp(app.choice_of_algo.Value, 'Brush')
		brush_size = app.SP_or_Brush_size_Spinner.Value;
		pixels_to_label_x = [max(1,mouse_pos(1)-brush_size+1) : min(size(mask,1), mouse_pos(1)+brush_size-1)];
		pixels_to_label_y = [max(1,mouse_pos(2)-brush_size+1) : min(size(mask,2), mouse_pos(2)+brush_size-1)];
		%pixel-by-pixel labelling
		if app.EraseButton.Value
			mask(pixels_to_label_x, pixels_to_label_y) = 0;
		else
			mask(pixels_to_label_x, pixels_to_label_y) = button_ix;
		end
	end
	
	app.KleverImageLabellingToolKILTUIFigure.UserData.mask = mask;
	plot_image;
end
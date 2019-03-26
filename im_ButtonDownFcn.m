function im_ButtonDownFcn(im, hit, app)

% if strcmp(zoom(app.UIAxes), 'on') || strcmp(pan(app.UIAxes), 'on')
% 	return
% end
	
%button_ix is the active label
[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);
selectedButton = app.LabelsButtonGroup.SelectedObject;

if n_buttons > 0
	button_ix = get_button_ix(all_buttons, selectedButton, n_buttons);
	
	load_img_and_SPs;

	mouse_pos = flip(round(hit.IntersectionPoint(1:2)));
	if all(isnan(mouse_pos))
		error('could not get the position of your mouse click. This may be related to using a Mac or a TrackPad, or something completely different. Sorry, there appears to be no solution available at the moment')
	end
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
		%DONE: left button add vertex to polygon
		%      left button near first vertex --> close polygon, update mask
		%      right button clear vertices
		if hit.Button == 1
			if isfield(app.MoreEfficientLabellingToolMELTUIFigure.UserData, 'polygon_in_progress')
				p_i_p = app.MoreEfficientLabellingToolMELTUIFigure.UserData.polygon_in_progress;
			else
				p_i_p = [];
			end
			if (size(p_i_p,1) < 2) || ...                                               %at least 3 points to make a closed polygon
					sqrt((mouse_pos(1) - p_i_p(1,1))^2 + (mouse_pos(2) - p_i_p(1,2))^2) > 2 %mouse close to first point of polygon
				%add new point to polygon
				app.MoreEfficientLabellingToolMELTUIFigure.UserData.polygon_in_progress = [p_i_p; mouse_pos];
			else
				%close polygon and label pixels
				in = poly2mask(p_i_p(:,2), p_i_p(:,1), size(mask,1), size(mask,2));
				if app.EraseButton.Value
					mask(in) = 0;
				else
					mask(in) = button_ix;
				end
				app.MoreEfficientLabellingToolMELTUIFigure.UserData.polygon_in_progress = [];
			end
		else
			app.MoreEfficientLabellingToolMELTUIFigure.UserData.polygon_in_progress = [];
		end
	elseif strcmp(app.choice_of_algo.Value, 'Brush')
		brush_size = app.SP_or_Brush_size_Spinner.Value;
		pixels_to_label_x = [max(1,mouse_pos(1)-floor(brush_size/2)) : min(size(mask,1), mouse_pos(1)+floor(brush_size/2))];
		pixels_to_label_y = [max(1,mouse_pos(2)-floor(brush_size/2)) : min(size(mask,2), mouse_pos(2)+floor(brush_size/2))];
		%pixel-by-pixel labelling
		if app.EraseButton.Value
			mask(pixels_to_label_x, pixels_to_label_y) = 0;
		else
			mask(pixels_to_label_x, pixels_to_label_y) = button_ix;
		end
	end
	
	full_mask(bbox(2):bbox(4), bbox(1):bbox(3)) = mask;
	app.MoreEfficientLabellingToolMELTUIFigure.UserData.full_mask = full_mask;
	
	tight_ax = 0; %disable fitting image to axes
	plot_image;
end
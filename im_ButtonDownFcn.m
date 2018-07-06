function im_ButtonDownFcn(im, hit, app)

%button_ix is the active label
all_buttons = app.LabelsButtonGroup.Children;
selectedButton = app.LabelsButtonGroup.SelectedObject;
n_buttons = length(all_buttons);

if n_buttons > 0
	button_ix = get_button_ix(all_buttons, selectedButton, n_buttons);
	
	load_img_and_SPs;

	%TODO: check whether round or ceil is more appropriate by zooming in to maximum and clicking in top-left/bottom-right
	mouse_pos = flip(round(hit.IntersectionPoint(1:2)));

	if app.ShowSuperpixelsCheckBox.Value
		%apply label to whole Superpixel
		chosen_SP_index = SP(mouse_pos(1), mouse_pos(2));

		%in the mask, set all of the pixels from this superpixel to button_ix
		if app.EraseButton.Value
			mask(SP == chosen_SP_index) = 0;
		else
			mask(SP == chosen_SP_index) = button_ix;
		end
	else
		%pixel-by-pixel labelling
		if app.EraseButton.Value
			mask(mouse_pos(1), mouse_pos(2)) = 0;
		else
			mask(mouse_pos(1), mouse_pos(2)) = button_ix;
		end
	end
	
	app.KleverImageLabellingToolKILTUIFigure.UserData.mask = mask;
	plot_image;
end
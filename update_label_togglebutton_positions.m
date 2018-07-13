function update_label_togglebutton_positions(app)

[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);
if n_buttons >= 1
	panel_pos = app.LabelsButtonGroup.InnerPosition;
	slider_pos = app.Slider.Position;
	bp = all_buttons(1).Position;
	button_w = slider_pos(1) * 0.875;
	button_h = bp(4);
	gap_x = bp(1);
	gap_y = button_h/5;

	togglebutton_panel_height = panel_pos(4);
	all_buttons_height = (button_h + gap_y)*n_buttons + gap_y*2;
	offset = (all_buttons_height - togglebutton_panel_height) * (100 - app.Slider.Value)/100;
	offset = max(0, offset);
	for ii=1:n_buttons
			y_pos = togglebutton_panel_height - (button_h + gap_y) * (n_buttons - ii + 1) + offset;
			all_buttons(ii).Position = [gap_x, y_pos, button_w, button_h];
	end
end
function button_ix = get_button_ix(all_buttons, selectedButton, n_buttons)

if nargin<3
	n_buttons = length(all_buttons);
end

%find index of selectedButton
for ii = 1:n_buttons
	if all_buttons(ii) == selectedButton
		button_ix = ii;
		break
	end
end
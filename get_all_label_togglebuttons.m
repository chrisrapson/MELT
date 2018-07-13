function [all_buttons, n_buttons] = get_all_label_togglebuttons(p)
%return all children that are uitogglebuttons
%INPUT:
% p   : parent (e.g. app.LabelsButtonGroup)

all_buttons = p.Children;
n_buttons = length(all_buttons);
for ii = n_buttons:-1:1
	if ~strcmp(all_buttons(ii).Type, 'uitogglebutton')
		all_buttons(ii) = [];
		n_buttons = n_buttons - 1;
	end
end
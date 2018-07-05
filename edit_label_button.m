function success = edit_label_button(app, selectedButton)
success = true;

all_buttons = app.LabelsButtonGroup.Children;
n_buttons = length(all_buttons);
button_ix = get_button_ix(all_buttons, selectedButton, n_buttons);

prompt = 'name your new label';
default_answer = {['label ',num2str(n_buttons)]};
answer_unique = 0;
while ~answer_unique
		answer = inputdlg(prompt, prompt, 1, default_answer);
		if isempty(answer)
				%user has pushed cancel
				success = false;
				return
		else
				%check the label hasn't been used before
				answer_unique = 1;
				for ii = 1:n_buttons
% 						disp(['checking answer{1}=',answer{1},' against button ',num2str(ii),' text=',all_buttons(ii).Text])
						if ii ~= button_ix ...
							 && strcmp(answer{1}, all_buttons(ii).Text)
								prompt = 'label already exists, please try again';
								answer_unique = 0;
								break
						end
				end
		end
end
selectedButton.Text = answer{1};


%choose a colour
colour_unique = 0;
prompt = 'choose a colour';
while ~colour_unique
		colour = uisetcolor(rand(1,3), prompt);
		if isempty(colour)
				%user has pushed cancel
				success = false;
				return
		else
				%check the colour hasn't been used before
				colour_unique = 1;
				for ii = 1:n_buttons
						if ii ~= button_ix ...
							 && all(colour == all_buttons(ii).BackgroundColor)
								prompt = 'colour already exists, please try again';
								colour_unique = 0;
								break
						end
				end
		end
end
selectedButton.BackgroundColor = colour;
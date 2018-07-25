%plots image 'I' into axes 'ax' and overlays a mask 'mask'

hold(ax, 'off')
cla(ax)

if strncmp(app.choice_of_algo.Value, 'Superpixels', 11)
	if app.ShowImageCheckBox.Value
		ih1 = imagesc(imoverlay(I, BM, 'cyan'), 'Parent', ax);
	else
		im_BM = zeros(size(BM));
		im_BM(~BM) = 1;
		im_BM(:,:,2) = ones(size(BM));
		im_BM(:,:,3) = ones(size(BM));
		ih1 = imagesc(im_BM, 'Parent', ax);
	end
else
	if app.ShowImageCheckBox.Value
		ih1 = imagesc(I, 'Parent', ax);
	else
		ih1 = imagesc(ones(size(I)), 'Parent', ax);
	end
end
axis(ax, 'ij')
title(ax, titleify(my_title))
ih1.ButtonDownFcn = {@im_ButtonDownFcn, app};

if ~isempty(mask) && app.ShowlabelledregionsCheckBox.Value
	%allow mask to be overplotted
	hold(ax,'all')

	mask_cmap = [1 1 1];
	[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);
	for ii=1:n_buttons
		mask_cmap = [mask_cmap; all_buttons(ii).BackgroundColor];
	end

	[ih2, patch2] = imagescnan(mask, 'Parent', ax);
	if n_buttons == 0
		set(ax, 'colormap', [mask_cmap; mask_cmap]);
		set(ax, 'clim', [0 1]);
	else
		set(ax, 'colormap', mask_cmap);
		set(ax, 'clim', [0 n_buttons]);
	end
	ih2.AlphaData = 0.25;
% 	patch2.FaceAlpha = 0.75;%125;

	ih2.ButtonDownFcn = {@im_ButtonDownFcn, app};
end

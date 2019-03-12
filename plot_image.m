%plots image 'I' into axes 'ax' and overlays a mask 'mask'

hold(ax, 'off')
cla(ax)
hold(ax,'all')

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
	mask_cmap = [1 1 1];
	[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);
	for ii=1:n_buttons
		mask_cmap = [mask_cmap; all_buttons(ii).BackgroundColor];
	end

	ih2 = imagesc(mask, 'Parent', ax);
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

	
if strcmp(app.choice_of_algo.Value, 'Polygon')
	p_i_p = app.MoreEfficientLabellingToolMELTUIFigure.UserData.polygon_in_progress;
	if ~isempty(p_i_p)
		plot(ax, p_i_p(:,2), p_i_p(:,1), 'co')
		plot(ax, p_i_p(:,2), p_i_p(:,1), 'c--')
		ph = plot(ax, p_i_p(1,2), p_i_p(1,1), 'mo');
		ph.ButtonDownFcn = {@im_ButtonDownFcn, app};
	end
end

%TODO: maybe no longer necessary after I added in "%reset zoom" to the main app code
%      including it makes the zoom reset every time you switch tools
% %make image fit to axes
% %can be disabled by setting tight_ax ~= 1
% if ~exist('tight_ax','var') || tight_ax==1
% 	axis(ax,'tight')
% end
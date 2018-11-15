function initialise_tracker(app)
%identify points within the masked area that can be used for tracking

%start by releasing existing trackers, and initialising everything to empty
for ii = size(app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker, 1):-1:1
	for kk = size(app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker, 2):-1:1
		if ~isempty(app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker{ii,kk})
			app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker{ii,kk}.release();
		end
	end
end
app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker = {};
app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker_points = {};
app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker_poky = {};

remember_bboxes_checkbox = app.BboxesonlyCheckBox.Value;
app.BboxesonlyCheckBox.Value = 0;
load_img_and_SPs; %load I and mask (turn off bboxes temporarily, otherwise this script only returns the zoomed in mask)
app.BboxesonlyCheckBox.Value = remember_bboxes_checkbox;
I_grayscale = uint8(mean(I,3));
[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);

%avoid annoying warning about polygon having duplicate & redundant vertices
warn_state = warning('query', 'MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:polyshape:repairedBySimplify')
for ii=1:n_buttons
	points = {};
	mask_ii = zeros(size(mask));
	mask_ii(mask == ii) = 1;
	if any(mask_ii(:))
% 		tmp = regionprops(tmp, 'BoundingBox', 'ConvexHull');
% 		my_polygon = tmp.ConvexHull;
% 		my_polygon = bwconvhull(tmp);
		CC = bwconncomp(mask_ii);
		RPs = regionprops(CC, 'BoundingBox', 'ConvexHull');
		
		for kk = 1:CC.NumObjects
			my_polygon = RPs(kk).ConvexHull;
			
			%if the polygon is too small, enlarge it
			min_polygon_area = 100; %pixels
			enlargement_factor = 4;
			if polyarea(my_polygon(:,1), my_polygon(:,2)) < min_polygon_area
				ps = polyshape(my_polygon(:,1), my_polygon(:,2));
				[cx,cy] = centroid(ps);
				for jj = size(my_polygon,1):-1:1
					rel_pos = my_polygon(jj,:) - [cx,cy]; %transform to [cx,cy] co-ordinate system
					rel_pos = round(rel_pos * enlargement_factor); %enlarge it
					enlarged_poly(jj,:) = rel_pos + [cx, cy];
				end
				enlarged_poly(enlarged_poly < 0) = 0;
				x_mm = minmax(enlarged_poly(:,1)');
				y_mm = minmax(enlarged_poly(:,2)');
				bbox = [x_mm(1) y_mm(1) (x_mm(2) - x_mm(1)) (y_mm(2) - y_mm(1))];
			else
				enlarged_poly = my_polygon;
				bbox = RPs(kk).BoundingBox;
			end
			bbox = [floor(bbox(1)) floor(bbox(2)) ceil(bbox(3)) ceil(bbox(4))];

			%crop image so that we only detect features near the object we are tracking
			croptoX = max(1, bbox(2) - round(bbox(4)/10)) : min(size(I,1), bbox(2) + round(bbox(4) * 11/10));
			croptoY = max(1, bbox(1) - round(bbox(3)/10)) : min(size(I,2), bbox(1) + round(bbox(3) * 11/10));
			cropped_I = I_grayscale(croptoX, croptoY);

			%detect features
			filterSize = round(log10(sqrt(polyarea(my_polygon(:,1), my_polygon(:,2))))) * 2 + 1; %smaller filter for smaller region
			filterSize = max(3, filterSize); %filter must be 3x3
			detectedFeatures = detectMinEigenFeatures(cropped_I, 'FilterSize', filterSize);
			points{kk} = detectedFeatures.Location;

			%only count points within the polygon (not within the bbox)
			%this might be different if the polygon is not rectangular
			for jj=size(points{kk},1):-1:1
				points{kk}(jj,:) = points{kk}(jj,:) + bbox(1:2);
				%DONE: should I use my_polygon or enlarged_poly for this?
				%      answer = enlarged_poly.
				[in, on] = inpolygon(points{kk}(jj,1), points{kk}(jj,2), enlarged_poly(:,1), enlarged_poly(:,2));
				if ~(in || on)
					points{kk}(jj,:) = [];
				end
			end

		end
	end

	if ~isempty(points)
		%save results
		for kk = 1:length(points)
			if isempty(points{kk})
				disp('empty points... that''s weird')
			else
				app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker{ii,kk} = vision.PointTracker('MaxBidirectionalError', 2);
				app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker{ii,kk}.initialize(points{kk}, I_grayscale);
				app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker_points{ii,kk} = points{kk};
				app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker_poly{ii,kk}   = RPs(kk).ConvexHull; %save the un-enlarged polygon
			end
		end
	else
		app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker_points{ii} = [];
		app.MoreEfficientLabellingToolMELTUIFigure.UserData.tracker_poly{ii}   = [];
	end
end

%set the warning state back how it was
warning(warn_state.state, 'MATLAB:polyshape:repairedBySimplify')
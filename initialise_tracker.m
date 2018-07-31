function initialise_tracker(app)
%identify points within the masked area that can be used for tracking

load_img_and_SPs; %load I and mask
I_grayscale = uint8(mean(I,3));
[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);

%avoid annoying warning about polygon having duplicate & redundant vertices
warn_state = warning('query', 'MATLAB:polyshape:repairedBySimplify');
warning('off', 'MATLAB:polyshape:repairedBySimplify')
for ii=1:n_buttons
	points = [];
	tmp = zeros(size(mask));
	tmp(mask == ii) = 1;
	if any(tmp(:))
		tmp = regionprops(tmp, 'BoundingBox', 'ConvexHull');
		my_polygon = tmp.ConvexHull;

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
			x_mm = minmax(enlarged_poly(:,1)');
			y_mm = minmax(enlarged_poly(:,2)');
			bbox = [x_mm(1) y_mm(1) (x_mm(2) - x_mm(1)) (y_mm(2) - y_mm(1))];
		else
			enlarged_poly = my_polygon;
			bbox = tmp.BoundingBox;
		end
		bbox = [floor(bbox(1)) floor(bbox(2)) ceil(bbox(3)) ceil(bbox(4))];

		%crop image so that we only detect features near the object we are tracking
		croptoX = max(1, bbox(2) - round(bbox(4)/10)) : min(size(I,1), bbox(2) + round(bbox(4) * 11/10));
		croptoY = max(1, bbox(1) - round(bbox(3)/10)) : min(size(I,2), bbox(1) + round(bbox(3) * 11/10));
		cropped_I = I_grayscale(croptoX, croptoY);

		%detect features
		filterSize = round(log10(sqrt(polyarea(my_polygon(:,1), my_polygon(:,2))))) * 2 + 1; %smaller filter for smaller region
		filterSize = max(3, filterSize); %filter must be 3x3
		points = detectMinEigenFeatures(cropped_I, 'FilterSize', filterSize);
		points = points.Location;

		%only count points within the polygon (not within the bbox)
		%this might be different if the polygon is not rectangular
		for jj=size(points,1):-1:1
			points(jj,:) = points(jj,:) + bbox(1:2);
			%DONE: should I use my_polygon or enlarged_poly for this?
			%      answer = enlarged_poly.
			[in, on] = inpolygon(points(jj,1), points(jj,2), enlarged_poly(:,1), enlarged_poly(:,2));
			if ~(in || on)
				points(jj,:) = [];
			end
		end

	end

	if ~isempty(points)
		%save results
		app.KleverImageLabellingToolKILTUIFigure.UserData.tracker_points{ii} = points;
		app.KleverImageLabellingToolKILTUIFigure.UserData.tracker_poly{ii}   = my_polygon; %save the un-enlarged polygon
		app.KleverImageLabellingToolKILTUIFigure.UserData.tracker{ii}.release();
		app.KleverImageLabellingToolKILTUIFigure.UserData.tracker{ii}.initialize(points, I_grayscale);
	else
		app.KleverImageLabellingToolKILTUIFigure.UserData.tracker_points{ii} = [];
		app.KleverImageLabellingToolKILTUIFigure.UserData.tracker_poly{ii}   = [];
	end
end

%set the warning state back how it was
warning(warn_state.state, 'MATLAB:polyshape:repairedBySimplify')
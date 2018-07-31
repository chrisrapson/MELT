function tracked_mask = track_mask(app)
min_points_for_tracking = 4;

load_img_and_SPs; %load I and mask
I_grayscale = uint8(mean(I,3));
[all_buttons, n_buttons] = get_all_label_togglebuttons(app.LabelsButtonGroup);
for ii=1:n_buttons
	% Track the points. Note that some points may be lost.

	%use the points from previous frame
	oldPoints = app.KleverImageLabellingToolKILTUIFigure.UserData.tracker_points{ii};
	
	if length(oldPoints) >= min_points_for_tracking
		[points, isFound] = step(app.KleverImageLabellingToolKILTUIFigure.UserData.tracker{ii}, I_grayscale);
		visiblePoints   = points(isFound,:);
		oldInliers = oldPoints(isFound,:);
		numPoints = size(visiblePoints, 1);

		if numPoints >= min_points_for_tracking
			% Estimate geometric transformation between old and new points, eliminating outliers.
			[tform, ~, ~, status] = estimateGeometricTransform(oldInliers, visiblePoints, 'Similarity', 'MaxDistance', 4);
			if status ~= 0
				disp('tracking failed.')
				continue;
			end

			% transform previous polygon to new polygon
			my_polygon =  transformPointsForward(tform, squeeze(app.KleverImageLabellingToolKILTUIFigure.UserData.tracker_poly{ii}));
			my_polygon = double(my_polygon);
			in = poly2mask(my_polygon(:,1), my_polygon(:,2), size(mask,1), size(mask,2));
			mask(in) = ii;
		end
	end
end

tracked_mask = mask;
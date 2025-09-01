clear; clc
obj = setupSystemObjects();
roiVideoPlayer = vision.VideoPlayer('Position', [1000, 400, 700, 400]);
particleVideoPlayer = vision.VideoPlayer('Position', [1400, 400, 700, 400]);

tracks = initializeTracks();
canvasHeight = 240;
canvasWidth = 320;
nextId = 1; 

F_update = [1 0 1 0; 0 1 0 1; 0 0 1 0; 0 0 0 1];

Npop_particles = 500;
Xstd_rgb = 0.2;
Xstd_pos = 10;
Xstd_vec = 5;

dist_func = @chi_square_statistics;
numBins = 32;

trackingActive = false;
particles = [];
rgbHist = [];
trackerLostCount = 0;
trackerLostThreshold = 10;







while true

    if ~trackingActive
        frame = snapshot(obj.reader);
        [centroids, bboxes, mask] = detectObjects(frame, obj);
        predictNewLocationsOfTracks(tracks);
        [assignments, unassignedTracks, unassignedDetections] = detectionToTrackAssignment(centroids, tracks);
        tracks = updateAssignedTracks(tracks, assignments, centroids, bboxes);
        tracks = updateUnassignedTracks(tracks, unassignedTracks);
        tracks = deleteLostTracks(tracks);
        [tracks, nextId] = createNewTracks(centroids, unassignedDetections, bboxes, nextId, tracks);
        displayTrackingResults(frame, mask, tracks, obj, nextId);

        for i = 1:length(tracks)
            if tracks(i).age >= 100
                oldTrack = tracks(i);
                bbox = oldTrack.bbox;
                x1 = double(max(1, round(bbox(1))));
                y1 = double(max(1, round(bbox(2))));
                x2 = double(min(size(frame, 2), x1 + round(bbox(3)) - 1));
                y2 = double(min(size(frame, 1), y1 + round(bbox(4)) - 1));
                
                roi = frame(y1:y2, x1:x2, :);
                canvas = uint8(zeros(canvasHeight, canvasWidth, 3));
                roiDisp = imresize(roi, [min(canvasHeight, size(roi,1)), min(canvasWidth, size(roi,2))]);
                [h, w, ~] = size(roiDisp);
                x_offset = floor((canvasWidth - w)/2) + 1;
                y_offset = floor((canvasHeight - h)/2) + 1;
                canvas(y_offset:y_offset+h-1, x_offset:x_offset+w-1, :) = roiDisp;
                roiVideoPlayer.step(canvas);

                rHist = imhist(roi(:,:,1), numBins);
                gHist = imhist(roi(:,:,2), numBins);
                bHist = imhist(roi(:,:,3), numBins);
                rgbHist = [rHist; gHist; bHist] / sum([rHist; gHist; bHist]);

                Npix_resolution = [size(roi, 1), size(roi, 2), x1, y1];
                particles = create_particles(Npix_resolution, Npop_particles);
                trackingActive = true;
                break;
            end
        end
    else
        tic
        frame = snapshot(obj.reader);
        particlesFrame = frame;
        D = zeros(1, size(particles, 2));
        for i = 1:size(particles, 2)
                        y = round(particles(1, i));
            x = round(particles(2, i));
            patchSizeX = round((x2-x1)/2);
            patchSizeY = round((y2-y1)/2);
            yp1 = max(1, y - patchSizeY);
            yp2 = min(size(frame,1), y + patchSizeY);
            xp1 = max(1, x - patchSizeX);
            xp2 = min(size(frame,2), x + patchSizeX);
            
            patch = frame(yp1:yp2, xp1:xp2, :);
            
            rHistP = imhist(patch(:, :, 1), numBins); 
            gHistP = imhist(patch(:, :, 2), numBins);
            bHistP = imhist(patch(:, :, 3), numBins); 

            rHistP = rHistP / sum(rHistP);
            gHistP = gHistP / sum(gHistP);
            bHistP = bHistP / sum(bHistP);
            HistP = [rHistP; gHistP; bHistP];
            D(i)=pdist2(rgbHist',HistP',dist_func);
            %D(i)=pdist2(rgbHist',HistP','euclidean')^2;
        end
        particles = update_particles(F_update, Xstd_pos, Xstd_vec, particles);
        L = calc_log_likelihood(Xstd_rgb, D, particles(1:2, :), frame);
        particles = resample_particles(particles, L);
        particles(1, :) = min(max(particles(1, :), 1), size(frame, 1));
        particles(2, :) = min(max(particles(2, :), 1), size(frame, 2));
        Xmean = round(mean(particles(2, :)));
        Ymean = round(mean(particles(1, :)));
        [~, bestIdx] = max(L);
        Xbest = particles(2, bestIdx);
        Ybest = particles(1, bestIdx);

        if max(L) < log(1e-3)
            trackerLostCount = trackerLostCount + 1;
        else
            trackerLostCount = 0;
        end
        if trackerLostCount > trackerLostThreshold
            trackingActive = false;
            trackerLostCount = 0;
            tracks = initializeTracks();
            nextId = 1;
        end

        for i = 1:size(particles, 2)
            particlePositionX = round(particles(2, i)); 
            particlePositionY = round(particles(1, i));
            if particlePositionX > 0 && particlePositionX <= size(particlesFrame, 2) && particlePositionY > 0 && particlePositionY <= size(particlesFrame, 1)
                particlesFrame(particlePositionY, particlePositionX, :) = [255, 0, 0]; 
            end
        end

        for i = 1:20
            for j = 1:20
                currentX = Xmean-10+i;
                currentY = Ymean-10+j;
                if currentX > 0 && currentX <= size(particlesFrame, 2) && currentY > 0 && currentY <= size(particlesFrame, 1)
                    particlesFrame(currentY, currentX, :) = [255, 0, 0];
                end
            end
        end



        particleVideoPlayer.step(particlesFrame);
    end
end
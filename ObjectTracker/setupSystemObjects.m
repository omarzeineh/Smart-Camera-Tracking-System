function obj = setupSystemObjects()
    % Initialize Video I/O from webcam and analysis components

    % Create a webcam object as the video source
    camList = webcamlist;  % List available webcams
    obj.reader = webcam(1, 'Resolution', '640x360');  % Or specify camera name: webcam('Logitech')
    

    % Create two video players
    obj.maskPlayer = vision.VideoPlayer('Position', [740, 400, 700, 400]);
    obj.videoPlayer = vision.VideoPlayer('Position', [20, 400, 700, 400]);

    % Foreground detector for background subtraction
    obj.detector = vision.ForegroundDetector('NumGaussians', 3, ...
        'NumTrainingFrames', 40, 'MinimumBackgroundRatio', 0.7);

    % Blob analysis to find connected components
    obj.blobAnalyser = vision.BlobAnalysis('BoundingBoxOutputPort', true, ...
        'AreaOutputPort', true, 'CentroidOutputPort', true, ...
        'MinimumBlobArea', 400);
end
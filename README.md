# Smart Camera Tracking with Particle Filter and PID Control

This project implements a **smart camera tracking system** in MATLAB, capable of detecting, tracking, and following a moving object in real-time. The system combines **motion-based detection**, **Kalman filters**, **particle filtering**, and **PID-controlled servo motors** via Arduino to keep the target centered in view.

## Overview

- **Tracks moving objects in video** using background subtraction and blob analysis.  
- **Maintains identity** across frames with Kalman filters.  
- **Switches to particle filtering** with histogram similarity for robust tracking, even when the camera itself moves.  
- **Controls servo motors** (pan/tilt) through Arduino using a PID feedback loop.  
- **Provides visual feedback** with ROI display and overlayed particle positions.  

This work extends and integrates existing MATLAB examples and demos into a full **real-time vision + hardware system**.

## Sources and References

- Particle filter base code inspired by: [Simple Particle Filter Demo](https://www.mathworks.com/matlabcentral/fileexchange/33666-simple-particle-filter-demo)  
  - **Modifications:** Reworked initialization (`create_particles` only around ROI), stabilized likelihood function, improved resampling with `cumsum` approach, and added histogram normalization.

- Motion-based multi-object tracking adapted from: [Motion-Based Multiple Object Tracking](https://www.mathworks.com/help/vision/ug/motion-based-multiple-object-tracking.html)  
  - **Modifications:** Added function arguments for flexibility, fine-tuned morphological operations (`imopen`, `imclose`, `imfill`), adjusted Kalman filter thresholds, and enhanced track management logic.

- Histogram comparison methods from: [Histogram Distances](https://www.mathworks.com/matlabcentral/fileexchange/39275-histogram-distances)  
  - Used for robust color histogram similarity (chi-square distance).

## Key Features

- **Detection Phase:**  
  - Foreground detection with Gaussian Mixture Models.  
  - Noise removal with tuned morphological operators.  
  - Custom filtering of blobs by minimum area.  

- **Tracking Phase:**  
  - Multi-object tracking using Kalman filters.  
  - Transition to particle filter once track is reliable.  
  - Histogram-based likelihood evaluation with resampling.

- **Camera Control:**  
  - PID controller computes error between object center and frame center.  
  - Arduino writes servo positions (`writePosition`) with safety clamping.  
  - Supports ±90° pan and ±30° tilt.  

- **System Robustness:**  
  - Automatic reinitialization when tracking confidence drops.  
  - ROI visualization before filter lock-in.  
  - Dual video players for debugging and demonstration.  

## Hardware Setup

- **Webcam** for video input.  
- **Arduino Uno** with two servo motors on a pan-tilt rig.  
- **MATLAB Arduino Support Package** for servo control.  
- Manual calibration of servo limits to avoid mechanical stress.  

## Testing

- **Motion Detection:** Successful bounding box detection in static backgrounds.  
- **Particle Filtering:** Maintained tracking accuracy during camera movement.  
- **PID Control:** Smooth servo adjustments keeping subject centered.  
- **Full Integration:** Reliable end-to-end performance with minor jitter under fast motion.  



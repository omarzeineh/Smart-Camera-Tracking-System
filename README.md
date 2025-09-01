# Smart Camera Tracking System

This repository contains MATLAB implementations for a **Smart Camera Tracking System** that combines **motion detection**, **object tracking**, and **particle filtering** with hardware control via **Arduino and servo motors**. The system is designed to detect, track, and follow a moving target in real-time using computer vision and control algorithms.

---

## 📖 Overview
This project integrates **motion-based tracking**, **Kalman filters**, and **particle filters** to build a robust smart camera system. The software runs in MATLAB, processes live video input from a webcam, and uses a **PID controller** to control Arduino-connected servo motors. The system ensures that the camera automatically follows moving targets and keeps them centered in the frame.  

### Key Features
- Motion detection with background subtraction  
- Kalman filter for multi-object tracking  
- Particle filter with histogram-based likelihood for robust tracking during camera motion  
- PID-based camera control with servo motors  
- Real-time visualization with bounding boxes, ROI display, and particle overlays  

---

## 📂 Repository Contents
- **`particles/`**  
  Contains files related to the **particle filter** implementation.  
  Based on [Simple Particle Filter Demo](https://www.mathworks.com/matlabcentral/fileexchange/33666-simple-particle-filter-demo), but with major modifications:
  - Particle initialization constrained to object ROI for faster convergence  
  - Numerical stability improvements in log-likelihood calculations  
  - Updated resampling method using cumulative sums for robustness  

- **`tracks/`**  
  Contains files for the **object tracking system**.  
  Adapted from [Motion-Based Multiple Object Tracking](https://www.mathworks.com/help/vision/ug/motion-based-multiple-object-tracking.html) with changes:
  - Added support for custom function arguments  
  - Tuned morphological operations for noise removal  
  - Adjusted Kalman filter thresholds for stability  

- **`histogram-distances/`**  
  Includes distance functions from [Histogram Distances](https://www.mathworks.com/matlabcentral/fileexchange/39275-histogram-distances) for computing similarity measures between color histograms (e.g., Chi-square).  

---

## ⚙️ System Design
The tracking system consists of three major stages:
1. **Detection** – Foreground detection using Gaussian Mixture Models and blob analysis  
2. **Tracking** – Transition from Kalman filter multi-object tracking to a single-object **particle filter**  
3. **Control** – A PID controller computes positional error and drives servo motors via Arduino to center the object  

Fail-safe mechanisms ensure reinitialization if tracking confidence drops, making the system robust against occlusion and sudden movement.

---

## 🧪 Experimental Results
Four main tests were conducted:
1. **Motion Detection in Static Background** – Accurate detection of moving persons  
2. **Particle Filter Tracking with Camera Motion** – Reliable tracking during manual camera movement  
3. **PID Camera Adjustment** – Smooth and responsive servo motion with tuned PID gains  
4. **Full System Integration** – Combined detection, tracking, and control, achieving real-time tracking with minor lag during abrupt movement  

All tests passed with acceptable accuracy and stability.  

---

## 🔗 References
- [Simple Particle Filter Demo](https://www.mathworks.com/matlabcentral/fileexchange/33666-simple-particle-filter-demo)  
- [Motion-Based Multiple Object Tracking](https://www.mathworks.com/help/vision/ug/motion-based-multiple-object-tracking.html)  
- [Histogram Distances](https://www.mathworks.com/matlabcentral/fileexchange/39275-histogram-distances)  

---

## 🚀 Future Work
- Integrate deep learning-based object detection for improved robustness  
- Add automatic re-calibration for recovery during occlusion  
- Explore depth cameras for higher tracking accuracy  
- Optimize PID tuning for smoother servo responses  

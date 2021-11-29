# 3d scanner under $40
This project proposes a 3d scanner for distances of up to roughly 10 meters. The scanner uses a smartphone and a line laser module to create colored point clouds. This repository contains hardware and software files.
<br>

The left  image shows the scanner mounted on a tripod and the right image shows the corresponding video frame captured by the smartphone. The horizontal disparity shift of the laser line visible in the video frame is related to the depth of the scene points.

<table style="width:100%; margin:0 auto; border: 0px;">
    <tr>
      <th>setup</th>
      <th>video frame</th> 
    </tr>
    <tr>
      <td><img src="https://github.com/albrecht-lindner/3d_scanner/blob/master/photos/setup.jpg" width="250"></td>
      <td><img src="https://github.com/albrecht-lindner/3d_scanner/blob/master/photos/frame.jpg" width="250"> </td> 
    </tr>
</table>
<br>

A video has to be recorded while the scanner rotates 360 degrees around the tripod axis (which coincides with the smartphone camera's optical center). The image below shows 10 key frames of a 360 degree video sequence of an entire room.
<img src="https://github.com/albrecht-lindner/3d_scanner/blob/master/data/stitch.jpg" width="100%">
<br>

The recorded video can then be converted into a full color 3d point cloud.
<img src="https://github.com/albrecht-lindner/3d_scanner/blob/master/output/anim3d.gif" width="100%">

# Usage
## Run the example video from this repository
- Unzip the video file in the ./data folder
- Run ./software/computePointCloud.m
## Build your own scanner
If you have an iPhone 7 you can use the device holder from the ./hardware folder. If you have another phone you need to design your own holder; make sure the optical center of the camera lies on the rotation axis of the platform, this is crucial.

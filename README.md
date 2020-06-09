# 3d_scanner
This project proposes a 3d scanner under $40. The scanner uses a smartphone and a line laser module to create colored point clouds for distances up to 10m.

The left  image shows the scanner mounted on a tripod and the right image shows the corresponding video frame captured by the smartphone. The horizontal disparity shift of the laser line in the frame is related to the depth of the scene points.
<table style="width:100%">
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
A video has to be recorded while the scanner rotates 360 degrees around the tripod axis (which coincides with the smartphone camera's optical center). The recorded video can be converted into a full color 3d point cloud:
<img src="https://github.com/albrecht-lindner/3d_scanner/blob/master/output/anim3d.gif" width="100%">

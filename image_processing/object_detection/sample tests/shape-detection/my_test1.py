import numpy as np
import cv2

## Image reading
frame = cv2.imread('testop.jpg')


## Image resizing logic
r = 400.0 / frame.shape[1]
dim = (400, int(frame.shape[0] * r))
frame = cv2.resize(frame, dim, interpolation = cv2.INTER_AREA)

# area calculation
height, width, channels = frame.shape
frameArea = height*width 
minReqArea = frameArea/20
#print height, width ,frameArea
### smoothing the noise

frame=cv2.GaussianBlur(frame, (5,5),0)

# convert the image to grayscale for processing
imgray = cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)

ret,thresh = cv2.threshold(imgray,127,255,0)

## finding contours
contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

## drawing contours over original image
#img = cv2.drawContours(img, contours[3], -1, (255,255,0), 3)
min_area = minReqArea
largest_contour = None

for idx, contour in enumerate(contours):
	area = cv2.contourArea(contour)
	if area > min_area:
		#print area of contour
		#print area
		largest_contour = contour
		if not largest_contour == None:
			#moment = cv2.moments(largest_contour)
			#if moment["m00"]> 200 :
			

			cv2.drawContours(frame, contour, -1, (200,200,0), 3)

## printing no of contours present in the image
print len(contours)

# displating final image
cv2.imshow('image',frame)
cv2.waitKey(0)
cv2.destroyAllWindows()
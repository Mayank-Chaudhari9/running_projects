import numpy as np
import cv2

## Image reading
frame = cv2.imread('testoo.jpg')

## Image resizing logic
r = 400.0 / frame.shape[1]
dim = (400, int(frame.shape[0] * r))
frame = cv2.resize(frame, dim, interpolation = cv2.INTER_AREA)

### smoothing the noise
frame=cv2.GaussianBlur(frame, (5,5),0)

# convert the image to grayscale for processing
imgray = cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)

ret,thresh = cv2.threshold(imgray,127,255,0)

## finding contours
contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

## drawing contours over original image
#img = cv2.drawContours(img, contours[3], -1, (255,255,0), 3)
cv2.drawContours(frame, contours, -1, (200,200,0), 3)

## printing no of contours present in the image
print len(contours)

# displating final image
cv2.imshow('image',frame)
cv2.waitKey(0)
cv2.destroyAllWindows()


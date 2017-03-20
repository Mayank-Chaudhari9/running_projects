import numpy as np
import cv2

frame = cv2.imread('test6.jpg')
#img=cv2.GaussianBlur(frame, (5,5),0)

imgray = cv2.cvtColor(frame,cv2.COLOR_BGR2GRAY)
ret,thresh = cv2.threshold(imgray,127,255,0)
contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

#img = cv2.drawContours(img, contours[3], -1, (255,255,0), 3)
cv2.drawContours(frame, contours, -1, (200,200,0), 3)
print len(contours)

cv2.imshow('image',frame)
cv2.waitKey(0)
cv2.destroyAllWindows()


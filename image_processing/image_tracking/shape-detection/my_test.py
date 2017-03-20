import numpy as np
import cv2

frame = cv2.imread('last.jpg')
img=cv2.GaussianBlur(frame, (5,5),0)

imgray = cv2.cvtColor(img,cv2.COLOR_BGR2GRAY)
ret,thresh = cv2.threshold(imgray,127,255,0)
contours, hierarchy = cv2.findContours(thresh,cv2.RETR_TREE,cv2.CHAIN_APPROX_SIMPLE)

img = cv2.drawContours(img, contours, -1, (255,255,0), 3)
print img
cv2.imshow('image',imgray)
cv2.waitKey(0)
cv2.destroyAllWindows()


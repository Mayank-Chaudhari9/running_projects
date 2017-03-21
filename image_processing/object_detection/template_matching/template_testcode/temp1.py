import cv2
import numpy as np

image = cv2.imread('im1.jpg')
template = cv2.imread("mark.jpg",0)

image2 = image.copy()
#cv2.imshow("test image", image)
#cv2.waitKey(0)
image_gray = cv2.cvtColor(image , cv2.COLOR_BGR2GRAY)

template = cv2.imread("mark.jpg",0)
#print image
cv2.imshow("testimage", image)

cv2.imshow("template" , image_gray)

w, h =template.shape[::-1]

result = cv2.matchTemplate(image_gray, template, cv2.TM_CCOEFF_NORMED)
threshold = 0.8

loc = np.where( result >= threshold)

for pt in zip(*loc[::-1]):
    cv2.rectangle(image, pt, (pt[0] + w, pt[1] + h), (0,255,255), 2)

#cv2.imshow('Detected',image)




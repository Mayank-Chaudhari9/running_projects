import cv2

import numpy as np


image = cv2.imread('im4.jpg')
template = cv2.imread('mark.jpg',0)

r = 400.0 / image.shape[1]

#print r
dim = (400, int(image.shape[0] * r))
#print dim
image = cv2.resize(image, dim, interpolation = cv2.INTER_AREA)
template_dim = (template.shape[1] * r , template.shape[0] * r)
#print template_dim
template = cv2.resize(template, dim, interpolation=cv2.INTER_AREA)

image_gray = cv2.cvtColor(image , cv2.COLOR_BGR2GRAY)

w, h =template.shape[::-1]

result = cv2.matchTemplate(image_gray, template, cv2.TM_CCOEFF_NORMED)
threshold = 0.1

loc = np.where( result >= threshold)

for pt in zip(*loc[::-1]):
    print 'i am in'
    cv2.rectangle(image, pt, (pt[0] + w, pt[1] + h), (0,255,255), 2)



cv2.imshow('Detected',image)
cv2.waitKey(0)

cv2.imshow('Detected',template)
cv2.waitKey(0)


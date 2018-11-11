from datetime import datetime as dt
import numpy as np
import cv2

def test(name, frame):
	print 'hello test'
	cv2.imwrite('./images/'+name+'.jpg',frame)

def templet(name, frame, template):
	#img_rgb = cv2.imread('im1.jpg')
	img_gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
	#template = cv2.imread('mark1.jpg',0)

	w, h = template.shape[::-1]

	res = cv2.matchTemplate(img_gray,template,cv2.TM_CCOEFF_NORMED)
	threshold = 0.7

	loc = np.where( res >= threshold)

	for pt in zip(*loc[::-1]):
	    cv2.rectangle(frame, pt, (pt[0] + w, pt[1] + h), (0,0,255), 2)


	cv2.imwrite('./images/'+name+'.jpg',frame)
	

capture = cv2.VideoCapture("v2.mp4")
template = cv2.imread('mark3.jpg',0)

while(capture.isOpened()):
	ret, frame = capture.read()
	
	#gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

	cv2.imshow('frame' , frame)
	name = str(dt.now())
	print name 
	templet(name, frame, template)
	#cv2.imwrite('./images/'+name+'.png',frame)

	
	if cv2.waitKey(1) & 0xFF == ord('q'):
		break


capture.release()
cv2.destroyAllWindows()




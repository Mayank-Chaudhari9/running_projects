from datetime import datetime as dt
import numpy as np
import cv2

def test(name, frame):
	print 'hello test'
	cv2.imwrite('./images/'+name+'.jpg',frame)
	

capture = cv2.VideoCapture("v1.mp4")

while(capture.isOpened()):
	ret, frame = capture.read()
	
	#gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)

	cv2.imshow('frame' , frame)
	name = str(dt.now())
	print name 
	test(name, frame)
	#cv2.imwrite('./images/'+name+'.png',frame)

	
	if cv2.waitKey(1) & 0xFF == ord('q'):
		break


capture.release()
cv2.destroyAllWindows()




import numpy as np
import cv2


capture = cv2.VideoCapture(0)
winName = "Test Capture"
cv2.namedWindow(winName, cv2.CV_WINDOW_AUTOSIZE)

while(True):

	# Capture frame-by-frame

	#defining operation on  for converting to grayscale

	#gray = cv2.cvtColor(capture.read()[1], cv2.COLOR_RGB2GRAY)
	
	# for capturing coloured video
	
	ret, gray = capture.read()

	#Display the resulting frame

	cv2.imshow(winName, gray)
	if cv2.waitKey(1) & 0xFF == ord('q'):
		break

capture.release()
cv2.destroyAllWindows()
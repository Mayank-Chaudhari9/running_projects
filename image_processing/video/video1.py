import numpy as np
import cv2


capture = cv2.VideoCapture(0)

while(True):

	# Capture frame-by-frame

	ret, frame = capture.read()

	#defining operation on frame

	grayscale = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)


	#Display the resulting frame

	cv2.imshow('frame', grayscale)
	if cv2.waitKey(1) & 0xFF == ord('q'):
		break

capture.release()
cv2.destroyAllWindows()
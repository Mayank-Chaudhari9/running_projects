import sys

#sys.path.insert(0,'/home/devil/Desktop/UntitledFolder/running_projects/pest_detection/pestsite')
sys.path.insert(0,'/home/devil/tensorflow/tf_files')

import label_fun

def hello():
	print "all this work is waste oooh lalalallaaaaa"
	y=" script integration successful"
	labels = "/home/devil/tensorflow/tf_files/retrained_labels.txt"
	graph = "/home/devil/tensorflow/tf_files/retrained_graph.pb"
	image = "/home/devil/tensorflow/tf_files/testing_images/betal/test1.jpg"


	return y + " " + label_fun.label(labels, image, graph)

hello()
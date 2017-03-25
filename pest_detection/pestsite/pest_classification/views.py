from django.shortcuts import render
from django.http import Http404
from django.http import HttpResponse
from django.template import loader
from pest_classification.forms import LoginForm

from django.conf import settings
from django.core.files.storage import FileSystemStorage

import requests
import json


# Create your views here.



## -------------------------------------------------- Web page Handeling logic ----------------------
def index(request):
	return HttpResponse("Hello from django . You are at home page.")

def test(request):
	return render(request, 'pest_classification/index.html',)

#-------Profile page handeling logic ------------------------- 
def profile(request):
    parsedData = []
    if request.method == 'POST':
        username = request.POST.get('user')
        req = requests.get('https://api.github.com/users/' + username)
        jsonList = []
        jsonList.append(json.loads(req.content))
        userData = {}
        for data in jsonList:
            userData['name'] = data['name']
            userData['blog'] = data['blog']
            userData['email'] = data['email']
            userData['public_gists'] = data['public_gists']
            userData['public_repos'] = data['public_repos']
            userData['avatar_url'] = data['avatar_url']
            userData['followers'] = data['followers']
            userData['following'] = data['following']
        parsedData.append(userData)
    #return HttpResponse(parsedData)
    return render(request, 'pest_classification/profile.html',{'data': parsedData})

def pest_capture(request):
	return render(request, 'pest_classification/pest_capture.html')
	


def pest_detector(request):
	return render(request, 'pest_classification/pest_detector.html')

def login(request):
	return render(request, 'pest_classification/login.html')
	
##------------------------------------ Form handeling --------------------------------------------
		## problem with this code
def login_process(request):
	username ="not logged in"

	if request.method== "POST":
		MyLoginForm = LoginForm(request.POST)

		if MyLoginForm.is_valid():
			username = MyLoginForm.cleaned_data['username']
		username = request.POST.get('username',"")
	else:
		MyLoginForm = LoginForm()
	return render(request,'pest_classification/loggedin.html', {"username":username})

	##-------------- file upload ---------

def simple_upload(request):
    if request.method == 'POST' and request.FILES['myfile']:
        myfile = request.FILES['myfile']
        fs = FileSystemStorage()
        filename = fs.save(myfile.name, myfile)
        uploaded_file_url = fs.url(filename)
        return render(request, 'pest_classification/simple_upload.html', {
            'uploaded_file_url': uploaded_file_url
        })
    return render(request, 'pest_classification/simple_upload.html')


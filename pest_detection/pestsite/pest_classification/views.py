from django.shortcuts import render
from django.http import Http404
from django.http import HttpResponse
from django.template import loader

import requests
import json

# Create your views here.

def index(request):
	return HttpResponse("Hello from django . You are at home page.")

def test(request):
	return render(request, 'pest_classification/index.html',)

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
	
#def google(request):
	#return redirect('http://google.com')
	#return HttpResponseRedirect('https://google.com')

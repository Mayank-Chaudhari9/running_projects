from django.shortcuts import render

from django.http import HttpResponse

import requests
import json

# Create your views here.

def index(request):
	return HttpResponse("Hello from django . You are at home page.")

def test(request):
	return HttpResponse("Second Page")

def profile(request):
    jsonList = []
    req = requests.get('https://api.github.com/users/Mayank-Chaudhari9')
    jsonList.append(json.loads(req.content))
    parsedData = []
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
    return HttpResponse(parsedData)
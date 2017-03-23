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
    req = requests.get('https://api.github.com/users/Mayank-Chaudhari9')
    content = req.text
    return HttpResponse(content)
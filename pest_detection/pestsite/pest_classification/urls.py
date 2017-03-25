from django.conf.urls import url
from django.views.generic import TemplateView

from . import views

urlpatterns =[
		
		url(r'^$',views.index, name='index'),
		url(r'^test/$',views.test, name='test'),
		url(r'^profile/$', views.profile, name='profile'),
		url(r'^pest_capture/$', views.pest_capture, name='pest_capture'),
		url(r'^pest_detector/$', views.pest_detector, name='pest_detector'),
		
		url(r'^login/$', views.login, name = 'login'),
   		url(r'^login_process/$', views.login_process, name = 'loggedin'),
   		url(r'^simple_upload/$', views.simple_upload, name = 'simple_upload'),
   		url(r'^pest_detection/$', views.pest_detection, name = 'pest_detection'),


	]
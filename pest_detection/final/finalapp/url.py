from django.conf.ulrs import url


from finalapp import views


urlpatterns=  
[
	url(r'^$', views.index, name='index'),

]


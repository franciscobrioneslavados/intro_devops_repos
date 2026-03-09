from django.shortcuts import render
from django.http import HttpResponse


# Create view with Httpresponse.
def home(request):
    return HttpResponse("Hola desde Django y Docker/Podman!")


# Create  views with render
def index(request):
    return render(request, "index.html")

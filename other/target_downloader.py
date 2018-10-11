# from __future__ import print_function
import urllib.request
from bs4 import BeautifulSoup
import requests
import shutil
import os
import re

'''
latest problem reports
current version of this script is pretty decent but 
realvnc mac download link - ".com/... reavnc/macos" < bad
teamviewer : "mac-os" < bad
veracrypt: "mac" <which is the good one
can work around this or nah? lets see later!
'''
DEBUG=1

#OS="mac"
OS="linux"
#OS="windows"

## todo
#architecture=64
#architecture=86

OS_formats={
	"mac":"dmg",
	"linux":("tar.bz2","tar.gz","deb","rpm",),
	"windows":"exe",
}

# download pages of the following applications which I wanna download!
urls={
	"sublime-text-3":"https://www.sublimetext.com/3",
	"octave": "",
	"realvnc-viewer":"https://www.realvnc.com/en/connect/download/viewer/"+OS.lower(),
	"teamviewer":"https://www.teamviewer.com/en/download/"+OS.lower(),
	"veracrypt":"https://www.veracrypt.fr/en/Downloads.html",
	"pycharm-community":"https://www.jetbrains.com/pycharm/download/download-thanks.html?platform="+OS.lower()+"&code=PCC",
	"pycharm-edu":"https://www.jetbrains.com/pycharm-edu/download/download-thanks.html?platform="+OS.lower()

## rexdl links do not work :()
#	"nova-prime":"http://rexdlfile.com/index.php?id=nova-launcher-prime-apk-download",
}

## check for these URLS as download links, to satisfy the download condition
dl_urls={
	"sublime-text-3":"download.sublimetext.com",
	"octave":"",
	"realvnc-viewer":"/download/file/viewer.files",
	"teamviewer":"download.teamviewer.com",
	"veracrypt":"launchpad.net",
	"pycharm-community":"data.services.jetbrains.com/products/download?code=PCP",
	"pycharm-edu":"data.services.jetbrains.com/products/download?code=PCE"
}

# conditions are priority wise - First checks for the first tuple, and so on!
# Modify x64 to x86 if you are on an i386/32 bit system,
# comparisons in the algorithm below are case insensitive so feel free
# but avoid any typing mistakes!
dl_conditions={
	"sublime-text-3":(OS_formats[OS.lower()],"x64",),
	"octave":"",
	"realvnc-viewer":(OS_formats[OS.lower()],"x64"),
	"teamviewer":(OS_formats[OS.lower()],"86",),
	"veracrypt":"", # add  x86 here if you want for old CPU
	"pycharm-community":(),
	"pycharm-edu":(),
}

#Get filename from content-disposition
def get_filename_from_cd(cd):
	if not cd:
		return None
	fname = re.findall('filename=(.+)', cd)
	if len(fname) == 0:
		return None
	return fname[0]

#Get filename from hyperlink
def get_filename_from_url(url):
	return url.split("/")[-1]

#validator from stackoverflow which was from django
def validate_url(url=None):
	if not url:
		return -1
	
	regex = re.compile(
		r'^(?:http|ftp)s?://' # http:// or https://
		r'(?:(?:[A-Z0-9](?:[A-Z0-9-]{0,61}[A-Z0-9])?\.)+(?:[A-Z]{2,6}\.?|[A-Z0-9-]{2,}\.?)|' #domain...
		r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3})' # ...or ip
		r'(?::\d+)?' # optional port
		r'(?:/?|[/?]\S+)$', re.IGNORECASE)
	if re.match(regex, url):
		return 0
	else:
		if url[0]=="/" and url[1]=="/":
			return 2
		return -1

# Download file from URL into file_name
def downloadFile(url=None,file_name=None,parent_site=None):
	if file_name == None:
		print("File name not passed, not downloading")
	elif isinstance(file_name,str):
		print(url)
		keepo=validate_url(url)
		if keepo < 0:
			print("URL cannot be validated, needs parent site!")
			url=parent_site+url
			print(url)
		elif keepo == 2:
			url="https:"+url
			print(url)
	with urllib.request.urlopen(url) as response, open(file_name, 'wb') as out_file:
		shutil.copyfileobj(response, out_file)

def DownloadTargetApp(TargetApp=None,allow_redirects=None):
	if not TargetApp:
		print("No target app passed!")
		return 1
	try:
		urls[TargetApp]
		dl_urls[TargetApp]
		dl_conditions[TargetApp]
	except KeyError as e:
		print("Target Application passed is not supported or has missing Download URLs/Conditions!",TargetApp)
		return 1

	url=urls[TargetApp]
	
	r = requests.get(url,headers = {'User-agent': 'mozilla-firefox'},allow_redirects = allow_redirects)
	site=r.url

	website=site.split("://")[0]+"://"+site.split("://")[1].split("/")[0]
	if DEBUG==1:
		print(website)
	# for debugging purposes lul
#	input(website)
	
	## begin algorithm
	soup = BeautifulSoup(r.text,'html.parser')
	print("Looking for conditions to satisfy: ",dl_conditions[TargetApp])
	Found_DL_URL=False
	for link in soup.findAll('a'):
		Failed=False
		dl_url=str(link.get('href'))
		
		if DEBUG==1:
			print(dl_url)
		if dl_url.lower().find(dl_urls[TargetApp].lower()) >= 0:
			Found_DL_URL=True
			for Z in dl_conditions[TargetApp]:
				if isinstance(Z,tuple):
					for X in Z:
						if dl_url.lower().find(X.lower()) > 0:
							Failed=False
							break
						else:
							pass
				else:
					if dl_url.lower().find(Z.lower()) < 0:
						# means the condition was not found in the download URL
						#print("Condition not satisfied!: "+Z+" > Cannot download from "+dl_url)
						Failed=True
						break
					else:
						pass
	
			if not Failed:
				print("Found a download link:"+dl_url)
				file_name=get_filename_from_url(dl_url)
				print("Download file name: "+file_name)
				choice=input("Would you like to download this link? (Enter or y/Y to continue, n/N to exit, or anything else to see the next link: ").lower()
				if choice == "y" or choice=="":
					if os.path.isfile(file_name):
						print("Output file already exists!")
						return 4
					else:
						print("Downloading!")
						if TargetApp=="pycharm-community" or TargetApp=="pycharm-edu":
							downloadFile(dl_url+"&platform="+OS.lower(),file_name,website)
						else:
							downloadFile(dl_url,file_name,website)
						return 0
				elif choice=="n":
					print("Finished scanning links for "+TargetApp)
					return 5

	if not Found_DL_URL:
		print("The download link "+dl_urls[TargetApp]+" was not found in the URLs on the page "+urls[TargetApp]);
		return 3

def __test__(target=None,allow_redirects=None):
	if not target:
		print("o come on")
		return -1

	print(DownloadTargetApp(target,allow_redirects))
	return 0

#__test__("octave") # not implemented
#__test__("sublime-text-3") # works
__test__("realvnc-viewer") # works
#__test__("teamviewer") # works
#__test__("veracrypt")
#__test__("pycharm-community") # works
#__test__("pycharm-edu") # works
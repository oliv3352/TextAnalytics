#! /usr/bin/python

from urllib import urlopen
from BeautifulSoup import BeautifulSoup
import re

# Copy all of the content from the provided web page
webpage = urlopen('http://obamaspeeches.com').read()

# Grab everything that lies between the title tags using a REGEX
patFinderTitle = re.compile(r'<p align="left">.*<a href=".*">.*\n\s*(.*)</a>', re.MULTILINE)

# Grab the link to the original article using a REGEX
patFinderLink = re.compile(r'<p align="left">.*<a href="(.*)">')

# Store all of the titles and links found in 2 lists
findPatTitle = re.findall(patFinderTitle,webpage)

findPatLink = re.findall(patFinderLink,webpage)

# Create an iterator that will cycle through the first 16 articles and skip a few
listIterator = []
listIterator[:] = range(2,10)

# Print out the results to screen
for i in listIterator:
    print findPatTitle[i] # The title
    print 'http://obamaspeeches.com/'+findPatLink[i] # The link to the original article

    articlePage = urlopen('http://obamaspeeches.com/' + findPatLink[i]).read() # Grab all of the content from original article
    
    divBegin = articlePage.find('<tr>.*</tr><tr><td.*\n*<p>\n*(.*)</td>') # Locate the div provided
    article = articlePage[divBegin:(divBegin+1000)] # Copy the first 1000 characters after the div
    
    # Pass the article to the Beautiful Soup Module
    soup = BeautifulSoup(article)
    
    # Tell Beautiful Soup to locate all of the p tags and store them in a list
    paragList = soup.findAll('p')
    
    
    # Print all of the paragraphs to screen
    for i in paragList:
        print i
    
    print "\n"
#
## Here I retrieve and print to screen the titles and links with just Beautiful Soup
#soup2 = BeautifulSoup(webpage)
#
#print soup2.findAll('title')
#print soup2.findAll('link')
#
#titleSoup = soup2.findAll('title')
#linkSoup = soup2.findAll('link')
#
#for i in listIterator:
#print titleSoup[i]
#
#print linkSoup[i]
#print "\n"
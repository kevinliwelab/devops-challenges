# run below script in python3
import urllib.request, urllib.error, urllib.parse
from bs4 import BeautifulSoup
from collections import Counter

# pointing to nginx default page at 80 port
url = 'http://127.0.0.1'

# extract the HTML response
response = urllib.request.urlopen(url)
html = response.read()

# using BeautifulSoup lib to parse HTML to text
text = BeautifulSoup(html, "html.parser").get_text()

# using collections.Counter to return the n most common elements and their counts
print(Counter(text.split()).most_common())

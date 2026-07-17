#copy_xlms.py
# The python script renames selected xmls files from the xml folder
# while renaming them to the first 32 characters in the title
# field. Besides the xml folder, it requires the PDMX.csv file.
# The renamed files are put in a separate folder called xmlfiles
# which you need to create inside this directory.
#
# Some of the titles have a slash embedded which implies a
# subfolder in the file name. A hyphen is substituted for the
# slash to avoid problems.
#
# All the input files come from the PDMX MusicXML database which
# was scraped from MuseScore. https://github.com/pnlong/PDMX/
#
# There over 250,000 xml files in this database. Presently, we select
# the files with ratings above 3.


import pandas as pd
import os
import shutil


pdmx = pd.read_csv('PDMX.csv')
local_directory = os.getcwd()
print(local_directory)
output_directory = local_directory + '/xmlfiles'
print(output_directory)

start_from = 5000
number_of_files_to_get = 200

j = 0
i = start_from

char_map = {"/" : "-"}
table = str.maketrans(char_map)
while j < number_of_files_to_get:
  i = i + 1
  if pdmx.iloc[i]['rating'] < 3:
    continue
  title = pdmx.iloc[i]['title']
  title = title[:32]
  title = title.translate(table)
  mxl = pdmx.iloc[i]['mxl']
  mxl = mxl[1:]
  print(i,title,pdmx.iloc[i]['rating'])
  source = local_directory+mxl
  #print(source)
  destination = output_directory + '/' + title + '.mxl'
  j = j + 1
  #print(destination)
  dest = shutil.copy(source, destination)
  #print("dest = ",dest)






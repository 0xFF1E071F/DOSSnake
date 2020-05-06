@echo off
cls

set folder=Snake\
set file_name1=main
set file_name2=graphics
set file_name3=logic

tasm /zi %folder%%file_name3%
tasm /zi %folder%%file_name2%
tasm /zi %folder%%file_name1%

tlink /v %file_name1% %file_name2% %file_name3%
%file_name1%

del %file_name1%.map
del %file_name1%.obj
del %file_name2%.obj
del %file_name3%.obj

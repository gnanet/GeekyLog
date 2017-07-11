# GeekyLog
SEO focused access logs analyzer. Uses Linux commands for parsing and D3js for visualization.

## CSV based for universal use
The parser exports the filtered data into several .csv files like :

* urls-actives.csv
* status-gbot-404.csv
* broken-links.csv
* ... and so on

This lets you crunch the generated .csv in your favourite spreadsheet, or use the GeekyLog UI.

## How to use it
This tool is based in some conventions and zero configuration. 

The default directory structure is as follows :

	GeekyLog
	|- css/
	|- js/
	|- logs
	|------ project-1
	|------ project-2
	|------ ...
	|- combined.bash
	|- index.html
	|- actives.html
	|- bots.html
	|- broken.html
	|- status.html


### name of the logs file
The name of the file containing the logs must be "allLogs.log". This should be a text file, though the parser can ignore some binary junk.

### combined.bash
This is the (for now) only parser avalaible. When you fire it, you should indicate the directory name where to look for logs. E.g :

	bash combined.bash project-1

In this case, the parser will look for /logs/project-1/allLogs.log file

### /logs/project-1/
Create a directory for each projet and paste your allLogs.log file in. 

Also, generated .csv files will be stored here.

### css/, js/, * .html files
These are the UI part of GeekyLog. If you want to use it, you may put GeekyLog directory on a (local) webserver.

You can then access the UI at :

	http://localhost/GeekyLog/index.html?d=project-1

You should notice that the "d" parameter indicates the project to be shown. This allows you to easily change from a stored project to another.

## Fake googlebot detection
The parser uses the DNS lookup method approuved by Google to detect spammers and other troublemakers. This is because IP ranges can change. 

These checks may slow down the parsing in some cases, but it's still faster compared to parsers that store data in DBs (and doesn't do the DNS lookup).

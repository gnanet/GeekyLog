#!/bin/bash

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Combined logs parser
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# filtered data is stored in .csv files that :
# * serve to build the UI
# * allows you to chrush the data with you favourite spredsheet or app

# First, you should combine log files into one big log file named allLogs.log 
# To achieve this, you can do the following :
# 1. cd to the logs directory
# 2. mkdir a directory to store the new project's logs
# 3. untar, unzip log files if needed
# 4. combine all logs into one big file, named allLogs.log. E.g : 
# cat *.log >> allLogs.log

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 0. Get path to data directory :
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

if [ -z $1 ]
then
  echo -e "\nUsage: $(basename $0) PROJECT\n\tproject - the name of a directory in the logs/ folder where allLogs.log lives in\n"
  exit
fi

path=$1

json="logs/${path}/data.json"


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 1. Group & filter
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# Group all .log from specified directory into one :

#cat *.log > allLogs.log

echo "Filtering logs ..."

# cat -v : filters binary junk when gre returns 'binary file matches'

cat -v "logs/${path}/"allLogs.log | grep Google > "logs/${path}/"google.log


# Filter 'GoogleBot' lines

cat -v "logs/${path}/"allLogs.log | grep Googlebot > "logs/${path}/"googlebot.log



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 2. Filter fake googlebots
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

echo "Filtering fake googlebots" 
echo -e "\t- grepping googlebots"

# Filter googlebot "search" UA

cat -v "logs/${path}/"googlebot.log | grep google.com/bot.html > "logs/${path}/"googlebotsearch.tmp


# Collect googlebot "search" IPs for control

echo -e "\t- grepping ips"
cat "logs/${path}/"googlebotsearch.tmp | awk '{print $1}' | sort -du > "logs/${path}/"ips.tmp

# Verify all googlebot "search" ips
# using the approuved method in Search Console Help

declare -A verifiedIps
echo "gSearchIPs" > "logs/${path}/"gSearchIPs.tsv
echo "" > "logs/${path}/"fakeGbotIPs.tsv

echo -e "\t- checking googlebots ips hosts"
while read -r line
do
   	if [ -z $line ]
	then
		continue
	fi
	fake=0	
	hostName=`host $line | cut -d" " -f5`
	domain=`echo $hostName | cut -d"." -f2,3`
	if [ $domain == "googlebot.com" ] || [ $domain == "google.com" ]
	then
		ip=`host $hostName | cut -d" " -f4`
		if [ $line == $ip ]
	then
		verifiedIps[$line]="1"
		echo -e "${line}" >> "logs/${path}/"gSearchIPs.tsv
		echo -e "\t $line : OK"
	else
		echo -e "\t $line : Seems a fake googlebot"
		fake=1
	fi
else
	echo -e "\t $line : Seems a fake googlebot"
	fake=1
fi

if [ "$fake" = 1 ]
then
	echo -e "${line}" >> "logs/${path}/"fakeGbotIPs.tsv
fi


done < "logs/${path}/"ips.tmp


# Start filtering
echo "" > "logs/${path}/"googlebotsearch.log

echo -e "\t- filtering googlebot logs with verified ips"
while read -r line 
do
	ip=`echo $line | cut -d" " -f1`
	if [ "${verifiedIps[$ip]}"=="1" ]
	then
		echo -e "${line}" >> "logs/${path}/"googlebotsearch.log
	fi
done < "logs/${path}/"googlebotsearch.tmp

# Removing .tmp files
echo -e "\t- Removing temporal files"
rm "logs/${path}/"googlebotsearch.tmp
rm "logs/${path}/"ips.tmp




# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 3. Status
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# All googlebot status
echo "Status"
echo -e "\t- all googlebot"
cat "logs/${path}/"google.log | awk '{print $9}' | sort | uniq -c | awk 'BEGIN {print "key\tvalue"} $2!="" {print $2 "\t" $1}' >  "logs/${path}/"status-all-gbot.tsv

# Search googlebot status
echo -e "\t- 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk '{print $9}' | sort | uniq -c | awk 'BEGIN {print "key\tvalue"} $2!="" {print $2 "\t" $1}' >  "logs/${path}/"status-gbot.tsv

# 301   googlebot search status
echo -e "\t-301 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk '$9==301 {print $7}' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {"key\tvalue"} $2!="" {print $2"\t"$1}' > "logs/${path}/"status-gbot-301.tsv

# 302   googlebot search status
echo -e "\t-302 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk '$9==302 {print $7}' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {"key\tvalue"} $2!="" {print $2"\t"$1}' > "logs/${path}/"status-gbot-302.tsv

# 404   googlebot search status
echo -e "\t-404 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk '$9==404 {print $7}' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {"key\tvalue"} $2!="" {print $2"\t"$1}' > "logs/${path}/"status-gbot-404.tsv

# 410   googlebot search status
echo -e "\t-410 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk '$9==410 {print $7}' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {"key\tvalue"} $2!="" {print $2"\t"$1}' > "logs/${path}/"status-gbot-410.tsv

# 5xx   googlebot search status
echo -e "\t-5xx 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk '$9>499 {print $7}' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {"key\tvalue"} $2!="" {print $2"\t"$1}' > "logs/${path}/"status-gbot-5xx.tsv


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 4. Status timelines 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Array of status codes by date   
# inspired by : searchdatalogy.com/blog/technical-seo-log-analysis/  
echo -e "\tTimeline"
#cat "logs/logs/${path}/"googlebotsearch.log | cut  -d' ' -f4,7,9 | sed  's/\[//g'| cut -c1-6,21- | sort -u | cut -d' ' -f1,3 | sort | uniq -c | sed 's/\//-/g' |  sed 's/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g; s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g;' | awk '$2~/^[0-9]{2}-[0-9]{2}/ {print $2" "$3" "$1}' | awk -F "[ -]*" '{print $2"-"$1" "$3" "$4}' | awk '{dic[$1][$2] = $3} END { for (key in dic) { print key","dic[key][200]","dic[key][301]","dic[key][302]","dic[key][404]","dic[key][500] } }' | sed 's/,,,/,0,0,/g ; s/,,/,0,/g;' | sed -e 's/,$/,0/g'| sort -t$'-' -k 2M -k1 | awk 'BEGIN {print "date,200,301,302,404,500"} {print $0}' > "logs/${path}/"status-by-date.csv


cat "logs/${path}/"googlebotsearch.log | cut  -d' ' -f4,7,9 | sed  's/\[//g'| cut -c1-6,21- | sort -u | cut -d' ' -f1,3 | sort | uniq -c | sed 's/\//-/g' |  sed 's/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g; s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g;' | awk '$2~/^[0-9]{2}-[0-9]{2}/ {print $2" "$3" "$1}' | awk -F "[ -]*" '{print $2"-"$1" "$3" "$4}' | awk '{dic[$1][$2] = $3} END { for (key in dic) { print key"\t"dic[key][200]"\t"dic[key][301]"\t"dic[key][302]"\t"dic[key][404]"\t"dic[key][500] } }' | sed 's/,,,/,0,0,/g ; s/,,/,0,/g;' | sed -e 's/,$/,0/g'| sort -t$'-' -k 2M -k1 | awk 'BEGIN {print "date\t200\t301\t302\t404\t500"} {print $0}' > "logs/${path}/"status-by-date.tsv


# Array of 404 by date   
echo -e "\tTimeline 404"
#cat "logs/${path}/"googlebotsearch.log | cut  -d' ' -f4,7,9 | sed  's/\[//g'| cut -c1-6,21- | sort -u | cut -d' ' -f1,3 | sort | uniq -c | sed 's/\//-/g' |  sed 's/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g; s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g;' | awk '$2~/^[0-9]{2}-[0-9]{2}/ {print $2" "$3" "$1}' | awk -F "[ -]*" '{print $2"-"$1" "$3" "$4}' | awk '{dic[$1][$2] = $3} END { for (key in dic) { print key","dic[key][404] } }' | sed 's/,,,/,0,0,/g ; s/,,/,0,/g;' | sed -e 's/,$/,0/g'| sort -t$'-' -k 2M -k1 | awk 'BEGIN {print "date,404"} {print $0}' > "logs/${path}/"status-404-by-date.csv



cat "logs/${path}/"googlebotsearch.log | cut  -d' ' -f4,7,9 | sed  's/\[//g'| cut -c1-6,21- | sort -u | cut -d' ' -f1,3 | sort | uniq -c | sed 's/\//-/g' |  sed 's/Jan/01/g; s/Feb/02/g; s/Mar/03/g; s/Apr/04/g; s/May/05/g; s/Jun/06/g; s/Jul/07/g; s/Aug/08/g; s/Sep/09/g; s/Oct/10/g; s/Nov/11/g; s/Dec/12/g;' | awk '$2~/^[0-9]{2}-[0-9]{2}/ {print $2" "$3" "$1}' | awk -F "[ -]*" '{print $2"-"$1" "$3" "$4}' | awk '{dic[$1][$2] = $3} END { for (key in dic) { print key"\t"dic[key][404] } }' | sed 's/,,,/,0,0,/g ; s/,,/,0,/g;' | sed -e 's/,$/,0/g'| sort -t$'-' -k 2M -k1 | awk 'BEGIN {print "date\t404"} {print $0}' > "logs/${path}/"status-404-by-date.tsv


# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 5. URLs
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# Googlebot search explored urls (no images) grouped by number of times
echo "URLs"
echo -e "\t- Top URLs 'search' googlebot"
#cat "logs/${path}/"googlebotsearch.log | awk '$7!~".txt|.css|.js|.jpg|.png|.gif|.jpeg"  {print $7}' | tr '/' '.' |  sed -e 's/\(.php\)*$//g' | sed -e 's/\(.html\)*$//g' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {print "id,value"} $2!="" {print $2"\t"$1}' > "logs/${path}/"urls-gbot.tsv

cat "logs/${path}/"googlebotsearch.log | awk '$7!~".jpg|.png|.gif|.jpeg"  {print $7}' |  sed -e 's/\(.php\)*$//g' | sed -e 's/\(.html\)*$//g' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {print "id\tvalue"} $2!="" {print $2"\t"$1}' > "logs/${path}/"urls-gbot.tsv


# Top 50 URL hitted by googlebot search : bulles
cat "logs/${path}/"urls-gbot.tsv | tr '/' '.' | head -n50 > "logs/${path}/"urls-gbot-top-50.tsv

# broken links 
echo -e "\t- Broken links"
cat "logs/${path}/"allLogs.log | awk -F\" '$4!="-" {print $2" "$4" "$3}' | awk '$5==404 {print $4" "$2}' | sort | uniq -c | sort -k1,1nr | awk 'BEGIN {print "number\tfrom\tto"} {print $1"\t"$2"\t"$3}' > "logs/${path}/"broken-links.tsv



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 6. Hits
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# TODO : Hits by section 
#cat "logs/${path}/"googlebotsearch.log | awk '{print $7}' | sed 's,/*[^/]\+/*$,,' | sort | uniq -c | sort -rn -k1,1 | awk '{print "\42" $2 "\42" ":" "\42" $1 "\42,"}' >> $json

# hits by UA
#cat "logs/${path}/"google.log | awk -F\" '{print "#" $6}' | sort | uniq -c | sort -rnk1,1 | awk -F"#" '{print "\42" $2 "\42" ":" "\42" $1 "\42,"}' >> $json

# hits by bot  
echo "Hits"
echo -e "\t- by bot"
#cat "logs/${path}/"allLogs.log | grep bot | awk -F\" '{print "#" $6}' | sort | uniq -c | sort -rnk1,1 | awk -F"#" '{gsub(/ */,"",$1); gsub(",","",$2)} {print $2"\t"$1}' > "logs/${path}/"ua-bot.tsv

cat "logs/${path}/"allLogs.log | grep bot | awk -F\" '{print "#" $6}' | sort | uniq -c | sort -rnk1,1 | awk -F"#" '{gsub(/ */,"",$1);} {print $2"\t"$1}' > "logs/${path}/"ua-bot.tsv
# hits by UA search
echo -e "\t- 'search' googlebot"
cat "logs/${path}/"googlebotsearch.log | awk -F\" '{print "#" $6}' | sort | uniq -c | sort -rnk1,1 | awk -F"#" '{gsub(/ */,"",$1); gsub(/,/,"",$2)} {print $2"\t"$1}' > "logs/${path}/"ua-gbot-search.tsv

# hits by UA search
echo -e "\t- googlebot"
cat "logs/${path}/"google.log | awk -F\" '{print "#" $6}' | sort | uniq -c | sort -rnk1,1 | awk -F"#" '{gsub(/ */,"",$1); gsub(/,/,"",$2)} {print $2"\t"$1}' > "logs/${path}/"ua-gbot.tsv

# time, active pages, orphans, retention, algos, crawl noindex, crawl pagination, ..

# Hits : Googlebot images 
echo -e "\t- googlebot images"
cat "logs/${path}/"googlebot.log | grep Googlebot-Image | awk '{print $7}' | sort | uniq -c | sort -rnk1,1 | awk '{gsub(/ */,"",$1); gsub(/,/,"",$2)} {print $2"\t"$1}' > "logs/${path}/"ua-gbot-images.tsv
googleImageHits=$(grep Googlebot-Image "logs/${path}/"googlebot.log)



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 7. Pages
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


echo "Pages"
echo -e "\t- Total pages"
cat "logs/${path}/"allLogs.log | awk '$9<300 && $7!~".css|.js|.txt|.jpg|.jpeg|.png|.gif" {print $7}' | sort | uniq | sort > "logs/${path}/"pages-total.tsv

echo -e "\t- Explored pages by googlebot search"
cat -v "logs/${path}/"googlebotsearch.log | awk '$9<300 && $7!~".css|.js|.txt|.jpg|.jpeg|.png|.gif" {print $7}' | sort | uniq | sort > "logs/${path}/"pages-explored.tsv

echo -e "\t- Unexplored pages by googlebot search"
comm -23 "logs/${path}/"pages-total.tsv  "logs/${path}/"pages-explored.tsv  | sort | uniq > "logs/${path}/"pages-unexplored.tsv

echo -e "\t- CSS"
cat -v "logs/${path}/"allLogs.log | awk '$7~".css" {print $7}' | sort | uniq -c | sort -rn | awk '{gsub(/ */,"",$1)} {print $2"\t"$1}'   > "logs/${path}/"assets-css.tsv

echo -e "\t- JS" 
cat -v "logs/${path}/"allLogs.log | awk '$7~".js" {print $7}' | sort | uniq -c | sort -rn | awk '{gsub(/ */,"",$1)} {print $2"\t"$1}'   > "logs/${path}/"assets-js.tsv

echo -e "\t- Images"
cat -v "logs/${path}/"allLogs.log | awk '$7~".jpg|.jpeg|.png|.gif" {print $7}' | sort | uniq -c | sort -rn | awk '{gsub(/ */,"",$1)} {print $2"\t"$1}'   > "logs/${path}/"assets-images.tsv

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 8. Actives
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


# active pages    
echo "Active pages"
echo -e "\t- actives"
cat "logs/${path}/"allLogs.log | awk '$11~"google" && $7!~".css|.txt|.js|.jpg|.png|.gif|.jpeg" {print $7}' | sort | uniq -c | sort -rn | awk '{gsub(/ */,"",$1)} {print $2"\t"$1}' > "logs/${path}/"pages-actives.tsv

cat "logs/${path}/"allLogs.log | awk '$11~"google" && $7!~".css|.txt|.js|.jpg|.png|.gif|.jpeg" {print $7}' | sort | uniq | sort > "logs/${path}/"pages-actives-list.tsv

cat "logs/${path}/"pages-actives.tsv | awk '{print $1}' | sort > "logs/${path}/"pages-actives-list.tsv


# non active pages - indexes
echo -e "\t- non actives"
comm -23 "logs/${path}/"pages-explored.tsv "logs/${path}/"pages-actives-list.tsv > "logs/${path}/"pages-inactives.tsv

# Status of all served files
echo -e "\t- Status of all served files"
cat "logs/${path}/"allLogs.log | awk '{print $9}' | sort | uniq -c | awk '{print $2" "$1}' > status.tsv
declare -A aa
while read -r line
do
	a=`echo "$line" | cut -d" " -f1`
	b=`echo "$line" | cut -d" " -f2`
	aa[$a]=$b
done < status.tsv
status200="${aa[200]:-0}"
status301="${aa[301]:-0}"
status302="${aa[302]:-0}"
status403="${aa[403]:-0}"
status404="${aa[404]:-0}"
status410="${aa[410]:-0}"
status5xx="${aa[5xx]:-0}"

# Status of all served files to googlebot search
echo -e "\t- Status of all served files gbot search"
cat "logs/${path}/"googlebotsearch.log | awk '{print $9}' | sort | uniq -c | awk '{print $2" "$1}' > statusGbot.tsv
declare -A bb
while read -r line
do
	a=`echo "$line" | cut -d" " -f1`
	b=`echo "$line" | cut -d" " -f2`
	bb[$a]=$b
done < statusGbot.tsv
statusGbot200="${bb[200]:-0}"
statusGbot301="${bb[301]:-0}"
statusGbot302="${bb[302]:-0}"
statusGbot403="${bb[403]:-0}"
statusGbot404="${bb[404]:-0}"
statusGbot410="${bb[410]:-0}"
statusGbot5xx="${bb[5xx]:-0}"



# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# 9. Global stats
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


echo "Global Stats"


# General
echo -e "\t- General"
hitsTotal=$(cat -v "logs/${path}/"allLogs.log | wc -l)
URLsTotal=$(cat -v "logs/${path}/"allLogs.log | awk '{print $7}' | sort | uniq  | wc -l)
URLsActives=$(cat -v "logs/${path}/"allLogs.log | awk '$11~"google" {print $7}' | wc -l)


echo -e "\t- Pages"
pagesTotal=$(cat -v "logs/${path}/"pages-total.tsv  | wc -l) 
pagesExplored=$(cat -v "logs/${path}/"pages-explored.tsv | wc -l)
pagesUnexplored=$(cat -v "logs/${path}/"pages-unexplored.tsv | wc -l) 
pagesActives=$(cat "logs/${path}/"pages-actives-list.tsv | wc -l)
pagesInactives=$(cat "logs/${path}/"pages-inactives.tsv | wc -l)


# Assets
echo -e "\t- Assets"
css=$(cat "logs/${path}/"assets-css.tsv | wc -l)
js=$(cat "logs/${path}/"assets-js.tsv | wc -l)
images=$(cat "logs/${path}/"assets-images.tsv | wc -l)


# Googlebot

echo -e "\t- Googlebot"
gBotsHits=$(cat "logs/${path}/"google.log | wc -l)
gBotsErrors=$(cat "logs/${path}/"googlebot.log | awk '$7>399 {print $7}' | wc -l)
gSearchHits=$(cat "logs/${path}/"googlebotsearch.log | wc -l)
gSearchIPs=$(cat "logs/${path}/"gSearchIPs.tsv | wc -l)
gImgHits=$(cat "logs/${path}/"googlebot.log | grep Googlebot-Image | wc -l)


# bots hits

echo -e "\t- Bots hits"
bingHits=$(cat "logs/${path}/"allLogs.log | grep -i bingbot | wc -l)
yandexHits=$(cat "logs/${path}/"allLogs.log | grep -i yandex | wc -l)
baiduHits=$(cat "logs/${path}/"allLogs.log | grep -i baidu | wc -l)
fakeGbotIPs=$(cat "logs/${path}/"fakeGbotIPs.tsv | wc -l)
bots=$(cat -v "logs/${path}/"allLogs.log | awk '$1~"^[0-9]{1,3}." {print $12$13$14}' | grep -E -i "spider|crawler|bot" | wc -l)


echo "{" > "logs/${path}/"global.json

echo '"hitsTotal":' ${hitsTotal}',' >> "logs/${path}/"global.json
echo '"URLsTotal":' ${URLsTotal}',' >> "logs/${path}/"global.json
echo '"URLsActives":' ${URLsActives}',' >> "logs/${path}/"global.json
echo '"pagesTotal":' ${pagesTotal}',' >> "logs/${path}/"global.json
echo '"pagesExplored":' ${pagesExplored}',' >> "logs/${path}/"global.json
echo '"pagesUnexplored":' ${pagesUnexplored}',' >> "logs/${path}/"global.json
echo '"pagesActives":' ${pagesActives}',' >> "logs/${path}/"global.json
echo '"pagesInactives":' ${pagesInactives}',' >> "logs/${path}/"global.json


echo '"status200":' ${status200}',' >> "logs/${path}/"global.json
echo '"status301":' ${status301}',' >> "logs/${path}/"global.json
echo '"status302":' ${status302}',' >> "logs/${path}/"global.json
echo '"status403":' ${status403}',' >> "logs/${path}/"global.json
echo '"status404":' ${status404}',' >> "logs/${path}/"global.json
echo '"status410":' ${status410}',' >> "logs/${path}/"global.json
echo '"status5xx":' ${status5xx}',' >> "logs/${path}/"global.json


echo '"statusGbot200":' ${statusGbot200}',' >> "logs/${path}/"global.json
echo '"statusGbot301":' ${statusGbot301}',' >> "logs/${path}/"global.json
echo '"statusGbot302":' ${statusGbot302}',' >> "logs/${path}/"global.json
echo '"statusGbot403":' ${statusGbot403}',' >> "logs/${path}/"global.json
echo '"statusGbot404":' ${statusGbot404}',' >> "logs/${path}/"global.json
echo '"statusGbot410":' ${statusGbot410}',' >> "logs/${path}/"global.json
echo '"statusGbot5xx":' ${statusGbot5xx}',' >> "logs/${path}/"global.json


echo '"css":' ${css}',' >> "logs/${path}/"global.json
echo '"js":' ${js}',' >> "logs/${path}/"global.json
echo '"images":' ${images}',' >> "logs/${path}/"global.json

echo '"gBotsHits":' ${gBotsHits}',' >> "logs/${path}/"global.json
echo '"gBotsErrors":' ${gBotsErrors}',' >> "logs/${path}/"global.json
echo '"gSearchHits":' ${gSearchHits}',' >> "logs/${path}/"global.json
echo '"gImgHits":' ${gImgHits}',' >> "logs/${path}/"global.json
echo '"gSearchIPs":' ${gSearchIPs}',' >> "logs/${path}/"global.json
echo '"fakeGbotIPs":' ${fakeGbotIPs}',' >> "logs/${path}/"global.json


echo '"botsHits":' ${bots}',' >> "logs/${path}/"global.json
echo '"bingHits":' ${bingHits}',' >> "logs/${path}/"global.json
echo '"yandexHits":' ${yandexHits}',' >> "logs/${path}/"global.json
echo '"baiduHits":' ${baiduHits} >> "logs/${path}/"global.json

echo "}"  >> "logs/${path}/"global.json

# Maintain list of projects
cd logs
projects=`ls -d */ | cut -f1 -d'/'`
cd ..
echo "${projects}" > logs/projects.txt

exit

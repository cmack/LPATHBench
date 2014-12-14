
if [ $# -ne 2 ]; then echo -e "Usage is sh $0 <correctresult> <resultfile>"; exit 1; fi

echo "Compiling..."
make buildall

runners=( "./fs.exe"\
	"./cpp"\
	"./rkt"\
	"mono ./cs.exe"\
	"java jv"\
	"dart dart.dart"\
	"./hs"\
	"./ml"\
	"./lisp"\
	"./rs"\
	"./go"\
	"./d"\
	"./nim"\
	"luajit lj.lua"\
	"./ojava ojv")

echo "Running..."

start=""
${start} > rawRes
for((i=0; i < ${#runners[@]}; i++));
do
#    echo 'yolo'
    ${runners[i]} >> rawRes
done

filterStringPartOne='$2 == "LANGUAGE" && $1 == '
filterStringPartTwo=$1
filterStringPartThree=' { print $3 " " $4 }' 
awkCmd=$filterStringPartOne$filterStringPartTwo$filterStringPartThree 

echo $awkCmd > filterString.awk

awk -f filterString.awk ./rawRes > ./filteredRes

sort -k 2 -n ./filteredRes > ./sortedRes

echo '<html><head></head><body><table style="width: 100%" border="1" cellspacing="1" cellpadding="1">' > $2
echo '<th style="width: 60%">Language</th><th style="width: 40%">Runtime (ms)</th>' >> $2
echo '{print "<tr><td>"$1"</td><td>"$2"</td></tr>"}' > ./printtable.awk
awk -E printtable.awk ./sortedRes >> $2
echo '</table></body></html>' $2

#cat $1 | sed 's/"[0-9]*",//g' > proxy1
cat $1 | sed 's/"",/"idx",/g' > proxy1
cat proxy1 | sed 's/"//g' > proxy2
#cat proxy2 | sed 's/NA/\?/g' > proxy3
cat proxy2 | sed 's/NA//g' > proxy3
mv proxy3 $1
#rm -r proxy1 proxy2


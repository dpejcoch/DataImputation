setwd("r:/ROOT/wamp/www/dataqualitycz/vyzkum/Imputace/data/")
library(imputeR)
m<-12
# 5 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.05)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_5.csv",sep=""))
}
# 10 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.10)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_10.csv",sep=""))
}
# 15 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.15)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_15.csv",sep=""))
}
# 20 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.20)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_20.csv",sep=""))
}
# 25 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.25)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_25.csv",sep=""))
}
# 30 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.30)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_30.csv",sep=""))
}
# 35 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.35)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_35.csv",sep=""))
}
# 40 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.40)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_40.csv",sep=""))
}
# 45 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.45)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_45.csv",sep=""))
}
# 50 procent =====================================
for(i in 1:m) {
mydata = read.csv(paste("ds",i,".csv",sep=""))
mtrix<-data.matrix(mydata)
out<-SimIm(mtrix, p=0.5)
output<-data.frame(out)
write.csv(output, file=paste("missings/ds",i,"_50.csv",sep=""))
}
# END =====================================
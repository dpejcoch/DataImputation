setwd("r:/ROOT/wamp/www/dataqualitycz/vyzkum/Imputace/data/missings/")
library(HotDeckImputation)
for (y in 1:12) {
    for (x in seq(5, 50, 5)) {
        h<-paste("ds",y, sep="", collapse=NULL)
        f<-paste(h,x,"M6","prep", sep="_", collapse=NULL)
        g<-paste(f,"csv",sep=".",collapse=NULL)
        mydata = read.csv(g)
        mtrix<-data.matrix(mydata)
        a.out<-data.frame(impute.NN_HD(data = mtrix, distance = "eukl"))
        link<-paste (h,x,"M6","imp",".csv", sep="_", collapse=NULL)
        write.csv(a.out, file=link)
    }
}
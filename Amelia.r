setwd("r:/ROOT/wamp/www/dataqualitycz/vyzkum/Imputace/data/missings/")
library(Amelia)
for (y in 1:12) {
    for (x in seq(5, 50, 5)) {
        h<-paste("ds",y, sep="", collapse=NULL)
        f<-paste(h,x, sep="_", collapse=NULL)
        m<-5
        g<-paste(f,"csv",sep=".",collapse=NULL)
        mydata = read.csv(g)
        a.out<-amelia(x = mydata, m = m, idvars = NULL, ts = NULL, 
               cs = NULL, priors = NULL, lags = NULL, empri = 0, intercs = FALSE, 
               leads = NULL, splinetime = NULL, logs = NULL, sqrts = NULL, 
               lgstc = NULL, ords = NULL, noms = NULL, bounds = NULL, max.resample = 1000, 
               tolerance = 1e-04)
        for(i in 1:m) {
        link<-paste (f,"M23","imp",i,".csv", sep="_", collapse=NULL)
        write.csv(a.out$imputations[[i]], file=link)
        }
    }
}
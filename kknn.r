setwd("r:/ROOT/wamp/www/dataqualitycz/vyzkum/Imputace/")
train = read.csv("imputace.DS002_0_25_train.csv")
test = read.csv("imputace.DS002_0_25_test.csv")
a.out<-kknn(a20~., train, test, distance = 1)
outtab<-summary(a.out)
write.csv(outtab, file="imputace.DS002_0_25_M06.csv")


iris.kknn <- kknn(Species~., iris.learn, iris.valid, distance = 1,
kernel = "triangular")
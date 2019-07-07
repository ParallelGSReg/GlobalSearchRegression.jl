# define your working directory path here
install.package("data.table")
library(data.table)

rm(list=ls())
rm(list = ls(all.names = TRUE))

x <- matrix(rnorm(200*1000), ncol=200)
y <- matrix(rnorm(1*1000), ncol=1)
data <- data.frame(y,x)

tmp1 <- system.time(
{
model <- lm(y ~ . , data=data)
print(model)
})

times <- t(data.matrix(tmp1))
fwrite(times,"RegTimeR.csv", append=TRUE)

tmp2 <- system.time(
{
modelcache <- lm(y ~ . , data=data)
print(modelcache)
})


timescache <- t(data.matrix(tmp2))
fwrite(timescache,"RegTimeR.csv", append=TRUE)

#########################################################

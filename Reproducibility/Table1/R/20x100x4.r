# insert your working directory path here
Packages <- c("MuMIn", "snow", "data.table")
lapply(Packages, library, character.only = TRUE)

rm(list=ls())
rm(list = ls(all.names = TRUE))

x <- matrix(rnorm(20*100), ncol=20)
y <- matrix(rnorm(1*100), ncol=1)
data <- data.frame(y,x)

tmp <- system.time(
{
globalmodel <- lm(y ~ . ,data=data)
options(na.action = "na.fail")

clusterType <- if(length(find.package("snow", quiet = TRUE))) "SOCK" else "PSOCK"
clust <- try(makeCluster(getOption("cl.cores", 4), type = clusterType))
clusterExport(clust, "data")


pdredge <- pdredge(globalmodel, cluster = clust, rank= "AIC")
print(summary(get.models(pdredge, 1)[[1]]))
fwrite(pdredge, "pdredge20x100x4.csv")
stopCluster(clust)
})

times <- t(data.matrix(tmp))
fwrite(times,"Rtimming.csv", append=TRUE)

quit(save="no")

# end
source("http://bioconductor.org/biocLite.R")
biocLite("breastCancerNKI")
biocLite("genefu")

library(genefu)
library(breastCancerNKI)

data(sig.oncotypedx)
## load NKI dataset
data(nkis)
## compute relapse score
rs.nkis <- oncotypedx(data=data.nkis, annot=annot.nkis, do.mapping=TRUE)

## merge in clinical data
data(nki)

nki.data <- exprs(nki)
nki.clinical <- as(nki@phenoData, "data.frame")
nki.annot <- nki@featureData@data

rs.nki <- oncotypedx(data = t(nki.data), annot = subset(nki.annot, !is.na(EntrezGene.ID)), do.mapping = TRUE)

nki.alldata <- subset(merge(nki.clinical, data.frame(samplename = names(rs.nki$score), oncotypedx = rs.nki$score), by = "samplename"), !is.na(oncotypedx))

## did it work?

library(survival)

plot(survfit(Surv(t.rfs, e.rfs) ~ cut(oncotypedx, c(-1, 25, 50, 75, 101)), data = nki.alldata))
plot(survfit(Surv(t.os, e.os) ~ cut(oncotypedx, c(-1, 25, 50, 75, 101)), data = nki.alldata))
# sweet

nki.alldata2 <- nki.alldata[, !colnames(nki.alldata) %in% c("dataset", "series", "filename", "pgr", "her2")]
write.csv(nki.alldata2, paste0("nki-oncotype-data-", Sys.Date(), ".csv"), row.names = FALSE)




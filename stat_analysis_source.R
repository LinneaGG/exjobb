genePresence <- read.table(file = 'gene_presence_absence.Rtab', row.names = 1)
colnames(genePresence) <- genePresence[1,]
genePresence <- genePresence[-1, ]

#genePresence <- head(genePresence, 5000) #May need to remove some of the least common genes if you get stack overflow error
genePresence = t(genePresence)

#Add column for source
source <- read.csv(file = 'traits_source.csv', row.names = 1)
genePresence = transform(merge(source,genePresence,by=0,all=TRUE), row.names=Row.names, Row.names=NULL)

#Remove columns of genes that all isolates have 
genePresence = genePresence[, sapply(genePresence, function(col) length(unique(col))) > 1]

genePresence[sapply(genePresence, is.character)] <- lapply(genePresence[sapply(genePresence, is.character)], as.factor)
genePresence[sapply(genePresence, is.integer)] <- lapply(genePresence[sapply(genePresence, is.integer)], as.factor)

library(glmnet)
library(Rcpp)
library(caret)
tc <- trainControl(method = "LOOCV") #Leave-one-out cross-validation. If script takes long to run, use k-fold validation: (method = "cv", number = 10)
m3 <- train( Source ~ .,
              data = genePresence,
              method = "glmnet",
              tuneGrid = expand.grid(alpha = 0.4,
                                     lambda = seq(0, 10, 0.1)),
              #metric =  "auc",
              family="binomial",
              trControl = tc)

#Results for the best model:
res = m3$results[which(m3$results$lambda == m3$finalModel$lambdaOpt),]

#Coefficients for the best model:
coef = coef(m3$finalModel, m3$finalModel$lambdaOpt)
coef <- as.data.frame(as.matrix(coef))
coef[coef != 0, ]
coef = subset(coef, s1 != 0) #Remove genes with a 0 coefficient

#Rename genes that actually have a name (note the added 1's)
rownames(coef)[rownames(coef) == "group_40781"] <- "ISEc25"
rownames(coef)[rownames(coef) == "group_94131"] <- "yeaN"
rownames(coef)[rownames(coef) == "group_13071"] <- "clpV11"
rownames(coef)[rownames(coef) == "group_92001"] <- "cyoC"
rownames(coef)[rownames(coef) == "group_62031"] <- "prpE_2"

plot(m3)

#see lambda
m3$lambda.min

#coef2 <- data.frame(coef)
coef2 <- cbind(rownames(coef), data.frame(coef, row.names = NULL))
coef <-coef2 [-1,] #remove intercept

#Remove the 1 that is added to the gene names!
coef$'rownames(coef)'<-gsub('1$',"",as.character(coef$'rownames(coef)'))

#Prepare for plotting
c.df<-coef[order(-coef$s1),]
c.df$var<-c.df$`rownames(coef)`
c.df<-c.df[,-1]
c.df$var <- factor(c.df$var, levels = c.df$var[order(c.df$s1)])

#Plot

library(ggplot2)

g  <- ggplot(c.df, aes(x= var, y =  s1)) +
  geom_bar(alpha=.5, stat="identity", color="darkorchid", fill="darkorchid") +
  ylab("Coefficient")+
  xlab("Gene")+
  coord_flip()+
  theme(axis.text = element_text(size = "10"))
g

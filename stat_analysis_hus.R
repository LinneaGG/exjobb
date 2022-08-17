genePresence <- read.table(file = 'gene_presence_absence_human.Rtab', row.names = 1)
colnames(genePresence) <- genePresence[1,]
genePresence <- genePresence[-1, ]

#genePresence <- head(genePresence, - 5000)
genePresence = t(genePresence)

#Add column for HUS and region
hus <- read.csv(file = 'traits_HUS.csv', row.names = 1)
regions <- read.csv(file = 'O157_human_animal_regions.csv', row.names = 1)

#genePresence = transform(merge(regions,genePresence,by=0,all=TRUE), row.names=Row.names, Row.names=NULL)
genePresence = transform(merge(hus,genePresence,by=0,all=TRUE), row.names=Row.names, Row.names=NULL)

genePresence = genePresence[complete.cases(genePresence), ]

#Remove columns of genes that all isolates have 
genePresence = genePresence[, sapply(genePresence, function(col) length(unique(col))) > 1]

genePresence[sapply(genePresence, is.character)] <- lapply(genePresence[sapply(genePresence, is.character)], as.factor)
genePresence[sapply(genePresence, is.integer)] <- lapply(genePresence[sapply(genePresence, is.integer)], as.factor)

library(glmnet)
library(Rcpp)
library(caret)
tc <- trainControl(method = "LOOCV") #Leave-one-out cross-validation 
m3 <- train( HUS ~ .,
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
#coef = subset(coef, s1 > 0.00001 | s1 < -0.00001)
coef = subset(coef, s1 != 0)

plot(m3)

#see lambda
m3$lambda.min

#coef2 <- data.frame(coef)
coef2 <- cbind(rownames(coef), data.frame(coef, row.names = NULL))
coef <-coef2 [-1,] #remove intercept

coef$'rownames(coef)'<-gsub('1$',"",as.character(coef$'rownames(coef)'))
c.df<-coef[order(-coef$s1),]
c.df$var<-c.df$`rownames(coef)`
c.df<-c.df[,-1]
c.df$var <- factor(c.df$var, levels = c.df$var[order(c.df$s1)])

#Plot

library(ggplot2)

g  <- ggplot(c.df, aes(x= var, y =  s1)) +
  geom_bar(alpha=.5, stat="identity", color="darkorchid", fill="darkorchid") +
  coord_flip()+
  theme(axis.text = element_text(size = "10"))
g

rm(list=ls(all=TRUE)) 

#initialize

libs <-c("tm", "plyr", "class")
lapply(libs, require, character.only = TRUE)

#set options
options(stringAsFactors = FALSE)

#set parameters
candidates <- c("romney", "obama")
pathname <- "C:/yourpath"

#clean text
#use cleanup functions available in textminer
#tm_map applies transformation functions to all elements in a corpus
cleanCorpus <- function(corpus) {
corpus.tmp <- tm_map(corpus, removePunctuation)
corpus.tmp <- tm_map(corpus.tmp, stripWhitespace)
corpus.tmp <- tm_map(corpus.tmp, tolower)
corpus.tmp <- tm_map(corpus.tmp, removeWords, stopwords("english"))
return(corpus.tmp)
}

#analyze corpus
# s.dir <- sprintf("%s/%s", pathname, "Obama")
# s.cor <- Corpus(DirSource(directory = s.dir, encoding = "ANSI"))
# s.cor.cl <- cleanCorpus(s.cor)
# inspect(s.cor.cl[1])
# s.cor.cl[[1]]
# DublinCore(s.cor.cl[[1]], "Creator") <- "Ano Nymous"
# meta(s.cor.cl[[1]]) ##check metadata


#build term document matrix TDM
#TermDocumentMatrix and DocumentTermMatrix (depending on whether you want terms as rows and
#documents as columns, or vice versa)

generateTDM <- function(cand, path) {
s.dir <- sprintf("%s/%s", path, cand)
s.cor <- Corpus(DirSource(directory = s.dir, encoding = "ANSI"))
s.cor.cl <- cleanCorpus(s.cor)
s.tdm <- TermDocumentMatrix(s.cor.cl)
s.tdm <- removeSparseTerms(s.tdm, 0.7)
result <- list(name = cand, tdm = s.tdm)
}

tdm <- lapply(candidates, generateTDM, path=pathname)

#see results: list of list with 2 candidates
str(tdm)


#attach name to TDM

bindCandidateToTDM <- function(tdm){
s.mat <- t(data.matrix(tdm[["tdm"]]))
s.df <- as.data.frame(s.mat, stringsAsFactors = FALSE)
s.df <- cbind(s.df, rep(tdm[["name"]], nrow(s.df)))
colnames(s.df)[ncol(s.df)] <- "targetcandidate"
return(s.df)
}

candTDM <- lapply(tdm, bindCandidateToTDM)

#see results: list of list 
str(candTDM)

#stack
tdm.stack <- do.call(rbind.fill, candTDM) #row binding for both TDMs
tdm.stack[is.na(tdm.stack)] <- 0

#hold out sample
#set training sample  to teach model
train.idx <- sample(nrow(tdm.stack), ceiling(nrow(tdm.stack) * 0.7)) #training data
test.idx <- (1:nrow(tdm.stack))[-train.idx] #test data

#model - k nearest neighbor KNN algo
#knn(train, test, cl, k = 1, l = 0, prob = FALSE, use.all = TRUE)
#euclidian distance

tdm.cand <- tdm.stack[,"targetcandidate"]
tdm.stack.nl <- tdm.stack[,!colnames(tdm.stack) %in% "targetcandidate"]

knn.pred <- knn(tdm.stack.nl[train.idx,], tdm.stack.nl[test.idx,], tdm.cand[train.idx])

#accuracy
conf.mat <- table("Predictions" = knn.pred, Actual = tdm.cand[test.idx])
accuracy <- sum(diag(conf.mat) / length(test.idx) * 100)

#score algorithm

#how to use PLYR rbin.fill
#l <- list(data.frame(a=1, b=2), data.frame(a=2, c=3, d=5))
#do.call(rbind.fill, l)

scoreSpeech <- function(testdir){
s.dir <- sprintf("%s/%s", pathname, testdir)
s.cor <- Corpus(DirSource(directory = s.dir, encoding = "ANSI"))
s.cor.cl <- cleanCorpus(s.cor)
s.tdm <- TermDocumentMatrix(s.cor.cl)
s.tdm <- removeSparseTerms(s.tdm, 0.7)
s.mat <- t(data.matrix(s.tdm))
s.df <- as.data.frame(s.mat, stringsAsFactors = FALSE)
stack.test = do.call(rbind.fill,list(tdm.stack.nl,s.df))
stack.test[is.na(stack.test)] <- 0
knn.pred <- knn(stack.test[1:nrow(stack.test)-1,], stack.test[nrow(stack.test),], tdm.cand)
return(knn.pred)
}

#put a test speech in /test directory
scoreSpeech("test")

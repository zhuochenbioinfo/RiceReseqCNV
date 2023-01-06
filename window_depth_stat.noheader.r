args <- commandArgs(TRUE)

file <- args[1]

data <- read.delim(file,header=F)

colnames(data) <- c("chr","start","end","cov","depth")

data.sub <- data[data$cov > 0.75,]

up <- quantile(data.sub$depth,prob=0.995)
down <- quantile(data.sub$depth,prob=0.005)

data.sub <- data.sub[data.sub$depth > down & data.sub$depth < up,]

depth_stdev <- sd(data.sub$depth)
mean_depth <- mean(data.sub$depth)

pct <- length(data.sub$depth)/length(data$depth)

data.thin <- data.sub[data.sub$depth > mean_depth - depth_stdev & data.sub$depth < mean_depth + depth_stdev,]
pct.thin <- length(data.thin$depth)/length(data$depth)

cat("up=",up,"\n",sep="")
cat("down=",down,"\n",sep="")
cat("mean=",mean_depth,"\n",sep="")
cat("stdev=",depth_stdev,"\n",sep="")
cat("pct=",pct,"\n",sep="")
cat("pct_thin=",pct.thin,"\n",sep="")

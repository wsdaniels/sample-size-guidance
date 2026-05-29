rm(list = ls())

library(scales)
library(viridis)
library(fields)
library(moments)

max.length <- 100000

lwd.val <- 5
line.col <- "gray80"
tick.lwd <- 2
basin.name.cex <- 0.7
williams.lty <- 1

cols <- c("#5495CFFF", "orange", "#DB4743FF", "forestgreen", "mediumpurple3")
sherwin.col <- cols[2]
williams.col <- cols[1]
kunkel.equip.col <- cols[3]
cobe.col <- cols[4]
kunkel.site.col <- cols[5]


resample.vector <- function(x, new.length) {
  old.ind <- seq(0, 1, length.out = length(x))
  new.ind <- seq(0, 1, length.out = new.length)
  approx(old.ind, x, xout = new.ind)$y
}

base.dir <- '/Users/wdaniels/Documents/papers/sampling/data_level_3/x_vectors/'

png('/Users/wdaniels/Documents/papers/sampling/figures/data_overview.png',
    width = 1920, height = 1080, res = 100, pointsize = 34)

par(mgp = c(2.5, 0.75, 0))

par(mar = c(2, 1,   1.25, 1.5))
par(oma = c(1, 2.5, 0,    0))

layout.mat <- matrix(c(1,2,3,
                       4,5,6), ncol = 3, byrow = T)
layout(layout.mat)


### BASIN-LEVEL

basins <- list.files(paste0(base.dir, "basin_level"))

features <- array(NA, dim = c(5,6,8)) #distribution, basin, feature
feature.names <- c("mean", "var", "skew", "kurtosis", "n.large", "top1", "length", "max")
distribution.names <- c("williams", "sherwin", "cobe", "kunkel.equip", "kunkel.site")
basin.names <- c("Appalachian Basin", "Barnette Basin", "Denver Basin", "Permian Basin",
                 "San Joaquin Basin", "Uinta Basin")

for (b in 1:length(basins)){
  
  plot(1,1, col = "white", xlim = c(-1,5), ylim = c(0,1), yaxt = "n", xaxt = "n")
  if (b %in% c(1,2,3,4,5,6)){
    axis(side = 2, at = seq(0,1, 0.1), labels = 100*seq(0,1, 0.1), las =2, lwd = lwd.val)
  }
  abline(h = seq(0,1, 0.1), lty = 2, col = line.col, lwd = tick.lwd)
  
  if (b %in% c(1,2,3,4,5,6)){
    axis(side = 1, at = seq(-1,5), lwd = lwd.val,
         labels = c(expression(10^-1),
                    expression(10^0),
                    expression(10^1),
                    expression(10^2),
                    expression(10^3),
                    expression(10^4),
                    expression(10^5)))
  }
  abline(v = seq(-1,5), lty = 2, col = line.col, lwd = tick.lwd)
  
  ### Williams ###
  
  files <- list.files(paste0(base.dir, "basin_level/", basins[b]))
  files <- files[grepl("williams", files)]
  
  x.mean <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[2]))
  x.lower <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[1]))
  x.upper <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[3]))
  
  y.mean <- cumsum(x.mean)/sum(x.mean)
  y.lower <- cumsum(x.lower)/sum(x.lower)
  y.upper <- cumsum(x.upper)/sum(x.upper)
  
  features[1,b,1] <- mean(x.mean)
  features[1,b,2] <- var(x.mean)
  features[1,b,3] <- skewness(x.mean)
  features[1,b,4] <- kurtosis(x.mean)
  features[1,b,5] <- sum(x.mean > 100)
  features[1,b,6] <- max(x.mean)/sum(x.mean)
  features[1,b,7] <- length(x.mean)
  features[1,b,8] <- max(x.mean)
  
  x.mean <- log(x.mean, base = 10)
  x.lower <- log(x.lower, base = 10)
  x.upper <- log(x.upper, base = 10)
  
  envelopePlot(x1 = x.upper, y1 = y.upper, x2 = x.lower, y2 = y.lower,
               col = alpha(williams.col, 0.3), lineCol = NA)
  
  lines(x.mean, y.mean, lwd = lwd.val, col = williams.col, lty = williams.lty)
  
  ### Sherwin ###
  
  files <- list.files(paste0(base.dir, "basin_level/", basins[b]))
  files <- files[grepl("sherwin", files)]
  
  x <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[1]))
  
  
  features[2,b,1] <- mean(x)
  features[2,b,2] <- var(x)
  features[2,b,3] <- skewness(x)
  features[2,b,4] <- kurtosis(x)
  features[2,b,5] <- sum(x > 100)
  features[2,b,6] <- max(x)/sum(x)
  features[2,b,7] <- length(x)
  features[2,b,8] <- max(x)
  
  x.vals <- log(x, base = 10)  
  y.vals <- cumsum(x)/sum(x)
  
  lines(x.vals, y.vals, col = sherwin.col, lwd = lwd.val)
  
  ### COBE ###
  if (basins[b] == "denver_julesburg"){
    files <- list.files(paste0(base.dir, "basin_level/", basins[b]))
    files <- files[grepl("cobe", files)]
    
    x <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[1]))
    
    features[3,b,1] <- mean(x)
    features[3,b,2] <- var(x)
    features[3,b,3] <- skewness(x)
    features[3,b,4] <- kurtosis(x)
    features[3,b,5] <- sum(x > 100)
    features[3,b,6] <- max(x)/sum(x)
    features[3,b,7] <- length(x)
    features[3,b,8] <- max(x)
    
    x.vals <- log(x, base = 10)
    y.vals <- cumsum(x)/sum(x)
    
    lines(x.vals, y.vals, col = cobe.col, lwd = lwd.val)
  }
  
  ### Kunkel ###
  if (basins[b] == "permian"){
    files <- list.files(paste0(base.dir, "basin_level/", basins[b]))
    files <- files[grepl("kunkel", files)]
    
    x <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[1]))
    
    features[4,b,1] <- mean(x)
    features[4,b,2] <- var(x)
    features[4,b,3] <- skewness(x)
    features[4,b,4] <- kurtosis(x)
    features[4,b,5] <- sum(x > 100)
    features[4,b,6] <- max(x)/sum(x)
    features[4,b,7] <- length(x)
    features[4,b,8] <- max(x)
    
    x.vals <- log(x, base = 10)
    y.vals <- cumsum(x)/sum(x)
    
    lines(x.vals, y.vals, col = kunkel.equip.col, lwd = lwd.val)
    
    files <- list.files(paste0(base.dir, "basin_level/", basins[b]))
    files <- files[grepl("kunkel", files)]
    
    x <- readRDS(paste0(base.dir, "basin_level/", basins[b], "/", files[2]))
    
    features[5,b,1] <- mean(x)
    features[5,b,2] <- var(x)
    features[5,b,3] <- skewness(x)
    features[5,b,4] <- kurtosis(x)
    features[5,b,5] <- sum(x > 100)
    features[5,b,6] <- max(x)/sum(x)
    features[5,b,7] <- length(x)
    features[5,b,8] <- max(x)
    
    x.vals <- log(x, base = 10)
    y.vals <- cumsum(x)/sum(x)
    
    lines(x.vals, y.vals, col = kunkel.site.col, lwd = lwd.val)
  }
  
  mtext(basin.names[b], line = 0.1, cex = basin.name.cex, adj = 0.05)
  box(lwd = lwd.val)
}

# legend("center", c("Williams et al. (2025)", "Sherwin et al. (2024)", "Kunkel et al. (2023) - Source", 
#                    "Kunkel et al. (2023) - 150m", "Brown et al. (2026)"), 
#        lwd = 7, col = c(williams.col, sherwin.col, kunkel.equip.col, kunkel.site.col, cobe.col),
#        bg = "#E2E2E2")

mtext("Cumulative percent of total emissions (%)", side = 2, outer = T, line = 1.25, cex = 0.8)
mtext("Methane emission rate (kg/hr)", side = 1, outer = T, line = 0, cex = 0.8)

dev.off()



round(t(features[,6,]), 1) # rows = features, cols = distributions
basin.names[6]




test <- features[,,6]
rownames(test) <- distribution.names
colnames(test) <- basin.names
round(test, 3)

mean.vals <- as.vector(features[,,1])
var.vals <- as.vector(features[,,2])
skew.vals <- as.vector(features[,,3])
kurtosis.vals <- as.vector(features[,,4])
n.large.vals <- as.vector(features[,,5])
top1.vals <- as.vector(features[,,6])
length.vals <- as.vector(features[,,7])
max.vals <- as.vector(features[,,8])



plot(length.vals, skew.vals, ylim = c(0,400))
l <- 1:1e5
lines(l, 0.5*(l-2)/sqrt(l-1))


plot(length.vals, kurtosis.vals, ylim = c(0,50000))
lines(l, 0.2*l-3)

plot(length.vals, skew.vals)
plot(length.vals, kurtosis.vals)
plot(length.vals, top1.vals)
plot(length.vals, max.vals)

plot(var.vals, skew.vals)
plot(length.vals, var.vals)
plot(length.vals, skew.vals)

#distribution, basin, feature

plot(features[2,,7], features[2, ,6], col = "orange",
     pch = 19, xlim = c(0,100000), ylim = c(0, 0.15))

# points(features[1,,7], features[1,,6], pch = 19, col = "blue")
# points(features[3,,7], features[3,,6], pch = 19, col = "forestgreen")
# points(features[4,,7], features[4,,6], pch = 19, col = "red")
# points(features[5,,7], features[5,,6], pch = 19, col = "purple")

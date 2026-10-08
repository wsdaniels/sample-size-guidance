if(!is.null(dev.list())){dev.off()}
rm(list = ls())
gc()

library(RColorBrewer)
library(scales)
library(fields)


zenodo.dir <- "/Users/wdaniels/Documents/papers/sampling_zenodo/"


##### SAMPLE SIZE FIGURE


forward_ma <- function(x, n){
  sapply(seq_along(x), function(i){
    end <- min(i + n, length(x))
    mean(x[i:end])
  })
}

centered_ma <- function(x, n){
  sapply(seq_along(x), function(i){
    start <- max(1, i - n)
    end   <- min(length(x), i + n)
    mean(x[start:end])
  })
}

cols <- brewer.pal(8, "Dark2")[1:6]
cols[5] <- "gray20"

basins <- list.files(paste0(zenodo.dir, "data_level_5/metrics/basin_level"))

sherwin <- williams <- kunkel.equip <- kunkel.site <- cobe <- vector(mode = "list", length = length(basins))
names(sherwin) <- names(williams) <- names(kunkel.site) <- names(kunkel.equip) <- names(cobe) <- basins
for (i in 1:length(basins)){
  williams[[i]]$average <- readRDS(paste0(zenodo.dir, "data_level_5/metrics/basin_level/", basins[i], "/williams_mean.rds"))
  sherwin[[i]]$average <- readRDS(paste0(zenodo.dir, "data_level_5/metrics/basin_level/", basins[i], "/sherwin_mean.rds"))
  if (i == 3){
    cobe[[i]]$average <- readRDS(paste0(zenodo.dir, "data_level_5/metrics/basin_level/", basins[i], "/cobe_mean.rds"))
  }
  if (i == 4){
    kunkel.equip[[i]]$average <- readRDS(paste0(zenodo.dir, "data_level_5/metrics/basin_level/", basins[i], "/kunkel-equip_mean.rds"))
    kunkel.site[[i]]$average <- readRDS(paste0(zenodo.dir, "data_level_5/metrics/basin_level/", basins[i], "/kunkel-site_mean.rds"))
  }
}
data <- list(williams = williams, sherwin = sherwin, cobe = cobe, kunkel.equip = kunkel.equip, kunkel.site = kunkel.site)
metrics <- names(data[[1]][[1]][[1]])
rm(sherwin, williams, cobe, kunkel.equip, kunkel.site)


legend.names <- c("Appalach.", "Barnette", "Denver", "Permian", "San Joaq.", "Uinta")

levels <- vector(mode = "list", length = length(metrics))
for (m in 1:length(metrics)){
  if (m == 1)      {levels[[m]] <- c(-1, -3, -5) }
  else if (m == 2) {levels[[m]] <- c(25, 50, 100)     }
  else             {levels[[m]] <- 0.95                }
}

# ARRAY DIMS: BASIN, LEVELS
tmp <- vector(mode = "list", length = length(metrics))
for (m in 1:length(metrics)){
  tmp[[m]] <- array(NA, dim = c(length(legend.names), length(levels[[m]])))
}
ss <- list(williams = tmp, sherwin = tmp, cobe = tmp, kunkel.equip = tmp, kunkel.site = tmp)

if (!all(names(ss) == names(data))){
  print("ERROR: SS DISTRIBUTION ORDER DOES NOT MATCH DATA DISTRIBUTION ORDER")
}


lwd.val <- 5
xlim.start.vals <- c(0, 0.1)
xlim.end.vals   <- c(0.1, 1)

ylim.vals <- vector(mode = "list", length = length(metrics))
for (m in 1:length(metrics)){
  if (m == 1)      {ylim.vals[[m]] <- c(-95, 5)  }
  else if (m == 2) {ylim.vals[[m]] <- c(0, 1000) }
  else             {ylim.vals[[m]] <- c(0,1)     }
}

ytick.vals <- vector(mode = "list", length = length(metrics))
for (m in 1:length(metrics)){
  ytick.vals[[m]] <- seq(ylim.vals[[m]][1], ylim.vals[[m]][2], length.out = 6)
}

plot.titles = list("Median error in the sample mean (% of true mean)",
                   "Maximum error in the sample mean (% of true mean)",
                   "Probability of sample mean being within 10% of true mean",
                   "Probability of sample mean being within 20% of true mean",
                   "Probability of sample mean being within 30% of true mean",
                   "Probability of sample mean being within 40% of true mean",
                   "Probability of sample mean being within 50% of true mean",
                   "Probability of sample mean being within 60% of true mean",
                   "Probability of sample mean being within 70% of true mean",
                   "Probability of sample mean being within 80% of true mean",
                   "Probability of sample mean being within 90% of true mean",
                   "Probability of sample mean being within 100% of true mean")


for (m in 1:length(metrics)){ # Loop over metrics to plot
  
  png(paste0('../figures/metrics_', metrics[m], '.png'),
      width = 1920, height = 1080, res = 100, pointsize = 28)
  
  par(mfrow = c(1,2))
  par(mgp = c(2,0.95, 0))
  par(oma = c(3, 2, 1, 1))
  
  for (p in 1:2){ # Loop to make the double plots
    
    if (p == 1){ par(mar = c(0, 1,   0.5, 0.1)) 
    } else { par(mar = c(0, 0.1, 0.5, 0  )) }
    
    plot(1,1, col = "white", ylim = ylim.vals[[m]], ylab = "", yaxt = "n", xaxt = "n",
         xlim = c(xlim.start.vals[p], xlim.end.vals[p]), xaxs = "i", yaxs = "i")
    
    if (m == 1){
      abline(h = 0, lwd = lwd.val)
      if ( p == 1){
        axis(side = 2, at = 0, , lwd = lwd.val, las = 2)
      }
    }
    
    for (b in 1:length(basins)){ # Loop over basins
      
      for (d in 1:length(data)){ # Loop of reference distributions
        
        x <- seq_along(data[[d]][[b]]$average[[1]])
        if (length(x) == 0){next}
        
        x <- x/max(x)
        y <- data[[d]][[b]]$average[[m]]
        
        #### Smoothing
        y.smooth <- centered_ma(y, length(y)*0.001)
        ####
        
        lines(x, y, lwd = 1, lty = 1, col = alpha(cols[b], 0.25))
        
        if (names(data)[d] == "sherwin"){
          lines(x, y.smooth, lwd = lwd.val, col = cols[b], lty = 1)  
        } else if (names(data)[d] == "williams"){
          lines(x, y.smooth, lwd = lwd.val, col = cols[b], lty = 3)  
        } else if (names(data)[d] == "cobe"){
          lines(x, y.smooth, lwd = lwd.val, col = cols[b], lty = 2)
        } else if (names(data)[d] == "kunkel.equip"){
          lines(x, y.smooth, lwd = lwd.val, col = cols[b], lty = 4)  
        } else if (names(data)[d] == "kunkel.site"){
          lines(x, y.smooth, lwd = lwd.val, col = cols[b], lty = 5)  
        }
        
        
        for (i in 1:length(levels[[m]])){ # Loop over levels
          
          if (m == 2) { ss[[d]][[m]][b, i] <- x[min(which(y.smooth <= levels[[m]][i]))] 
          } else { ss[[d]][[m]][b, i] <- x[min(which(y.smooth >= levels[[m]][i]))] }
          
          
        } # End loop over levels
      } # End loop over reference distributions
      
      # Make outer lines thicker
      if (b == 1 & p == 1){
        axis(side = 2, at = seq(-1e10,1e10, length.out = 2), lwd = lwd.val)
        axis(side = 3, at = seq(-1e10,1e10, length.out = 2), lwd = lwd.val)
        axis(side = 1, at = seq(0,0.1, by = 0.02), lwd = lwd.val)
      } else if (b == 1 & p == 2) {
        axis(side = 3, at = seq(-1e10,1e10, length.out = 2), lwd = lwd.val)
        axis(side = 4, at = seq(-1e10,1e10, length.out = 2), lwd = lwd.val)
        axis(side = 1, at = seq(0.2, 1, by = 0.1), lwd = lwd.val)
        axis(side = 1, at = c(0.1,100), lwd = lwd.val, labels = c("", ""))
      }
      # Y axis tick labels
      if (b == 1 & p == 1){
        axis(side = 2, lwd = lwd.val, las = 2, at = ytick.vals[[m]], labels = round(ytick.vals[[m]],2))
      }
      
      if (p == 1 & m == 3){ legend("topleft", c("Williams et al. (2025)", "Sherwin et al. (2024)", "Brown et al. (2025)",
                                                "Kunkel et al. (2023) Source-Level", "Kunkel et al. (2023) 150 m"), 
                                   lty = c(3,1,2,4,5), lwd = 3, bty = "n") }
      
    } # End loop over basins
  } # End loop to make double plots
  
  if (m == 2){         legend("topright",    legend.names, lwd = 5, col = cols, bty = "n") 
  } else if (m == 3) { legend("bottomright", legend.names, lwd = 5, col = cols, bty = "n") 
  } else {             legend("right",       legend.names, lwd = 5, col = cols, bty = "n") }
  
  if (m == 2){legend("right", c("Williams et al. (2025)", "Sherwin et al. (2024)", "Brown et al. (2025)",
                                "Kunkel et al. (2023) Source-Level", "Kunkel et al. (2023) 150 m"), 
                     lty = c(3,1,2,4,5), lwd = 3, bty = "n")
  } else if (m != 3){ legend("bottomright", c("Williams et al. (2025)", "Sherwin et al. (2024)", "Brown et al. (2025)",
                                              "Kunkel et al. (2023) Source-Level", "Kunkel et al. (2023) 150 m"), 
                             lty = c(3,1,2,4,5), lwd = 3, bty = "n") }
  
  mtext("Fraction of distribution sampled", side = 1, outer = T, line = 2)
  mtext(plot.titles[[m]], side = 3, adj = 0.05, outer = T, cex = 1.2)
  
  dev.off()
  
  
} # End loop over metrics




library(moments)
library(lmom)

calc_features <- function(x){
  x <- x[!is.na(x)]
  
  n_large <- log(sum(x>100), base = 10)
  top1 <- ifelse(sum(x)==0, 0, max(x)/sum(x))
  
  c(n_large = n_large, top1 = top1)
}
feature_names <- c("n_large", "top1")
n.features <- length(feature_names)

base.dir <- paste0(zenodo.dir, "data_level_3/x_vectors/basin_level/")
basins <- list.files(base.dir)

features <- list(williams =     vector(mode = "list", length = length(basins)),
                 sherwin =      vector(mode = "list", length = length(basins)),
                 cobe =         vector(mode = "list", length = length(basins)),
                 kunkel.equip = vector(mode = "list", length = length(basins)),
                 kunkel.site =  vector(mode = "list", length = length(basins)))

for (i in 1:length(features)){ names(features[[i]]) <- basins }

for (d in 1:length(features)){
  dist.name <- names(features)[d]
  for (b in 1:length(basins)){
    files <- list.files(paste0(base.dir, basins[b]))
    files <- files[grepl(dist.name, files)]
    if (length(files) == 0){next}
    features[[d]][[b]] <- matrix(NA, nrow = length(files), ncol = n.features)
    
    for (i in 1:length(files)){
      this.x <- readRDS(paste0(base.dir, basins[b], "/", files[i]))
      features[[d]][[b]][i, ] <- calc_features(this.x)
    }
  }
}


features <- lapply(features, function(X) lapply(X, function(Y) Y[ifelse(nrow(Y)>1, 2, 1),]))
features <- lapply(features, function(sublist) {
  lapply(sublist, function(x) {
    if (is.null(x)) c(NA, NA) else x
  })
})
features <- lapply(features, function(X) do.call(rbind, X))

for (i in 1:length(features)){ rownames(features[[i]]) <- paste0(rownames(features[[i]]), "_", names(features)[i]) }

X <- do.call(rbind, features)
colnames(X) <- feature_names

y <- matrix(nrow = nrow(X), ncol = 3)
y[,1] <- c(ss$williams[[1]][ ,1], ss$sherwin[[1]][ ,1], ss$cobe[[1]][ ,1], ss$kunkel.equip[[1]][ ,1], ss$kunkel.site[[1]][ ,1]) # median error within -1%
y[,2] <- c(ss$williams[[2]][ ,1], ss$sherwin[[2]][ ,1], ss$cobe[[2]][ ,1], ss$kunkel.equip[[2]][ ,1], ss$kunkel.site[[2]][ ,1]) # max error within 25%
y[,3] <- c(ss$williams[[3]][ ,1], ss$sherwin[[3]][ ,1], ss$cobe[[3]][, 1], ss$kunkel.equip[[3]][ ,1], ss$kunkel.site[[3]][ ,1]) # 95% chance error within 10%
colnames(y) <- c("median_error", "max_error", "error_within_10")
rownames(y) <- rownames(X)

r.vals <- p.vals <- sign.vals <- matrix(NA, nrow = ncol(X), ncol = ncol(y))
pch.vals <- vector(length = nrow(X))
pch.vals[grepl("williams", rownames(X))] <- 21 # Circle
pch.vals[grepl("sherwin", rownames(X))] <- 24 # Upward pointing triangle
pch.vals[grepl("cobe", rownames(X))] <- 25 # Downward pointing triangle
pch.vals[grepl("kunkel.equip", rownames(X))] <- 22 # Square
pch.vals[grepl("kunkel.site", rownames(X))] <- 23 # Diamond


# (Williams, Sherwin, cobe, Kunkel Equip, Kunkel Site)
pch.list <- list(21, 24, 25, 22, 23)
lty.list <- list(2, 1, 3, 3, 3)
vert.list <- list((1:6) - 0.2, (1:6) + 0.2, (1:6), (1:6) + 0.1, (1:6) - 0.1)



png('../figures/basin_summary_stats.png',
    width = 1920, height = 1080*1.45, res = 100, pointsize = 34)

par(mgp = c(3, 0.66, 0))
par(mar = c(2, 2.7, 1.2, 0.7))
par(oma = c(2, 1.8, 1, 0))

layout.mat <- matrix(c(1,1,2,3,
                       4,4,5,6,
                       7,7,8,9), ncol = 4, byrow = T)
layout(layout.mat)

cex.val <- 0.9
pt.lwd.val <- 4
new.lwd.val <- 4
alpha.val <- 0.1
mtext.cex <- 0.75
title.cex <- 0.675
legend.cex <- 0.9
text.adj <- 0.06

bg.cols <- c("gray90", "white", "gray90", "white", "gray90", "white")

col.vals <- list(rev(viridis(8))[c(2, 4, 8)],
                 rev(magma(8))[c(2, 4, 6)],
                 rev(mako(10))[c(3, 6, 8)])

metric.ind <- c(3, 5, 7) # 10, 30, 50

for (k in 1:3){
  
  cols <- col.vals[[k]]
  this.order <- order(ss$sherwin[[k]][,1])
  
  plot(1,1, col = "white", xlim = c(0,1), ylim = c(0.7, 6.3), xlab = "", ylab = "", xaxt = "n", yaxt = "n")
  axis(side = 1, at = seq(0, 1, 0.2), lwd.ticks = lwd.val)
  axis(side = 2, at = 1:6, labels = rep("", 6), lwd.ticks = lwd.val)
  
  rect(xleft = -1, xright = 2, ybottom = 0.5, ytop = 1.5, col = alpha("black", alpha.val), border = NA)
  rect(xleft = -1, xright = 2, ybottom = 2.5, ytop = 3.5, col = alpha("black", alpha.val), border = NA)
  rect(xleft = -1, xright = 2, ybottom = 4.5, ytop = 5.5, col = alpha("black", alpha.val), border = NA)
  
  if (k %in% c(1,2)){
    for (d in 1:length(pch.list)){
      segments(x0 = rep(0, 6),                           y0 = vert.list[[d]], x1 = ss[[d]][[k]][this.order,3], col = cols[3], lwd = new.lwd.val, lty = lty.list[[d]])
      segments(x0 = ss[[d]][[k]][this.order,3], y0 = vert.list[[d]], x1 = ss[[d]][[k]][this.order,2], col = cols[2], lwd = new.lwd.val, lty = lty.list[[d]])
      segments(x0 = ss[[d]][[k]][this.order,2], y0 = vert.list[[d]], x1 = ss[[d]][[k]][this.order,1], col = cols[1], lwd = new.lwd.val, lty = lty.list[[d]])
      
      points(ss[[d]][[k]][this.order,1], vert.list[[d]], col = cols[1], pch = pch.list[[d]], cex = cex.val, lwd = pt.lwd.val, bg = bg.cols, lty = lty.list[[d]])
      points(ss[[d]][[k]][this.order,2], vert.list[[d]], col = cols[2], pch = pch.list[[d]], cex = cex.val, lwd = pt.lwd.val, bg = bg.cols, lty = lty.list[[d]])
      points(ss[[d]][[k]][this.order,3], vert.list[[d]], col = cols[3], pch = pch.list[[d]], cex = cex.val, lwd = pt.lwd.val, bg = bg.cols, lty = lty.list[[d]])
    }
  } else {
    for (d in 1:length(pch.list)){
      segments(x0 = rep(0, 6),                            y0 = vert.list[[d]], x1 = ss[[d]][[metric.ind[3]]][this.order], col = cols[3], lwd = new.lwd.val, lty = lty.list[[d]])
      segments(x0 = ss[[d]][[metric.ind[3]]][this.order], y0 = vert.list[[d]], x1 = ss[[d]][[metric.ind[2]]][this.order], col = cols[2], lwd = new.lwd.val, lty = lty.list[[d]])
      segments(x0 = ss[[d]][[metric.ind[2]]][this.order], y0 = vert.list[[d]], x1 = ss[[d]][[metric.ind[1]]][this.order], col = cols[1], lwd = new.lwd.val, lty = lty.list[[d]])
      
      points(ss[[d]][[metric.ind[1]]][this.order], vert.list[[d]], col = cols[1], pch = pch.list[[d]], cex = cex.val, lwd = pt.lwd.val, bg = bg.cols, lty = lty.list[[d]])
      points(ss[[d]][[metric.ind[2]]][this.order], vert.list[[d]], col = cols[2], pch = pch.list[[d]], cex = cex.val, lwd = pt.lwd.val, bg = bg.cols, lty = lty.list[[d]])
      points(ss[[d]][[metric.ind[3]]][this.order], vert.list[[d]], col = cols[3], pch = pch.list[[d]], cex = cex.val, lwd = pt.lwd.val, bg = bg.cols, lty = lty.list[[d]])
    }
  }
  
  axis(side = 2, at = 1:6, labels = legend.names[this.order], las = 2)
  box(lwd = lwd.val)
  
  # legend("bottomright", c("Sherwin et al.", "Brown et al.", 
  #                         "Kunkel et al. 150m", "Kunkel et al. Source",
  #                         "Williams et al."),
  #        lty = c(1,3,3,2), lwd = lwd.val,
  #        inset = c(0.15, 0.1), box.lwd = lwd.val)
  
  for (j in 1:ncol(X)){ # Start loop over predictors
    
    data.mat <- data.frame(cbind(y[,k], X[,j]))
    colnames(data.mat) <- c("y", "x")
    
    this.fit <- lm(y~x, data.mat)
    
    new.data <- data.frame(x = seq(min(data.mat$x, na.rm = T), max(data.mat$x, na.rm = T), length.out = 100))
    ci <- predict(this.fit, newdata = new.data, interval = "confidence")
    
    r.vals[j,k] <- summary(this.fit)$r.squared
    p.vals[j,k] <- coef(summary(this.fit))[2,4]
    sign.vals[j,k] <- paste(paste0(round(coef(this.fit), 3)), collapse = "  ")
    
    width <- max(X[,j],na.rm=T)-min(X[,j],na.rm=T)
    plot(X[,j], y[,k],
         xaxt = "n",
         ylim = c(0,1), yaxt = "n",
         xlim = c(min(X[,j],na.rm=T)-width*0.05, max(X[,j],na.rm=T)+width*0.05),
         pch = pch.vals, lwd = pt.lwd.val, main = "")
    polygon(c(new.data$x, rev(new.data$x)), c(ci[,"lwr"], rev(ci[,"upr"])),
            col = alpha("black", 0.15), border = NA)
    fit.pred <- predict(this.fit, newdata = new.data)
    lines(new.data$x, fit.pred, col = cols, lwd = lwd.val)
    points(X[,j], y[,k], pch = pch.vals, lwd = pt.lwd.val)
    
    if (j == 1){
      axis(side = 1, at = c(1, 1.5, 2, 2.5), lwd.tick = lwd.val) # n_large
      axis(side = 2, at = seq(0,1,0.2), las =2 , lwd.tick = lwd.val)
    } else {
      this.seq <- seq(0.02, 0.1, length.out = 3) # top1
      axis(side =1, at = this.seq, labels = round(this.seq, 2), lwd.tick = lwd.val)
    }
    box(lwd = lwd.val)
    
  } # End loop over predictors
} # End loop over metrics

dev.off()






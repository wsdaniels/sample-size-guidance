rm(list = ls())

library(foreach)
library(doParallel)

set.seed(1)

base.dir <- '/Users/wdaniels/Documents/papers/sampling/'

save.dir <- paste0(base.dir, 'data_level_5/metrics/basin_level/denver_julesburg/')


######### HEATMAPS

x <- readRDS(paste0(base.dir, 'data_level_3/x_vectors/basin_level/denver_julesburg/sherwin_mean.rds'))
n <- length(x)
x <- x[-n]

p.vals <- seq(0.035, 0.1575, by = 0.0025)
y.vals <- p.vals*sum(x)/(1-p.vals)

n.sample.sizes <- 3000
sample.sizes <- round(seq(1, n, length.out = n.sample.sizes))

big.out <- vector(mode = "list", length = length(y.vals))

for (a in 1:length(y.vals)){
  
  print(paste0(a, "/", length(y.vals)))
  
  x.tmp <- c(x, y.vals[a])
  
  sample.means <- readRDS(paste0(base.dir, 'data_level_4/sample_means/basin_level/denver_julesburg/sherwin_mean_heatmap', a, ".rds"))

  true.mean <- mean(x.tmp)
  err <- 100 * (sample.means - true.mean) / true.mean
  
  err <- err[,sample.sizes]
  
  big.out[[a]] <- list(median    = apply(err, 2, function(X) median(X)),
                       max.error = apply(err, 2, function(X) max(X)),
                       within10  = apply(err, 2, function(X) sum(abs(X) < 10)/length(X)),
                       sample.sizes = sample.sizes,
                       p.vals = p.vals)
  
  
  
}

saveRDS(big.out, paste0(save.dir, "sherwin_mean_heatmap.rds"))

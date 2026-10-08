rm(list = ls())

library(foreach)
library(doParallel)

set.seed(1)

R <- 1250 # Number of replicates
n.cores <- 6

zenodo.dir <- '/Users/wdaniels/Documents/papers/sampling_zenodo/' # CHANGE THIS

######### HEATMAPS

x <- readRDS(paste0(zenodo.dir, 'data_level_3/x_vectors/basin_level/denver_julesburg/sherwin_mean.rds'))
n <- length(x)
x <- x[-n]

p.vals <- seq(0.035, 0.1575, by = 0.0025)
y.vals <- p.vals*sum(x)/(1-p.vals)

for (a in 1:length(p.vals)){
  
  print(paste0(a, "/", length(y.vals)))
  
  x.tmp <- c(x, y.vals[a])
  
  cl <- makeCluster(n.cores)
  registerDoParallel(cl)
  
  sample.means <- foreach(r = 1:R, .combine = rbind, .packages = "stats") %dopar% {
    
    this.replicate <- vector(length = n)
    for (s in 1:n) {
      this.replicate[s] <- mean(sample(x.tmp, size = s, replace = FALSE))
    }
    this.replicate
  }
  
  stopCluster(cl)
  
  saveRDS(sample.means, paste0(zenodo.dir,
                               'data_level_4/sample_means/basin_level/denver_julesburg/',
                               "sherwin_mean_heatmap", a, ".rds"))
  
}


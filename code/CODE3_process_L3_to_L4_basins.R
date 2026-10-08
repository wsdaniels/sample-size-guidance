rm(list = ls())

library(foreach)
library(doParallel)

set.seed(1)

R <- 1250 # Number of replicates
n.cores <- 6

zenodo.dir <- '/Users/wdaniels/Documents/papers/sampling_zenodo/' # CHANGE THIS

######### BASIN SAMPLE MEANS

base.dir <- paste0(zenodo.dir, 'data_level_3/x_vectors/basin_level/')
save.dir <- paste0(zenodo.dir, 'data_level_4/sample_means/basin_level/')

basins <- list.files(base.dir)

for (b in 1:length(basins)){
  
  files <- list.files(paste0(base.dir, basins[b]))
  
  for (a in 1:length(files)){
    
    print(paste0(b, "/", length(basins), " - ", a, "/", length(files)))
    
    x <- readRDS(paste0(base.dir, basins[b], "/", files[a]))
    n <- length(x)
    
    cl <- makeCluster(n.cores)
    registerDoParallel(cl)
    
    sample.means <- foreach(r = 1:R, .combine = rbind, .packages = "stats") %dopar% {
      
      this.replicate <- vector(length = n)
      for (s in 1:n) {
        this.replicate[s] <- mean(sample(x, size = s, replace = FALSE))
      }
      this.replicate
    }
    
    stopCluster(cl)
    
    saveRDS(sample.means, paste0(save.dir, basins[b], "/", files[a]))
    
  }
}


rm(list = ls())

library(foreach)
library(doParallel)

set.seed(1)

R <- 1250 # Number of replicates
n.cores <- 64


######### BASIN SAMPLE MEANS

base.dir <- '/glade/work/wdaniels/sampling/data_level_3/x_vectors/basin_level/'
save.dir <- '/glade/work/wdaniels/sampling/data_level_4/sample_means/basin_level/'

basins <- list.files(base.dir)

for (b in 5:6){
  
  files <- list.files(paste0(base.dir, basins[b]))
  
  for (a in 1:length(files)){
    
    print(paste0(b, "/", length(basins), " - ", a, "/", length(files)))
    
    x <- readRDS(paste0(base.dir, basins[b], "/", files[a]))
    n <- length(x)
    
    cl <- makeCluster(n.cores)
    registerDoParallel(cl)
    
    # --- Parallel (r, s) grid ---
    # We evaluate each row of the matrix as one parallel job
    # total jobs = R * n
    sample.means <- foreach(r = 1:R, .combine = rbind, .packages = "stats") %dopar% {
      # For this replicate r, compute means at all sample sizes
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


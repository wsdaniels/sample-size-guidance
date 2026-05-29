rm(list = ls())

library(foreach)
library(doParallel)

set.seed(1)

R <- 1250 # Number of replicates
n.cores <- 64

save.dir <- '/glade/work/wdaniels/sampling/data_level_4/sample_means/basin_level/denver_julesburg/'


######### HEATMAPS

x <- readRDS('/glade/work/wdaniels/sampling/data_level_3/x_vectors/basin_level/denver_julesburg/sherwin_mean.rds')
n <- length(x)
x <- x[-n]

p.vals <- seq(0.035, 0.1575, by = 0.0025)
y.vals <- p.vals*sum(x)/(1-p.vals)

for (a in 31:40){
  
  print(paste0(a, "/", length(y.vals)))
  
  x.tmp <- c(x, y.vals[a])
  
  cl <- makeCluster(n.cores)
  registerDoParallel(cl)
  
  # --- Parallel (r, s) grid ---
  # We evaluate each row of the matrix as one parallel job
  # total jobs = R * n
  sample.means <- foreach(r = 1:R, .combine = rbind, .packages = "stats") %dopar% {
    # For this replicate r, compute means at all sample sizes
    this.replicate <- vector(length = n)
    for (s in 1:n) {
      this.replicate[s] <- mean(sample(x.tmp, size = s, replace = FALSE))
    }
    this.replicate
  }
  
  stopCluster(cl)
  
  saveRDS(sample.means, paste0(save.dir, "sherwin_mean_heatmap", a, ".rds"))
  
}


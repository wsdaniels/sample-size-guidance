rm(list = ls())

library(foreach)
library(doParallel)

set.seed(1)

base.dir <- '/Users/wdaniels/Documents/papers/sampling/data_level_4/sample_means/basin_level/'
basins <- list.files(base.dir)

for (d in c("sherwin", "williams", "cobe", "kunkel-equip", "kunkel-site")){
  
  for (b in 1:length(basins)){
    
    print(paste0(b, "/", length(basins)))
    
    files <- list.files(paste0('/Users/wdaniels/Documents/papers/sampling/data_level_3/x_vectors/basin_level/', basins[b], "/"))
    files <- files[grepl(d, files)]
    files <- files[grepl("mean", files)]
    
    if (length(files) == 0){ next }
    
    x <- readRDS(paste0('/Users/wdaniels/Documents/papers/sampling/data_level_3/x_vectors/basin_level/', basins[b], "/", files[1]))
    sample.means <- readRDS(paste0(base.dir, basins[b], '/', d, '_mean.rds'))
    
    true.mean <- mean(x)
    err <- 100 * (sample.means - true.mean) / true.mean
    
    to.save <- list(median    = apply(err, 2, function(X) median(X)),
                    max.error = apply(err, 2, function(X) max(X)),
                    within10  = apply(err, 2, function(X) sum(abs(X) < 10)/length(X)),
                    within20  = apply(err, 2, function(X) sum(abs(X) < 20)/length(X)),
                    within30  = apply(err, 2, function(X) sum(abs(X) < 30)/length(X)),
                    within40  = apply(err, 2, function(X) sum(abs(X) < 40)/length(X)),
                    within50  = apply(err, 2, function(X) sum(abs(X) < 50)/length(X)),
                    within60  = apply(err, 2, function(X) sum(abs(X) < 60)/length(X)),
                    within70  = apply(err, 2, function(X) sum(abs(X) < 70)/length(X)),
                    within80  = apply(err, 2, function(X) sum(abs(X) < 80)/length(X)),
                    within90  = apply(err, 2, function(X) sum(abs(X) < 90)/length(X)),
                    within100 = apply(err, 2, function(X) sum(abs(X) < 100)/length(X)))
    
    saveRDS(to.save, paste0('/Users/wdaniels/Documents/papers/sampling/data_level_5/metrics/basin_level/', basins[b], "/", d, "_mean.rds"))
    
  }
}




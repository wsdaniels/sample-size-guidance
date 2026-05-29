rm(list = ls())

set.seed(1)

max.length <- 100000 # sample emission rate distributions down to this length

####### BASIN-LEVEL X-VECTORS

base.dir <- '/Users/wdaniels/Documents/papers/sampling/'
basins <- list.files(paste0(base.dir, "data_level_2/basin_level"))

for (b in 1:length(basins)){
  
  # Williams must go first because it is used to supplement kunkel and cobe distributions
  for (d in c("williams", "sherwin", "kunkel-equip", "kunkel-site", "cobe")){
    
    print(paste0(b, "/", length(basins)))
    
    files <- list.files(paste0(base.dir, "data_level_2/basin_level/", basins[b]))
    files <- files[grepl(d, files)]
    
    if (length(files) == 0){next}
    
    if (d == "williams"){
      x <- readRDS(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[1]))
    } else if (d == "sherwin") {
      x <- read.csv(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[1]))
      x <- x$Emission.magnitude..kgh.
    } else if (grepl("kunkel", d)){
      x <- read.csv(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[1]))
      x <- x$qBarKgPerHour
    } else if (d == "cobe"){
      x <- read.csv(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[1]))
      x <- x[x$NEW_BASIN == "DJ",]
      x <- x$Emission_rate_kg_h
    }
    this.length <- min(length(x), max.length)
    
    running.values <- matrix(NA, nrow = length(files), ncol = this.length)
    for (a in 1:length(files)){
      if (d == "williams"){
        x <- readRDS(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[a]))
      } else if (d == "sherwin") {
        x <- read.csv(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[a]))
        x <- x$Emission.magnitude..kgh.
      } else if (grepl("kunkel", d)){
        x <- read.csv(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[a]))
        x <- x$qBarKgPerHour
      } else if (d == "cobe"){
        x <- read.csv(paste0(base.dir, "data_level_2/basin_level/", basins[b], "/", files[a]))
        x <- x[x$NEW_BASIN == "DJ",]
        x <- x$Emission_rate_kg_h
      }
      if (length(x) > max.length){ x <- sample(x, size = max.length, replace = F) }
      x <- sort(x)
      running.values[a, ] <- x
    }
    
    x.mean <- apply(running.values, 2, mean)
    x.lower <- apply(running.values, 2, function(X) quantile(X, probs = 0.025))
    x.upper <- apply(running.values, 2, function(X) quantile(X, probs = 0.975))
    
    # Scale the amount of williams rates to add based on the ratio of >3/<3 from williams
    if (d == "williams"){
      williams.x.vals <- x.mean
    } else if (d == "sherwin"){
      sherwin.x.vals <- x.mean
    } else if (grepl("kunkel", d) | grepl("cobe", d)){
      
      williams.ratio.above.3 <- sum(williams.x.vals >= 3)/length(williams.x.vals)
      num.to.add <- round(sum(x.mean >= 3) / williams.ratio.above.3)
      x.mean <- sort(c(sample(williams.x.vals[williams.x.vals < 3], num.to.add, replace = F),
                       x.mean[x.mean >= 3]))
      
      # sherwin.ratio.above.3 <- sum(sherwin.x.vals >= 3)/length(sherwin.x.vals)
      # num.to.add <- round(sum(x.mean >= 3) / sherwin.ratio.above.3)
      # x.mean <- sort(c(sample(sherwin.x.vals[sherwin.x.vals < 3], num.to.add, replace = T),
      #                  x.mean[x.mean >= 3]))
    } 
    
    
    if (d == "williams"){
      saveRDS(x.mean, paste0(base.dir, 'data_level_3/x_vectors/basin_level/', basins[b], '/', d, '_mean.rds'))
      saveRDS(x.lower, paste0(base.dir, 'data_level_3/x_vectors/basin_level/', basins[b], '/', d, '_lower.rds'))
      saveRDS(x.upper, paste0(base.dir, 'data_level_3/x_vectors/basin_level/', basins[b], '/', d, '_upper.rds'))
    } else {
      saveRDS(x.mean, paste0(base.dir, 'data_level_3/x_vectors/basin_level/', basins[b], '/', d, '_mean.rds'))
    }
  }
}





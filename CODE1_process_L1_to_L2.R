rm(list = ls())

library(data.table)

# Mapping from basin name in filenames → directory name
basins <- list(
  Appalachian   = "appalachian",
  Barnett       = "barnette",
  Denver        = "denver_julesburg",
  Permian       = "permian",
  SanJoaquin    = "san_joaquin",
  Uinta         = "uinta"
)

for (b in names(basins)) {
  
  infile <- sprintf("/Users/wdaniels/Documents/papers/sampling/data_level_1/williams/20250723_%s_.csv", b)
  outdir <- sprintf("/Users/wdaniels/Documents/papers/sampling/data_level_2/basin_level/%s/", basins[[b]])
  
  for (i in 1:500){
    
    print(paste0(b, " - ", i, "/", 500))
    
    # Read a single column
    col <- fread(infile, select = i)[[1]]
    
    # Save as fast RDS
    outfile <- sprintf("%swilliams_%d.rds", outdir, i)
    saveRDS(col, outfile, compress = FALSE)
  }
}


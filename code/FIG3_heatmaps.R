
######### HEAT MAPS

rm(list = ls())

library(viridis)
library(scales)
library(moments)
library(fields)
library(lubridate)

set.seed(1)

lwd.val <- 4
example.sample.size <- 1000

x <- readRDS('/Users/wdaniels/Documents/papers/sampling/data_level_3/x_vectors/basin_level/denver_julesburg/sherwin_mean.rds')


big.out <- readRDS('/Users/wdaniels/Documents/papers/sampling/data_level_5/metrics/basin_level/denver_julesburg/sherwin_mean_heatmap.rds')
sample.sizes <- big.out[[1]]$sample.sizes/length(x)
p.vals <- big.out[[1]]$p.vals

median.mat <- lapply(big.out, function(X) X[[1]])
median.mat <- do.call(rbind, median.mat)

max.error.mat <- lapply(big.out, function(X) X[[2]])
max.error.mat <- do.call(rbind, max.error.mat)

within10.mat <- lapply(big.out, function(X) X[[3]])
within10.mat <- do.call(rbind, within10.mat)


lwd.val <- 5

png('/Users/wdaniels/Documents/papers/sampling/figures/heatmap_median.png',
    width = 900, height = 1080*0.65, res = 100, pointsize = 28)


par(mar = c(2,2,2,2))
par(mgp = c(3, 0.75, 0))

my.pal <- colorRampPalette(rev(c("#143d67",
                                 "#2166ACFF", 
                                 "#4393C3FF", 
                                 "#92C5DEFF", 
                                 "#D1E5F0FF", 
                                 "#F7F7F7FF", 
                                 "#FDDBC7FF", 
                                 "#F4A582FF", 
                                 "#D6604DFF",
                                 "#B2182BFF",
                                 "#6b0e1a")))


cutoff <- 18

median.mat.to.plot <- median.mat
median.mat.to.plot[median.mat.to.plot < -cutoff] <- -cutoff
median.mat.to.plot[median.mat.to.plot > cutoff] <- cutoff

n.colors <- 12
cols <- my.pal(n.colors)

image.plot(sample.sizes, p.vals, t(median.mat.to.plot), 
           lwd = lwd.val, 
           col = my.pal(n.colors),
           breaks = seq(-cutoff,cutoff, length.out = n.colors+1), 
           xlab = "", xaxt = 'n', yaxt = "n",
           axis.args = list(at = seq(-cutoff, cutoff, length.out = 5)))


abline(h = max(x)/sum(x), col = "gray45", lwd = lwd.val, lty = 2)

axis(side = 1, at = seq(0,1, by = 0.2), lwd = lwd.val, labels = seq(0,1, by = 0.2))
axis(side = 3, at = c(-100, 1e10), lwd = lwd.val)
axis(side = 4, at = c(-1000,1000), lwd = lwd.val)

ylim.vals <- c(seq(0, 0.15, by = 0.05))
axis(side = 2, at = ylim.vals, lwd = lwd.val, labels = round(ylim.vals, 2))



dev.off()



png('/Users/wdaniels/Documents/papers/sampling/figures/heatmap_max_error.png',
    width = 900, height = 1080*0.65, res = 100, pointsize = 28)

par(mar = c(2,2,2,2))
par(mgp = c(3, 0.75, 0))

my.pal <- colorRampPalette(rev(c("#f9fcd7",
                                 "#F7FEAEFF",
                                 "#B7E6A5FF",
                                 "#7CCBA2FF",
                                 "#46AEA0FF",
                                 "#089099FF",
                                 "#00718BFF",
                                 "#045275FF",
                                 "#01293b")))



max.error.mat.log <- log(max.error.mat, base = 10)
break.vals = seq(0,3, length.out = 10)
max.error.mat.log[max.error.mat.log < 0] <- 0
max.error.mat.log[max.error.mat.log > 3] <- 3

image.plot(sample.sizes, p.vals, t(max.error.mat.log),
           col = my.pal(length(break.vals)-1), 
           lwd = lwd.val, yaxt = "n", xaxt = "n", breaks = break.vals,
           axis.args = list(at = seq(0,3),
                            labels = c(expression(10^0),
                                       expression(10^1),
                                       expression(10^2),
                                       expression(10^3))))


abline(h = max(x)/sum(x), col = "gray60", lwd = lwd.val, lty = 2)

axis(side = 1, at = seq(0,1, by = 0.2), lwd = lwd.val, labels = seq(0,1, by = 0.2))
axis(side = 2, at= c(-100,100), lwd = lwd.val)
axis(side = 3, at = c(-100, 1e10), lwd = lwd.val)
axis(side = 4, at = c(-1000,1000), lwd = lwd.val)


dev.off()



png('/Users/wdaniels/Documents/papers/sampling/figures/heatmap_within10.png',
    width = 900, height = 1080*0.65, res = 100, pointsize = 28)

par(mar = c(2,2,2,2))
par(mgp = c(3, 0.75, 0))

my.pal <- colorRampPalette(rev(c(rep("#ddddd3", 1),
                                 rep("#C6C7B6FF", 1),
                                 rep("#BBA88AFF", 1),
                                 rep("#935933FF", 1),
                                 rep("#5C2C18FF", 1),
                                 rep("#331900", 1))))

break.vals = seq(0, 1, 0.1)

image.plot(sample.sizes, p.vals, t(within10.mat),
           breaks = break.vals,yaxt = "n",
           col = my.pal(length(break.vals)-1), lwd = lwd.val, xaxt = "n",
           axis.args = list(at = seq(0, 1, by = 0.2)))

abline(h = max(x)/sum(x), col = "gray60", lwd = lwd.val, lty = 2)


axis(side = 1, at = seq(0,1, by = 0.2), lwd = lwd.val, labels = seq(0,1, by = 0.2))
axis(side = 2, at= c(-100,100), lwd = lwd.val)
axis(side = 3, at = c(-100, 1e10), lwd = lwd.val)
axis(side = 4, at = c(-1000,1000), lwd = lwd.val)


dev.off()




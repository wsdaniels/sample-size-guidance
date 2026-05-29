rm(list = ls())

library(scales)

set.seed(1)

size <- 100000

x <- readRDS('/Users/wdaniels/Documents/papers/sampling/data_level_3/x_vectors/national_level/mean.rds')

lwd.val <- 4

png('/Users/wdaniels/Documents/papers/sampling/figures/toc1.png',
    width = 1920*0.7, height = 1080*0.75, res = 100, pointsize = 36)

cols <- c("#FED789FF",
          "#023743FF", 
          "#72874EFF",
          "#476F84FF", 
          "#A4BED5FF",
          "#453947FF")

par(mar = c(3,4,4,1))
par(mgp = c(3, 0.75, 0))

line<-par(lwd=lwd.val+0.1)

hist(x[x<50], xlim = c(0,50), breaks = 50, col = alpha(cols[3], 0.15), main = "", xaxt = "n", yaxt= "n", ylab = "",
     border = cols[3])

axis(side = 1, at = seq(0, 50, by = 10), lwd = lwd.val)

axis(side = 2, at = seq(0, 60000, by = 30000), labels = seq(0,60, by = 30), las = 2,
     lwd = lwd.val)

mtext("Count (thousands)", side = 2, line = 1.9)
mtext("Methane emission rate (kg/hr)", side = 1, line = 1.75)

dev.off()





png('/Users/wdaniels/Documents/papers/sampling/figures/toc2.png',
    width = 1920*0.5, height = 1080*0.5, res = 100, pointsize = 32)

cols <- c("#FED789FF",
          "#023743FF", 
          "#72874EFF",
          "#476F84FF", 
          "#A4BED5FF",
          "#453947FF")

par(mar = c(3,4,4,1))
par(mgp = c(3, 0.75, 0))

line<-par(lwd=lwd.val+0.1)

log.x <- log(x, base = 10)
log.x[log.x < -3] <- NA
log.x[log.x > 3] <- NA

hist(log.x, breaks = 40, col = alpha(cols[4], 0.15), 
     main = "", xaxt = "n", yaxt = "n", ylab = "",
     xlim = c(-3, 3),
     border = cols[4])

axis(side = 1, at = seq(-3, 3),
     labels = c(expression(10^-3),
                expression(10^-2),
                expression(10^-1),
                expression(10^0),
                expression(10^1),
                expression(10^2),
                expression(10^3)),
     lwd = lwd.val)

axis(side = 2, at = seq(0,6000, by = 3000), labels = seq(0,6, by = 3), las = 2, lwd = lwd.val)

dev.off()


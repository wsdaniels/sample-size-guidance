rm(list = ls())

library(viridis)
library(scales)
library(moments)
library(fields)
library(lubridate)

set.seed(1)

lwd.val <- 4
example.sample.size <- 200

x <- readRDS('/Users/wdaniels/Documents/papers/sampling/data_level_3/x_vectors/basin_level/denver_julesburg/sherwin_mean.rds')

second.largest <- sort(x, decreasing = T)[2]

set.seed(8500)
s1 <- sample(x, size = example.sample.size)

set.seed(9785)
s2 <- sample(x, size = example.sample.size)

set.seed(6770)
s3 <- sample(x, size = example.sample.size)

mean(x)
mean(s1)
mean(s2)
mean(s3)

break.vals <- seq(-10, 10, by = 0.5)

x.log <- log(x, base = 10)
s1.log <- log(s1, base = 10)
s2.log <- log(s2, base = 10)
s3.log <- log(s3, base = 10)

x.log[is.infinite(x.log)] <- NA
s1.log[is.infinite(s1.log)] <- NA
s2.log[is.infinite(s2.log)] <- NA
s3.log[is.infinite(s3.log)] <- NA

x.log[x.log < -3] <- NA
s1.log[s1.log < -3] <- NA
s2.log[s2.log < -3] <- NA
s3.log[s3.log < -3] <- NA

h.x <- hist(x.log, plot = F, breaks = break.vals)
h.s1 <- hist(s1.log, plot = F, breaks = break.vals)
h.s2 <- hist(s2.log, plot = F, breaks = break.vals)
h.s3 <- hist(s3.log, plot = F, breaks = break.vals)

png('/Users/wdaniels/Documents/papers/sampling/figures/histograms.png',
    width = 1920/2, height = 1080*0.75, res = 100, pointsize = 24)

par(mgp = c(3,0.75,0))
par(mfrow = c(1,1))
par(mar = c(2,2,1,1))
line <- par(lwd=lwd.val)

hist.max <- 300
bin.size <- 20

cols <- c("#023743FF", "#FED789FF",  "#72874EFF","#A4BED5FF", "#476F84FF" , "#453947FF")

xlim.vals <- seq(-3,5)
plot(h.x, freq = F, xaxt = "n", col = NA, border = cols[1],
     xlim = range(xlim.vals),
     ylim = c(0, 0.6), main = "", lwd = lwd.val)
plot(h.s1, freq = F, xaxt = "n", col = NA, border = cols[2], add = T)
plot(h.s2, freq = F, xaxt = "n", col = NA, border = cols[3], add = T)
plot(h.s3, freq = F, xaxt = "n", col = NA, border = cols[4], add = T)

line<-par(lwd=lwd.val+0.1)
plot(h.x, freq = F, xaxt = "n", col = NA, border = cols[1], ylim = c(0, 0.5),
     main = "", add = T)

axis.break.vals <- seq(min(break.vals), max(break.vals), by = 1)

axis(side = 1, at = seq(-3,5), 
     labels = c(expression(10^-3),
                expression(10^-2),
                expression(10^-1),
                expression(10^0),
                expression(10^1),
                expression(10^2),
                expression(10^3),
                expression(10^4),
                expression(10^5)),
     lwd = lwd.val)

mean.vals <- c(log(mean(x), base = 10), 
               log(mean(s1), base = 10),
               log(mean(s2), base = 10),
               log(mean(s3), base = 10))

box()

col.vec <- c(cols[1], cols[2], cols[3], cols[4])
this.order <- order(mean.vals)

points(mean.vals[this.order], rep(-0.025, 4), 
       bg = "white",
       col = col.vec[this.order], cex = 1.1, lwd = 5,
       xpd = NA, pch = 24)

legend("topright", c("Population (n = 7,000)", "Sample 1 (n = 200)", "Sample 2 (n = 200)", "Sample 3 (n = 200)"),
       col = cols[1:4], lty = 1, lwd = 6,
       bty = "n")

legend("bottomright", c("Averages", "", "", ""),
       col = cols[1:4], pch = 2, bty = "n", inset = c(0.06, 0.45))


dev.off()



######### 2b

set.seed(1)

sample.means <- readRDS('/Users/wdaniels/Documents/papers/sampling/data_level_4/sample_means/basin_level/denver_julesburg/sherwin_mean.rds')

sample.sizes <- seq_along(x)

true.mean <- mean(x)
err <- 100 * (sample.means - true.mean) / true.mean

x.vals <- y.vals <- vector(length = nrow(err)*ncol(err))
for (n in 1:ncol(err)){
  this.mask <- seq((n-1)*nrow(err)+1, n*nrow(err))
  x.vals[this.mask] <- rep(sample.sizes[n]/length(x), nrow(err))
  y.vals[this.mask] <- err[,n]
}

mat <- cbind(x.vals, y.vals)

n.grid <- 200

ny <- (60-(-60))/n.grid
nx <- (1-0)/n.grid

grid.list <- list(x = seq(0, 1, by = nx),
                  y = seq(-100,ceiling(max(err, na.rm = T)), by = ny))

disc.image <- discretize.image(mat, grid = grid.list)

z.tmp <- log(disc.image$hist, base = 10)
z.tmp[is.infinite(z.tmp)] <- NA

out <- list(x = disc.image$grid$x, y = disc.image$grid$y, z = z.tmp)

median.line <- apply(err, 2, median)
mean.line <- apply(err, 2, mean)



ratio.val <- 0.5
round(quantile(err[,round(n*ratio.val)], probs = c(0.025, 0.975)), 1)
round(range(err[,round(n*ratio.val)]), 1)
midpoint <- sample.means[,round(n*ratio.val)]
round(sum((midpoint < true.mean))/length(midpoint), 2)


size.val <- 200
round(quantile(err[,size.val], probs = c(0.025, 0.975)), 1)
round(range(err[,size.val]), 1)
midpoint <- sample.means[,size.val]
round(sum((midpoint < true.mean))/length(midpoint), 2)




png('/Users/wdaniels/Documents/papers/sampling/figures/heatmap_sample_means.png',
    width = 1920/2, height = 1080*0.75, res = 100, pointsize = 24)

my.pal <- colorRampPalette(rev(c(rep("#E8E79AFF",1),
                                 rep("#C2D89AFF",1),
                                 rep("#8CBF9AFF",1),
                                 rep("#5FA2A4FF",2),
                                 rep("#477B95FF",2),
                                 rep("#315B88FF",4),
                                 rep("#24396BFF",4),
                                 rep("#191F40FF",4))))


par(mar = c(2,2,2,2))
par(mgp = c(3, 0.75, 0))

z.max <- 3.35

out.to.plot <- out
out.to.plot$z[out.to.plot$z > z.max] <- z.max

image.plot(out.to.plot,
           xlim = c(-0.001, 1),
           ylim = c(-60, 60),
           col = my.pal(30),
           yaxt = "n", xaxt = "n",
           lwd = lwd.val,
           zlim = c(0, z.max),
           axis.args=list( at=seq(0,4,by = 1), labels=c(expression(10^0),
                                                        expression(10^1),
                                                        expression(10^2),
                                                        expression(10^3),
                                                        expression(10^4))))

x.coords <- seq_along(x)/length(x)
lines(x.coords, median.line, col = "#BF2729FF", lwd = 1, lty = 1)
lines(x.coords, mean.line, col = "#F4A464FF", lwd = 1, lty = 1)

axis(side = 1, at = seq(0,1, by = 0.2), lwd = lwd.val, labels = seq(0,1, by = 0.2))
axis(side = 2, at = seq(-60, 60, by = 30), lwd = lwd.val)
axis(side = 3, at = seq(0, 1, length.out = 7), labels = paste0(seq(0, 7200, length.out = 7)/1000, "k"), lwd = lwd.val)
axis(side = 4, at = c(-1000,1000), lwd = lwd.val)

legend("bottomright", c("Mean of repeated samples", "Median of repeated samples"),
       lty = 1, lwd = 6, col = c("#F4A464FF", "#BF2729FF"), bty = "n")

dev.off()



######### SLICES

xlim.vals <- list(c(-60,60),
                  c(-45,45),
                  c(-30,30))
xlim.vals.adj <- list(c(-60,60),
                      c(-45,45),
                      c(-30,30))

plot.widths <- sapply(xlim.vals, function(X) X[2]-X[1])
plot.widths <- plot.widths / plot.widths[length(plot.widths)] * 2

seq.val <- 75
x.ticks <- list(seq(-seq.val, seq.val, by = 15),
                seq(-seq.val, seq.val, by = 15),
                seq(-seq.val, seq.val, by = 15))

ylim.vals <- c(0,4)



cols <- my.pal(30)

png('/Users/wdaniels/Documents/papers/sampling/figures/slices.png',
    width = 1920, height = 1080*0.5, res = 100, pointsize = 36)

layout.mat <- matrix(c(rep(1, plot.widths[1]), 
                       rep(2, plot.widths[2]), 
                       rep(3, plot.widths[3])), nrow = 1)
layout(layout.mat)

par(mgp = c(2.5, 0.75, 0))

par(mar = c(1,   0.5, 1, 0.5))
par(oma = c(2.25,   2.5,  0, 4))

true.mean <- mean(sample.means[,ncol(sample.means)])
lwd.val <- 4

# frac.to.plot <- c(0.2, 0.5, 0.8)
frac.to.plot <- c(0.1, 0.3, 0.5)
data <- vector(mode = "list", length = length(frac.to.plot))

for (i in 1:length(frac.to.plot)){
  
  to.use <- which(sample.sizes/length(x) > (frac.to.plot[i] - nx) & sample.sizes/length(x) <= (frac.to.plot[i]))
  
  data.mat <- matrix(NA, nrow = nrow(sample.means), ncol = length(to.use))
  for (j in 1:length(to.use)){
    data.mat[, j] <- sample.means[, to.use[j]]
  }
  
  data.mat <- 100*(data.mat - true.mean)/true.mean
  data[[i]] <- as.vector(data.mat)
  
}

all.vals <- unlist(data)

for (i in 1:3){
  
  h1 <- hist(data[[i]], plot = FALSE,
             breaks = seq(min(all.vals)-1, max(all.vals)+1, by = ny))
  
  h1$counts <- log(h1$counts, base = 10)
  counts.clamped <- pmax(h1$counts, 0)
  
  # Map count order to colors
  idx <- round( counts.clamped / z.max * (length(cols)-1) ) + 1
  idx[idx > length(cols)] <- length(cols)
  bar_cols <- cols[idx]
  
  plot(range(h1$breaks), c(0, z.max),
       type = "n", xlim = xlim.vals.adj[[i]], ylim = ylim.vals,
       main = "", xaxt = "n", yaxt = "n", xlab = "", ylab = "")
  
  for (k in seq_along(h1$counts)) {
    rect(h1$breaks[k], 0,
         h1$breaks[k+1], counts.clamped[k],
         col = bar_cols[k],
         border = NA,
         lwd = lwd.val)
  }
  
  abline(v = mean(data[[i]]),   lwd = lwd.val, col = "#F4A464FF")
  abline(v = median(data[[i]]), lwd = lwd.val, col = "#BF2729FF")
  
  box(lwd = lwd.val)
  axis(side = 1, at = x.ticks[[i]], lwd = lwd.val)
  
  if (i == 1){
    axis(side = 2,
         at = seq(0, ceiling(z.max), 1),
         las = 2, lwd = lwd.val,
         labels=c(expression(10^0),
                  expression(10^1),
                  expression(10^2),
                  expression(10^3),
                  expression(10^4)))
  }
}


mtext("Percent error in the sample mean (%)",
      outer = T, line = 1, side = 1, cex = 0.7)

dev.off()


#!/usr/bin/env Rscript

library(micropan)
library(vegan)

args <- commandArgs(trailingOnly = TRUE)
genePresenceAbsence <- args[1]

data <- read.table("~/Downloads/paranoo.Rtab", sep = "\t", row.names = 1, header = TRUE, check.names = FALSE)

pangenome_size = nrow(data)
core_size <- length(rowSums(data)[rowSums(data) > 0.99*ncol(data)])
shell_size <- length(rowSums(data)[rowSums(data) < 0.99*ncol(data) & rowSums(data) > 0.15*ncol(data)])
cloud_size <- length(rowSums(data)[rowSums(data) <  0.15*ncol(data)])
par(mfrow = c(1, 2),pin = c(2.5, 2.5))

slices <- c(core_size,shell_size,cloud_size)
pct <- round(slices/sum(slices)*100,2)
lab <- paste(c("core", "shell", "cloud"),pct,"%",sep=" ")
png(filename = "pie_plot_panaroo.png", width = 6, height = 4, units = "in", res = 300)
pie(slices, labels = lab, main="Pangenome", cex=0.8)
dev.off()

png(filename = "hist_plot_panaroo.png", width = 6, height = 4, units = "in", res = 300)
hist(rowSums(data), xlab = "Number of genomes containing a gene",
     ylab = "Number of genes", main = "Gene frequency",
     ylim = c(0,5000), xlim = c(0,ncol(data)+1),
     breaks = seq(min(rowSums(data))-0.5, max(rowSums(data))+0.5, by = 1))
dev.off()

df_t <- t(data)
rownames(df_t) <- colnames(data)
colnames(df_t) <- rownames(data)

heap <- heaps(df_t, n.perm = 1000)
rf <- specaccum(df_t, "random", permutations = 1000)
png(filename = "rarefaction_curve_panaroo.png", width = 6, height = 4, units = "in", res = 300)
plot(rf, ci.type = "poly", col = "darkblue", lwd = 2, ci.lty = 0, ci.col = "lightblue3",
           xlab = "Number of genomes",
           ylab = "Number of gene families",
           ylim = c(4000, 6000))
legend(x = "bottomright", legend = paste("\u03B1 =", round(heap[2], 2)), fill = "blue")
dev.off()

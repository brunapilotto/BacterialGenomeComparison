#!/usr/bin/env Rscript

library(micropan)
library(vegan)
library(limma)
library(pheatmap)
library(ggplot2)

args <- commandArgs(trailingOnly = TRUE)
genePresenceAbsence <- args[1]
metadata <- args[2]

data <- read.table(genePresenceAbsence, sep = "\t", row.names = 1, header = TRUE, check.names = FALSE)

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
    )
legend(x = "bottomright", legend = paste("\u03B1 =", round(heap[2], 2)), fill = "blue")
dev.off()

counts <- vennCounts(data[2:5])
png(filename = "venn_diagram_panaroo.png", width = 6, height = 4, units = "in", res = 300)
vennDiagram(counts, circle.col = c("red", "blue", "green3", "yellow"), cex = 1)
dev.off()

pange <- as.matrix(df_t, as.numeric)
rownames(pange) <- colnames(data)

pdf(file = "heatmap_panaroo.pdf", width = 10, height = 4)
hm <- pheatmap(pange, clustering_distance_rows = "manhattan",
            clustering_method = "ward.D", color = c("white", "skyblue4"),
            clustering_distance_cols = "manhattan", show_colnames = F,
            cluster_cols = T, cluster_rows = T, legend = F)
reorder <- data[hm$tree_col[["order"]],]
reorder <- reorder[,hm$tree_row[["order"]]]
pheatmap(t(reorder[1:85,]), show_colnames = T,
      cluster_cols = F, cluster_rows = F, legend = F,
      color = c("white", "skyblue4"))
dev.off()

meta <- read.table(metadata, header = TRUE, sep = "\t", row.names = 1)
dafr <- data.frame(merge(df_t, meta, by = 0))
numericCols <- sapply(dafr, is.numeric)
numericData <- dafr[, numericCols]
numericData <- numericData[, apply(numericData, 2, function(x) var(x) != 0)]
PC <- prcomp(numericData, scale. = TRUE)
PCi <- data.frame(PC$x, Host = dafr$Host)
png(filename = "PCA_plot_panaroo.png", width = 6, height = 4, units = "in", res = 300)
ggplot(PCi, aes(x=PC1,y=PC2,fill=Host)) +
  geom_point(size = 5, alpha = 0.5, shape = 21) +
  scale_fill_brewer(palette = "Set1") +
  theme_bw()
dev.off()

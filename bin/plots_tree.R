#!/usr/bin/env Rscript

library(ggplot2)
library(ggtree)
library(phangorn)

args <- commandArgs(trailingOnly = TRUE)
treeFile <- args[1]
metadata <- args[2]

tree <- read.tree(treeFile)
treeMP<-midpoint(tree)
meta <- read.table(metadata, header = T, sep = "\t")

png(filename = "tree_plot.png", width = 10, height = 4, units = "in", res = 300)
gg <- ggtree(treeMP, layout= "rectangular", right=F) +
  geom_tiplab(size=2.8, linesize=.5,offset = 0.0003,align = T) +
  geom_text2(aes(subset = !isTip, label=label), size = 2,
             hjust=1.2,vjust = -0.3) +
  geom_treescale()

p1 <- gg %<+% meta[,c(1:2)]
p2 <- p1 + geom_tippoint(aes(fill=Host, shape=Host),
                         size=5, alpha=1, colour = "black") +
  scale_fill_brewer(palette = "Set1") +
  scale_shape_manual(values = rep(21,each=12)) +
  theme(legend.position = "right")
p2
dev.off()

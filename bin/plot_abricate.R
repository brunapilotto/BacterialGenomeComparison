#!/usr/bin/env Rscript

library(ggnewscale)
library(ggplot2)
library(ggtree)
library(phangorn)

args <- commandArgs(trailingOnly = TRUE)
abricateSummary <- args[1]
treeFile <- args[2]
metadata <- args[3]

tree <- read.tree(treeFile)
treeMP <- midpoint(tree)
meta <- read.table(metadata, header = TRUE, sep = "\t")
df1 <- read.table(abricateSummary, sep = "\t", header = TRUE,
                    check.names = FALSE, row.names = 1
                )
df2 <- df1[,-1]

df2[df2 >= 90] <- 'Present'
df2[df2 < 90] <- 'Absent'

png(filename = "abricate_heatmap.png", width = 10, height = 10, units = "in", res = 300)
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
p3 <- p2 + new_scale_fill()
gheatmap(p3, df2, width = 1.2, font.size = 2.8,
            color ="black", colnames_offset_y = -0.4, colnames_position =
            "top", offset = 0.0012, hjust = 0, colnames_angle = 90) +
            scale_fill_manual(breaks = c("Present", "Absent"),
                            values = c("#6da3a3", "gray95"),
                            name = "Plasmid replicon") +
            theme(legend.position = "right")
dev.off()

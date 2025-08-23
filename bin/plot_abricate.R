#!/usr/bin/env Rscript

library(ggnewscale)
library(ggtree)

args <- commandArgs(trailingOnly = TRUE)
abricateSummary <- args[1]

df1 <- read.table(abricateSummary, sep = "\t", header = TRUE,
                    check.names = F, row.names = 1
                )
df2 <- df1[,-1]

df2[df2 >= 90] <- 'Present'
df2[df2 < 90] <- 'Absent'

png(filename = "abricate_heatmap.png", width = 8, height = 10, units = "in", res = 300)
gheatmap(df2, width = 1.2, font.size = 2.8,
            color ="black", colnames_offset_y = -0.4, colnames_position =
            "top", offset = 0.0012, hjust = 0, colnames_angle = 90) +
            scale_fill_manual(breaks = c("Present", "Absent"),
                            values = c("#6da3a3", "gray95"),
                            name = "Plasmid replicon") +
            theme(legend.position = "right")
dev.off()

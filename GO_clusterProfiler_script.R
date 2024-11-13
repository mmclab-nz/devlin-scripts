library(BiocManager)
library(clusterProfiler)
library(AnnotationDbi)
library(org.Mm.eg.db)
library(enrichplot)
library(tidyverse)


#easy symbol change code (ENSEMBL to SYMBOL)

mapIds(org.Mm.eg.db, keys = {sample}_sig_0.05_df$gene_name, keytype = "SYMBOL", column = "SYMBOL")

#adjust df to have genes on row

{sample}_sig_0.05_df <- {sample}_sig_0.05_df[order(-{sample}_sig_0.05_df$log2FoldChange),]
{sample}_GOgenes<- row.names({sample}_sig_0.05_df[{sample}_sig_0.05_df$log2FoldChange > 2,])

#run GO enrichment
#keyType works with "ENSEMBL" "SYMBOL" "ENTREZID"

{sample}_GO_results <- enrichGO(gene = {sample}_GOgenes,
                           OrgDb = "org.Mm.eg.db", 
                           keyType = "SYMBOL", 
                           readable = T,
                           ont = "BP")

view(as.data.frame({sample}_GO_results))

#plot enrichment data

{sample}GO_bar <- plot(barplot({sample}_GO_results, showCategory = 20)) + 
              ggtitle("title")

{sample}GO_dot <- plot(dotplot({sample}_GO_results, showCategory = 20)) + 
  ggtitle("title")

{sample}GO_cnetplot <- cnetplot({sample}_GO_results) +
                  ggtitle("title")
{sample}GO_heatplot <- heatplot({sample}_GO_results, showCategory = 5) +
                  ggtitle("title")


#hierachical clutering
{sample}_GO_results2 <- pairwise_termsim({sample}_GO_results)
{sample}GO_tree <- treeplot({sample}_GO_results2) +
  ggtitle("title")

{sample}GO_enrichmap <- emapplot({sample}_GO_results2, cex_label_category=0.5) +
                    ggtitle("title")

{sample}GO_upset <- upsetplot({sample}_GO_results) + 
                ggtitle("title")

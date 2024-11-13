library(BiocManager)
library(clusterProfiler)
library(AnnotationDbi)
library(org.Mm.eg.db)
library(tidyverse)

#easy symbol change code (ENSEMBL to SYMBOL)

{sample}_sig_0.05_df$ensembl <- mapIds(org.Mm.eg.db, keys = rownames({sample}_sig_0.05_df), keytype = "SYMBOL", column = "ENSEMBL")
rownames()

#rank deseq data (ENTREZID or ENSEMBL)

{sample}_sig_0.05_df <- {sample}_sig_0.05_df[order(-{sample}_sig_0.05_df$stat),]
ent_{sample}_genelist <- {sample}_sig_0.05_df$stat
names({sample}_rvg_genelist) <- {sample}_sig_0.05_df$ENTREZID
ent_{sample}_genelist <- ent_{sample}_genelist[-which(is.na(names(ent_{sample}_genelist)))]

#rank deseq data (for SYMBOL)

{sample}_sig_0.05_df <- {sample}_sig_0.05_df[order(-{sample}_sig_0.05_df$stat),]
sym_{sample}_genelist <- {sample}_sig_0.05_df$stat
names(sym_{sample}_genelist) <- rownames({sample}_sig_0.05_df)

#run gene set enrichment for GO

{sample}_gseGO <- gseGO(sym_{sample}_genelist,
                   ont = "BP",
                   OrgDb = org.Mm.eg.db,
                   keyType = "SYMBOL")

{sample}_gseGO_df <- as.data.frame({sample}_gseGO)

#make list smaller for plotting (if needed)

nes_{sample}_gseGO <- abs({sample}_gseGO_df[{sample}_gseGO_df$NES > 3]) 
posnes_{sample}_gseGO <- {sample}_gseGO_df[{sample}_gseGO_df$NES > 2.5,]

#plot barplot of enriched gene sets

{sample}_gseGO_0.05_ggp <- ggplot(nes_{sample}_gseGO, aes(reorder(Description, NES), NES)) +
  geom_col(aes(fill=NES > 0), show.legend = F) +
  coord_flip() +
  labs(x="Description", y="Normalized Enrichment Score",
       title="title") + 
  theme_minimal() + 
  theme(axis.text.y = element_text(size=2))



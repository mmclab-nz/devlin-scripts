#load libraries for FGSEA
library(msigdbr)
library(org.Mm.eg.db)
library(fgsea)
library(tidyverse)

#pull in genesets using msigdbr

all_mus_gene_sets <- msigdbr(species = "Mus musculus")

mus_celltype_gene_sets <- msigdbr(species = "Mus musculus", category = "C8")
head(mus_hallmark_gene_sets)

#create a list on gene symbols for ensembl genes

gvh_sig_0.05_df <- 

ens2symbol <- AnnotationDbi::select(org.Mm.eg.db,
                                    key = rownames(gvh_sig_0.05_df),
                                    columns="SYMBOL",
                                    keytype="ENSEMBL")

ens2symbol <- as_tibble(ens2symbol)
ens2symbol

#add gene symbols to sig filtered data -> split into separate dataframe with t-statistic

sig_filter_0.05_df <- inner_join(sig_filter_0.05_df, ens2symbol, by=c("ens_gene_name"="ENSEMBL"))

{sample}_sig_0.05_df <- {sample}_sig_0.05_df[order(-gvh_sig_0.05_df$stat),]

{sample}_sig_0.05_df_2 <- {sample}_sig_0.05_df %>% 
  dplyr::select(ensembl, stat) %>% 
  na.omit() %>% 
  distinct() %>% 
  group_by(ensembl) %>% 
  summarize(stat=mean(stat))


#rank DEGs by t-statistic
{sample}_sig_0.05_df_2 <- {sample}_sig_0.05_df_2[order(-{sample}_sig_0.05_df_2$stat)]
{sample}_ranks_0.05 <- deframe({sample}_sig_0.05_df_2)

head({sample}_ranks_0.05, 20)

#make a new item with gene symbols and genesets as two groups

mus_hallmark_gene_ens <- split(x =mus_hallmark_gene_sets$ensembl_gene , f = mus_hallmark_gene_sets$gs_name)

mus_hallmark_gene_sym %>%
  head() %>%
  lapply(head)

#run fgsea

{sample}_fgsea_Mm_hm_0.05 <- fgsea:: fgsea(pathways = mus_hallmark_gene_ens, stats = {sample}_ranks_0.05)

#create tibble for viewing results

{sample}_sig_hm_ggplot <- {sample}_fgsea_Mm_hm_0.05[gvh_fgsea_Mm_hm_0.05$padj < 0.05]

#plot NES for all genesets

rvh_fgsea_Mm_hallm_0.05_ggp <- ggplot({sample}_sig_hm_ggplot, aes(reorder(pathway, NES), NES)) +
  geom_col(aes(fill=NES>0), show.legend = F) +
  coord_flip() +
  labs(x="Pathway", y="Normalized Enrichment Score",
       title="title") + 
  theme_minimal()

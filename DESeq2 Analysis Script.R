#load packages 
library(BiocManager)
library(tximport)
library(DESeq2)
library(plotly)
library(pheatmap)
library(RColorBrewer)
library(tidyverse)

#file import and organisation

tx2gene <- read.csv("tx2gene.csv")
read.csv("tx2gene.csv.gz") %>% View()

{file}_sample_info <- read.csv("{filename}_sample_info.csv")

{file}_sample_files <- paste0(pull({file}_sample_info,'Sample_ID'), '/quant.sf')

names({file}_sample_files) <- pull({file}_sample_info, 'ID')

{sample}_count_data <- tximport(files = {file}_sample_files,
         type = "salmon",
         tx2gene = tx2gene,
         ignoreTxVersion = F,
         dropInfReps = TRUE)


#how to look at count data (the important part)
tail(count_data[['counts']])
#or
gvh_count_data$counts 

#differential expression analysis


#need to make the variable of interest a factor 
{sample}cond <- c('GL261', 'GL261', 'GL261', 'GL261', 'GL261', 'GL261','Healthy', 'Healthy',
          'Healthy', 'Healthy', 'Healthy', 'Healthy', 'Healthy', 'Healthy')

{sample}cond <- factor({sample}cond)
        

{sample}_sample_info$Tumour <- cond


#txi -> data generated by tximport
#colData -> metadata/column data to go along with salmon txi data (sample_info)
#design is "equation description of experiment"
# ~ represents 'given' ie y ~ x, where y is implied (x=factor)

{sample}_dds <- DESeqDataSetFromTximport(txi = {sample}_count_data,
                                colData = {sample}_sample_info,
                                design = ~Tumour)

{sample}_dds <- estimateSizeFactors({sample}_dds)


#plot raw count data -> very skewed to small values
boxplot(counts({sample}_dds, normalized = T))
boxplot(counts({sample}_dds))

#transform data using vst
{sample}_vst <- varianceStabilizingTransformation({sample}_dds)

boxplot(assay({sample}_vst))

{sample}_pca <- plotPCA({sample}_vst, intgroup = "Tumour") +
  theme_bw()

#estimating dispersion of data

{sample}_dds <- estimateDispersions({sample}_dds)
plotDispEsts({sample}_dds)

#apply statistics
#alphabetically compared by default -> GL261 compared with RAS
#+ log fold -> increase in RAS
#- log fold -> decrease in RAS/increase in GL261

{sample}_dds <- nbinomWaldTest({sample}_dds)
results_{sample}_dds <- results({sample}_dds)
summary(results_{sample}_dds)

#convert results to data.frame

results_{sample}_dds_df <- as.data.frame(results_{sample}_dds)

#remove genes from data.frame which have NA vaules

sum(complete.cases(results_{sample}_dds_df))

filtered_results_{sample}_dds_df <- results_{sample}_dds_df[complete.cases(results_{sample}_dds_df),]

#filter results based on stat significance

# padj < 0.05 
# log2FoldChange > 1 or < -1

filtered_results_{sample}_dds_df$padj < 0.05
abs(filtered_results_{sample}_dds_df$log2FoldChange) > 1

{sample}_sig_0.05_df <- filtered_results_{sample}_dds_df[filtered_results_{sample}_dds_df$padj < 0.05,]
dim({sample}_sig_0.05_df)

{sample}_sig_0.05_df <- {sample}_sig_0.05_df[abs({sample}_sig_0.05_df$log2FoldChange) > 1,]
dim({sample}_sig_0.05_df)

# padj < 0.01
# log2FoldChange > 1 or < -1

filtered_results_{sample}_dds_df$padj < 0.01
abs(filtered_results_{sample}_dds_df$log2FoldChange) > 1

{sample}_sig_0.01_df <- filtered_results_{sample}_dds_df[filtered_results_gvh_dds_df$padj < 0.01,]
dim(gvh_sig_0.01_df)

{sample}_sig_0.01_df <- {sample}_sig_0.01_df[abs({sample}_sig_0.01_df$log2FoldChange) > 1,]
dim(gvh_sig_0.01_df)

#volcano plots
# plots the log2FC against the padj value (-log10 of padj)

filtered_results_{sample}_dds_df$sig_test <- filtered_results_{sample}_dds_df$padj < 0.05 & abs(filtered_results_{sample}_dds_df$log2FoldChange) > 1

filtered_results_{sample}_dds_df <- rownames_to_column(filtered_results_{sample}_dds_df, var = 'Gene_name')

gvh_V_plot <- ggplot(filtered_results_{sample}_dds_df, aes(x=log2FoldChange, y=-log10(padj), name=Gene_name)) +
      geom_point(aes(colour = sig_test), size = 1, alpha = 0.5) +
      scale_colour_manual(values = c('grey', 'red')) +
      labs(title = "title") +
      xlab("log2 Fold Change") + ylab("-log10 Padj")  +
      theme_bw() +
      theme(legend.position = "none", plot.title = element_text(hjust = 0.5))

ggplotly(gvh_V_plot)

#heatmaps

#need to get row_names -> columns for DEGs
#base heatmap package has less customisation 

{sample}_sig_0.05_df <- rownames_to_column({sample}_sig_0.05_df, var = "gene_name")
{sample}_DEGs_5 <- {sample}_sig_0.05_df$gene_name

{sample}_sig_0.01_df <- rownames_to_column({sample}_sig_0.01_df, var = "gene_name")
{sample}_DEGs_1 <- {sample}_sig_0.01_df$gene_name


{sample}_vst_mat <- assay({sample}_vst)
{sample}_hm_data_5 <- {sample}_vst_mat[{sample}_DEGs_5,]

{sample}_hm_data_1 <- {sample}_vst_mat[{sample}_DEGs_1,]

heatmap({sample}_hm_data_1)      

#pheatmaps has more input factors
#default is not to normalise across gene

PuRd_colour <- colorRampPalette(brewer.pal(9, "PuRd"))(100)

pheatmap({sample}_hm_data_5, fontsize_row = 4,
         scale = 'row', color = PuRd_colour,
         show_rownames = F,
         main = 'title')

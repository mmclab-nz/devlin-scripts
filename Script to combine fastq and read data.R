geneNames <- intersect(rownames(prim_raw_counts), rownames(healthy_human_mat))
prim_sub_mat <- prim_raw_counts[geneNames,]
healthy_human_sub_mat <- healthy_human_mat[geneNames,]
combine_prim_health_counts <- cbind(healthy_human_sub_mat, prim_sub_mat)

geneNames2 <- intersect(rownames(rec_raw_counts), rownames(healthy_human_mat))
rec_sub_mat <- rec_raw_counts[geneNames2,]
healthy_human_sub2_mat <- healthy_human_mat[geneNames2,]
combine_rec_health_counts <- cbind(healthy_human_sub_mat, rec_sub_mat)

row.names(prim_sample_info) <- prim_sample_info[,1]
row.names(rec_sample_info) <- rec_sample_info[,1]

all(row.names(prim_sample_info) == colnames(combine_prim_health_counts))
all(row.names(rec_sample_info) == colnames(combine_rec_health_counts))

as.data.frame(prim_sample_info)
prim_sample_info <- as.data.frame(prim_sample_info)

as.data.frame(rec_sample_info)
rec_sample_info <- as.data.frame(prim_sample_info)

row.names(prim_sample_info) <- prim_sample_info [,1]

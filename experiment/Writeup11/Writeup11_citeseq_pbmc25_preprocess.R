rm(list=ls())

# from what used to be https://satijalab.org/seurat/v4.0/weighted_nearest_neighbor_analysis.html
# now at https://satijalab.org/seurat/articles/weighted_nearest_neighbor_analysis.html#wnn-analysis-of-cite-seq-rna-adt-1

library(Seurat)
library(SeuratData)
library(cowplot)
library(dplyr)

date_of_run <- Sys.time()
session_info <- devtools::session_info()
set.seed(10)

SeuratData::InstallData("bmcite")
bm <- SeuratData::LoadData(ds = "bmcite")

DefaultAssay(bm) <- 'RNA'
bm <- Seurat::NormalizeData(bm) %>% Seurat::FindVariableFeatures() %>% Seurat::ScaleData() %>% Seurat::RunPCA()

DefaultAssay(bm) <- 'ADT'
# we will use all ADT features for dimensional reduction
# we set a dimensional reduction name to avoid overwriting the 
Seurat::VariableFeatures(bm) <- rownames(bm[["ADT"]])
bm <- Seurat::NormalizeData(bm, normalization.method = 'CLR', margin = 2) %>% 
  Seurat::ScaleData() %>% Seurat::RunPCA(reduction.name = 'apca')
names(bm)

set.seed(10)
bm <- Seurat::FindMultiModalNeighbors(
  bm, reduction.list = list("pca", "apca"), 
  dims.list = list(1:30, 1:18), modality.weight.name = "RNA.weight"
)

set.seed(10)
bm <- Seurat::RunUMAP(bm, reduction = 'pca', dims = 1:30, assay = 'RNA',
                        reduction.name = 'rna.umap', reduction.key = 'rnaUMAP_')
set.seed(10)
bm <- Seurat::RunUMAP(bm, reduction = 'apca', dims = 1:18, assay = 'ADT',
                        reduction.name = 'adt.umap', reduction.key = 'adtUMAP_')
set.seed(10)
bm <- Seurat::RunUMAP(bm, nn.name = "weighted.nn", reduction.name = "wnn.umap", reduction.key = "wnnUMAP_")

names(bm)
save.image("../../../../out/Writeup11/Writeup11_citeseq_bm25_preprocessed.RData")



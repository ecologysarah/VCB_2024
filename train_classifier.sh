#!/bin/bash
#SBATCH --partition=jumbo
#SBATCH --mem-per-cpu=200G
#SBATCH --nodes=1
#SBATCH --cpus-per-task=1
#SBATCH --time="24:00:00"
#SBATCH --output OUT/train_classifer.%J
#SBATCH --error ERR/train_classifer.%J

cd /mnt/scratch/sbi9srj/VCB_2024/UNITE_QIIME/

module load qiime2/

#UNITE QIIME release v9. https://unite.ut.ee/repository.php

#Will train classifier using dynamic clustering thresholds

#qiime tools import \
#  --type 'FeatureData[Sequence]' \
#  --input-path sh_refs_qiime_ver9_dynamic_25.07.2023.fasta \
#  --output-path sh_refs_qiime_ver9_dynamic_25.07.2023.qza

#qiime tools import \
#  --type 'FeatureData[Taxonomy]' \
#  --input-format TSVTaxonomyFormat \
#  --input-path sh_taxonomy_qiime_ver9_dynamic_25.07.2023.txt \
#  --output-path sh_taxonomy_qiime_ver9_dynamic_25.07.2023.qza

qiime feature-classifier fit-classifier-naive-bayes \
  --i-reference-reads sh_refs_qiime_ver9_dynamic_25.07.2023.qza \
  --i-reference-taxonomy sh_taxonomy_qiime_ver9_dynamic_25.07.2023.qza \
  --o-classifier UNITEv9dynamic_classifier.qza

#!/bin/bash

#This script will assign taxonomy in QIIME using a Bayesian classifier pre-trained on the 515-806 region of the 16S SILVA dataset. It relies on correctly setting the variables indicated below.
#Written by Sarah Christofides, 2022. Released under Creative Commons BY-SA.

###VARIABLES TO BE SET###
#Set the path to your directory on scratch - do not include a trailing /
myDir=/mnt/scratch/sbi9srj/VCB_2024
#Set your username
userProject=sbi9srj
#Path to metadata (mapping) file. See https://docs.qiime2.org/2022.2/tutorials/metadata/
metadat=${myDir}/metadata.txt
#Set the slurm queue to use: defq for gomphus, epyc for iago, htc for hawk
queue=mammoth
######

mem="2G"
cpu="50"
runTime="01:00:00"
scriptBase="05taxonomy"

##Set the correct version of QIIME
QIIME=$(module avail -L qiime2/ | tail -n 1)
##Find version number
vNO=$(echo ${QIIME} | sed -E 's/.+\/(.+)/\1/')
##Append this information to the report
echo -e "\nTaxonomy assigned with the UNITE database (v9) in ${QIIME}" >> ${myDir}/AnalysisReport.txt

##Make directories for the output
if [ ! -d "${myDir}/05-taxonomy" ]; then
  mkdir ${myDir}/05-taxonomy
fi

##Create the slurm script
scriptName=${myDir}/temp/${scriptBase}.sh
rm -rf ${scriptName} || true
touch ${scriptName}

echo "#!/bin/bash" >> ${scriptName}
echo "#SBATCH --partition=${queue}" >> ${scriptName}
echo "#SBATCH --mem-per-cpu=${mem}" >> ${scriptName}
echo "#SBATCH --nodes=1" >> ${scriptName}
echo "#SBATCH --cpus-per-task=${cpu}" >> ${scriptName}
echo "#SBATCH --time=${runTime}" >> ${scriptName}
echo "#SBATCH --output ${myDir}/OUT/${scriptBase}.%J" >> ${scriptName}
echo "#SBATCH --error ${myDir}/ERR/${scriptBase}.%J" >> ${scriptName}

echo "module load ${QIIME}" >> ${scriptName}


##Assign the taxonomy
echo "qiime feature-classifier classify-sklearn \\
  --i-classifier ${myDir}/UNITE_QIIME/UNITEv9dynamic_classifier.qza \\
  --i-reads ${myDir}/04-denoise/representative_sequences.qza \\
  --p-n-jobs ${cpu} \\
  --o-classification ${myDir}/05-taxonomy/taxonomy.qza" >> ${scriptName}

##Summarise results
echo "qiime metadata tabulate \\
  --m-input-file ${myDir}/05-taxonomy/taxonomy.qza \\
  --o-visualization ${myDir}/05-taxonomy/taxonomy.qzv" >> ${scriptName}

##Create bar plot visualisations
echo "qiime taxa barplot \\
  --i-table ${myDir}/04-denoise/table.qza \\
  --i-taxonomy ${myDir}/05-taxonomy/taxonomy.qza \\
  --m-metadata-file ${metadat} \\
  --o-visualization ${myDir}/05-taxonomy/taxa-bar-plots.qzv" >> ${scriptName}

echo "exit 0" >> ${scriptName}

##Make the script executable
chmod u+x ${scriptName}

##Submit the script to the compute queue
sbatch ${scriptName}

exit 0

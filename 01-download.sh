#!/bin/bash

##This script will download, back up and upzip your raw sequencing data. It relies on correctly setting the variables below. It will also set up the required directory structure for the project and start a report documenting the steps.

##Written by Sarah Christofides, 2022. Released under Creative Commons BY-SA.

###VARIABLES TO BE SET###
##Your name
analyst="Sarah Christofides"
##Your project title
project="Analysis of fungal communities in violet click beetle habitat"
##N.B. If you are working on a server that doesn't use scratch, leave the SAVEPATH commented out and set SCRATCHPATH to your data folder.
##Set path to directory for saving files - do not include a trailing /
##SAVEPATH=/mnt/data/GROUP-yourgroup/yourusername/yourproject
##Set path to working directory on scratch - do not include a trailing /
SCRATCHPATH=/mnt/scratch/sbi9srj/VCB_2024
##Paste in the URLs to your files here, e.g. DOWNLOADURL=("https://url1" "https://url2")
#DOWNLOADURL=("")
#The files had to be downloaded manally, so instead I am using this script to set up directories and organise the files
#Set the slurm queue to use: defq for gomphus or iago, htc for hawk
queue=defq
######

##Set up the directories: check if they exist and create them if not
DIRLIST=("01-download" "temp" "ERR" "OUT")
for DIRECTORY in "${DIRLIST[@]}"
do 
	if [ ! -d "${SCRATCHPATH}/$DIRECTORY" ]; then
	  mkdir ${SCRATCHPATH}/${DIRECTORY}
	fi
done

scriptBase="download"
slurmids=""

##Create a report for the analysis
touch ${SCRATCHPATH}/AnalysisReport.txt
##Add information to the report
echo -e "${project}\nAnalysis run by ${analyst}\nSequencing runs:" >> ${SCRATCHPATH}/AnalysisReport.txt

##Work through each of the links in turn
#for url in "${!DOWNLOADURL[@]}"
#do
#        ## write a script to the temp/ directory (one for each sample)
#        scriptName="${SCRATCHPATH}/temp/${scriptBase}.${url}.sh"
#
#        ## remove the script if it exists already
#        rm -rf ${scriptName} || true
#
#        ## make an empty script for writing
#        touch ${scriptName}

        ## write the SLURM parameters to the top of the script
#	echo "#!/bin/bash" >> ${scriptName}
#	echo "#SBATCH --partition=${queue}" >> ${scriptName}       # the requested queue
#	echo "#SBATCH --nodes=1" >> ${scriptName}              # number of nodes to use
#	echo "#SBATCH --tasks-per-node=1" >> ${scriptName}     #
#	echo "#SBATCH --cpus-per-task=1" >> ${scriptName}      #
#	echo "#SBATCH --mem-per-cpu=1000" >> ${scriptName}     # in megabytes, unless unit explicitly stated
#	echo "#SBATCH --error=${SCRATCHPATH}/ERR/${scriptBase}.${url}.%J" >> ${scriptName}     # redirect stderr to this file
#	echo "#SBATCH --output=${SCRATCHPATH}/OUT/${scriptBase}.${url}.%J" >> ${scriptName}    # redirect stdout to this file

	##Download the data
#	echo -e "
#	echo Downloading ${DOWNLOADURL[$url]}
#	curl -sL ${DOWNLOADURL[$url]}/download > ${SCRATCHPATH}/01-download/download${url}.zip
#        echo Download ${DOWNLOADURL[$url]} complete

	##Save the run name to a variable and rename the zip file
#	RUN=\$(unzip -Z -1 ${SCRATCHPATH}/01-download/download${url}.zip | head -n 1 | sed -E 's/(.+)\/$/\1/')
#	mv ${SCRATCHPATH}/01-download/download${url}.zip ${SCRATCHPATH}/01-download/\${RUN}.zip

	##Copy the data to long term storage
#	if [ ${SAVEPATH+x} ]
#		then
#		echo Copying \${RUN} to long term storage
#		cp ${SCRATCHPATH}/01-download/\${RUN}.zip ${SAVEPATH}/\${RUN}.zip
#	fi

        ##Unzip the data
#	echo Unzipping \${RUN}
#       unzip ${SCRATCHPATH}/01-download/\${RUN}.zip -d ${SCRATCHPATH}/01-download/

	##Remove the zipped file
#	rm ${SCRATCHPATH}/01-download/\${RUN}.zip

	##Add run name to the report
#	echo ${RUN} >> ${SCRATCHPATH}/AnalysisReport.txt
#	exit 0" >> ${scriptName}

        ## make the script into an 'executable'
#        chmod u+x ${scriptName}

        ## submit the script to the compute queue
#        slurmids="${slurmids}:$(sbatch --parsable ${scriptName})"

#done

##Create a list of sample names for subsequent steps
scriptName=${SCRATCHPATH}/temp/${scriptBase}.sh

##Create the empty script
touch ${scriptName}

## write the SLURM parameters to the top of the script
echo "#!/bin/bash" > ${scriptName}
echo "#SBATCH --partition=defq" >> ${scriptName}       # the requested queue
echo "#SBATCH --nodes=1" >> ${scriptName}              # number of nodes to use
echo "#SBATCH --tasks-per-node=1" >> ${scriptName}     #
echo "#SBATCH --cpus-per-task=1" >> ${scriptName}      #
echo "#SBATCH --mem-per-cpu=1000" >> ${scriptName}     # in megabytes, unless unit explicitly stated
echo "#SBATCH --error=ERR/download.%J" >> ${scriptName}     # redirect stderr to this file
echo "#SBATCH --output=OUT/download.%J" >> ${scriptName}    # redirect stdout to this file

##Unzip the data
#echo "unzip ${SCRATCHPATH}/VCBdataFromAber.zip -d ${SCRATCHPATH}/01-download/" >> ${scriptName}

##Remove the zipped file
#echo "rm ${SCRATCHPATH}/VCBdataFromAber.zip" >> ${scriptName}

#gzip the fastqs
echo "ls ${SCRATCHPATH}/01-download/*/*.fastq | while read line
		do gzip \${line}
	done" >> ${scriptName}

echo "find ${SCRATCHPATH}/01-download/ -name *f*q.gz | grep -v 'Undet' | sed -E 's/.+\/(.+)R[1-2](_001)?\.f.*q\.gz/\1/' | sort | uniq > ${SCRATCHPATH}/01-download/SampleFileNames.txt" >> ${scriptName}

##Make the script into an 'executable'
chmod u+x ${scriptName}
##Submit the script to the compute queue
#sbatch -d afterok${slurmids} ${scriptName}
sbatch ${scriptName}

exit 0

# Run prepareBAM() function and creat the "sorted_by_name_uniq_filtered.bam" files from the
# original .bam files

# Note: This process will overwrite the current .bam files with the new 
# "_sorted_by_name_uniq_filtered.bam" files, so be sure to keep a copy of the original .bam files
# in a separate directory. The inputDirectory should be the location of the .bam files
# you are okay overwriting.

# Note: run all of this in a linux environment

#------------------------------------------------------------------
# Generating BAM file List            
#------------------------------------------------------------------

# Needed arguments (see Step_0_Directions.Rmd for details):
# inputDirectory, workingDirectory

# Generate initial list of files: (NOTE: this takes into account and 
# ignores any .bam.bai files also included)
init_list = list.files(path = inputDirectory, pattern=".bam")
init_list

# Generate list of .bai files
int_list = list.files(path = inputDirectory, pattern=".bai")

# Final List (excluding .bai files):
BAM_list = setdiff(init_list,int_list)

# -----------------------------------------------------------------
# check the bam files
# -----------------------------------------------------------------

# Checks length of BAM files to ensure all has run properly:
length(BAM_list)

# Displays BAM list as another check for errors:
BAM_list

bam2use = BAM_list

#Loop across all BAM files in the folder:
for(i in 1:length(BAM_list)){
  
  bami = bam2use[i]
  
  #Generates a name that can be used in the files by stripping 
  #off the ".bam" extension: 
  if(str_detect(bami, "_sorted_by_name.bam$")){
    sami = substr(bam2use[i],start=1,stop=nchar(bam2use[i])-4)
  }else{
    sami = str_c(substr(bam2use[i],start=1,stop=nchar(bam2use[i])-4), "_sorted_by_name")
  }
  
  # ----------------------------------------------------------
  # counting
  # ----------------------------------------------------------
  ctF  = sprintf("%s/count_%s.txt", inputDirectory, sami)
  cmd1 = sprintf("samtools view %s/%s | wc -l > %s \n", inputDirectory, bam2use[i], ctF)
  system(cmd1)
  
  # ----------------------------------------------------------
  # sorting
  # ----------------------------------------------------------
  cmd2 = sprintf("samtools sort -n %s/%s -o %s/%s.bam", inputDirectory, bam2use[i], inputDirectory, sami)
  system(cmd2)
  bamF = sprintf("%s/%s.bam", inputDirectory, sami)
  
  # ----------------------------------------------------------
  # getUnique and filtering
  # ----------------------------------------------------------
  prepareBAM(bamF, sprintf("%s/%s", inputDirectory, sami), sortIt=FALSE)
  
  # ----------------------------------------------------------
  # counting again
  # ----------------------------------------------------------
  cmd3   = sprintf("samtools view %s/%s_uniq_filtered.bam | wc -l >> %s\n", inputDirectory, sami, ctF)
  system(cmd3)
  
  system(sprintf("rm %s/%s.bam", inputDirectory, sami))
  # system(sprintf("rm %s/count_%s.txt", inputDirectory, sami))
  
}

output_list = list.files(path = inputDirectory, pattern = "sorted_by_name_uniq_filtered.bam")

if(inputDirectory != workingDirectory){
  for(i in 1:length(output_list)){
    cmd4 = sprintf("cp %s/%s %s/%s \n", inputDirectory, output_list[i], 
                   workingDirectory, output_list[i])
    system(cmd4)
  }
}


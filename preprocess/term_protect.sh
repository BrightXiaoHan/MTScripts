# 基于非译元素对平行语料进行术语保护
set -e
PYTHON_SCRIPT=$(dirname $0)/python/term_protect.py
MASK_DATASET_NAME=""

maskFolder () {
  folder=$1
  gen=$1_mask
  mkdir -p $gen

  for filename in $(find ${folder} -type f -name "zh*"); do
    basefilename=$(basename $filename)
    if  [[ $basefilename =~ (.*)?\.(.*) ]];then 
      suffix=${basefilename#*.}
      targetfile=$(find $(dirname $filename) -type f -name *.$suffix ! -name zh.$suffix)
    else
      targetfile=$(find $(dirname $filename) -type f ! -name zh ! -name *.*)
    fi
    
    python $PYTHON_SCRIPT $filename $targetfile \
                          --suffix "" \
                          --output_folder $gen
    MASK_DATASET_NAME="$(basename $gen) $MASK_DATASET_NAME"
  done
}

for name in $(ls $DATASET_DIR); do
  # 跳过含有mask的文件夹和普通文件
  if [[ $name =~ mask ]] || [ ! -d $DATASET_DIR/$name ];then
    echo "Skip subset $name."
  else
    maskFolder $DATASET_DIR/$name
  fi
done

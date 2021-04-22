# 将多个子数据集中的数据合并到一起
# 请务必保证每个自数据集中的文件名称一一对应
set -e

SUBSET_FOLDERS=$(find $DATASET_DIR -maxdepth 1 -mindepth 1 -type d ! -name ".*")
REFERENCE=$(echo $SUBSET_FOLDERS | cut -d' ' -f1)

for file in $(find $REFERENCE -maxdepth 1 -type f)
do
    allFileNames+=" $(basename $file)"
done


for name in $allFileNames
do
    # 这里将名字交换（如 $lang.train -> train.$lang ），为了满足fairseq的数据存储文件名格式
    if [[ $FRAMEWORK_NAME == "fairseq" ]]; then
      ext=${name##*.}
      base=${name%%.*}
      if [[ $ext == $base ]]; then
        # 如果数据集本身没有被分成tran, dev, test
        outputname="train.$base"
      else
        outputname=$ext.$base
      fi
    else
      outputname=$name
    fi
    input_files=""
    for folder in $SUBSET_FOLDERS 
    do
        input_files+=" $folder/$name"
    done
    cat $input_files > $DATASET_DIR/$outputname
done

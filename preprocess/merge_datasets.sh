# 将多个子数据集中的数据合并到一起
# 请务必保证每个自数据集中的文件名称一一对应
set -e

SUBSET_FOLDERS=$(find $DATASET_DIR -maxdepth 1 -mindepth 1 -type d)
REFERENCE=$(echo $SUBSET_FOLDERS | cut -d' ' -f1)

for file in $(find $REFERENCE -maxdepth 1 -type f)
do
    allFileNames+=" $(basename $file)"
done


for name in $allFileNames
do
    input_files=""
    for folder in $SUBSET_FOLDERS 
    do
        input_files+=" $folder/$name"
    done
    cat $input_files > $DATASET_DIR/$name
done


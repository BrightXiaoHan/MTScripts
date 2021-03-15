# 当文件夹中包含$SRC_LANG-$TGT_LANG的文件时，如果格式为tsv文件，则可以用此脚本进行拆分。

REVERSE=$1  # 语项是否反向，如果语料语项与实际翻译语项相反，则将该位置设为True

if [[ $REVERSE == "True" ]]; then
  tmp=$SRC_LANG
  SRC_LANG=$TGT_LANG
  TGT_LANG=$tmp
fi

ALL_FILE=$(find $DATASET_DIR -maxdepth 2 -mindepth 2 -type f -name "$SRC_LANG-$TGT_LANG*")

for file in $ALL_FILE; do
  suffix=$(basename $file | grep -Po "(?<=$SRC_LANG-$TGT_LANG)")
  folder=$(dirname $file)
  cut -f 1 $file > ${folder}/${SRC_LANG}${suffix}
  cut -f 2 $file > ${folder}/${TGT_LANG}${suffix}
  rm $file
done

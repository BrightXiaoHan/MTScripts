# 中文分字脚本, 脚本会将`DATASET_DIR`中所有以zh开头的文本进行分字处理
set -e
PYTHON_SCRIPT=$(dirname $0)/python/segment_chinese_chars.py

for file in $(find ${DATASET_DIR}/$name -type f -name "zh*"); do
  python $PYTHON_SCRIPT $file $file.tmp
  rm $file
  mv $file.tmp $file
done

# 将所有中文语料中的繁体字转换成简体字
set -e
PYTHON_SCRIPT=$(dirname $0)/python/segment_chinese_chars.py

for file in $(find ${DATASET_DIR}/$name -type f -name "zh*"); do
  hanzi-convert -o $file.tmp -s $file
  rm $file
  mv $file.tmp $file
done

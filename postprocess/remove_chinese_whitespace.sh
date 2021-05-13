# 目前只对中文分字的语料做处理
PYTHON_SCRIPT=$(dirname $0)/python/remove_chinese_whitespace.py


for file in $(find $DATASET_DIR -maxdepth 1 -type f -name "*zh.pred"); do
  python $PYTHON_SCRIPT $file $file.tmp
  rm $file
  mv $file.tmp $file
done

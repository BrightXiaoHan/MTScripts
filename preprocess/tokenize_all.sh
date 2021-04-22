# 对所有数据进行分词操作
# 如果存在`all.spm.model`则对所有语言使用该分词模型进行分词
# 否则，则对每种语言使用不同的分词模型进行分词，比如所有`en`语料使用`en.spm.model`模型进行分词
SENTENCEPIECE_BIN=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh sentencepiece)

echo "Executing script $0..."
for model in $(find $DATASET_DIR -maxdepth 1 -type f -name "*.spm.model")
do
  model_name=$(basename $model)
  lang=${model_name%%.*}
  if [[ $lang == "all" ]];then
    lang=""
  fi
  for file in $(find $DATASET_DIR -maxdepth 2 -mindepth 2 -type f -name "$lang*")
  do
    echo "Tokenizing file $file..."
    $SENTENCEPIECE_BIN/spm_encode --model=$model < $file > $file.spm
    rm $file
    mv $file.spm $file
    echo "Tokenize file $file done."
  done
done

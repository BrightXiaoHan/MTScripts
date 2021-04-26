# 对生成的测试数据译文进行去分词
SENTENCEPIECE_BIN=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh sentencepiece)

echo "Executing script $0..."

model_file=$DATASET_DIR/$TARGET_LANG.spm.model

if [ ! -f $model_file ]
then
  model_file=$DATASET_DIR/all.spm.model
fi

for file in $(find $DATASET_DIR -maxdepth 1 -type f -name "*.pred"); do
  
  $SENTENCEPIECE_BIN/spm_decode --model=$model_file --input_format=piece < $file > $file.tmp
  rm $file
  mv $file.tmp $file
done

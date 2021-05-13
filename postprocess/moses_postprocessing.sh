# 对生成的测试数据译文进行去分词
MOSES_SCRIPTS=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh moses)

echo "Executing script $0..."

moses_detok () {
  for file in $(find $DATASET_DIR -maxdepth 1 -type f -name "*.pred"); do
    sacremoses -l en -j 4 detokenize < $file > $file.tmp
    rm $file
    mv $file.tmp $file
  done
}

moses_deturecase () {
  for file in $(find $DATASET_DIR -maxdepth 1 -type f -name "*.pred"); do
    $MOSES_SCRIPTS/recaser/detruecase.perl < $file > $file.tmp
    rm $file
    mv $file.tmp $file
  done
}

if [[ $* =~ "detruecase" ]]
then
  moses_deturecase
fi

if [[ $* =~ "detok" ]]
then
  moses_detok
fi

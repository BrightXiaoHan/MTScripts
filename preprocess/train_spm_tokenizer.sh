# spm分词模型训练脚本
set -e

OUTPUT_FOLDER=$DATASET_DIR  # 分词模型和词表存放目录
USER_DEFINE_SYMBOLS_FILE=$(dirname $0)/assets/term_protect_symbols.txt
VOCAB_SIZE=$1  # spm训练生成的词表大小
TRAIN_SEPERATE_TOKENIZER=$2  # 是否为原文译文训练单独的词表,True时分别训练词表,False时训练一个词表
ALGORITHM=$3  # 指定分词模型算法。可用的分词算法有`bpe`，`unigram`
SENTENCEPIECE_BIN=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh sentencepiece)


train () {
  # 给定文件序列,训练分词模型
  prefix=$1
  TMP_FILE="$OUTPUT_FOLDER/.dataset_all_in_one"  # 中间生成文件，脚本结束后删除
  echo "Merging files: $input_files ..."
  cat ${@: 2:$#} > $TMP_FILE

  echo "Training sentencepiece model with prefix $prefix..."
  $SENTENCEPIECE_BIN/spm_train --input=$TMP_FILE \
    --model_prefix=$OUTPUT_FOLDER/$prefix \
    --vocab_size=$VOCAB_SIZE \
    --model_type=$ALGORITHM \
    --train_extremely_large_corpus \
    --shuffle_input_sentence \
    --user_defined_symbols_file=$USER_DEFINE_SYMBOLS_FILE

  # 清除中间生成的文件
  rm $TMP_FILE 

  if [[ $FRAMEWORK_NAME == "fairseq" ]]; then
    sed -i "s/\t/ /g" $OUTPUT_FOLDER/$prefix.vocab
    sed -i '1,3d' $OUTPUT_FOLDER/$prefix.vocab  # <unk>, <s>, </s>
  fi
}

# 获取原文、译文的语言类型
getLangs () {
  for folder in $(find $DATASET_DIR -maxdepth 1 -type d ! -name ".*"); do
      for file in $(find $folder -maxdepth 1 -type f ! -name ".*"); do
        filename=$(basename $file)
        lang=${filename%%.*} 
        if [[ ! $langs =~ $lang ]];then
          langs="$langs $lang"
        fi
      done
  done
  echo $langs
}

if [ $TRAIN_SEPERATE_TOKENIZER = True ];then
  for lang in $(getLangs); do
    train $lang.spm $(find $DATASET_DIR -mindepth 2 -maxdepth 2 -type f -name "$lang*" ! -name ".*")
  done
else
  train all.spm $(find $DATASET_DIR -mindepth 2 -maxdepth 2 -type f ! -name ".*") 
fi

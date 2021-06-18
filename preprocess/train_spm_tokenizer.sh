# spm分词模型训练脚本
set -e

for ARGUMENT in "$@"
do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    VALUE=$(echo $ARGUMENT | cut -f2 -d=)

    case "$KEY" in
            vocab_size)
                VOCAB_SIZE=${VALUE}
                ;;
            train_seperate_tokenizer)
                TRAIN_SEPERATE_TOKENIZER=${VALUE}
                ;;
            algorithm)
                ALGORITHM=${VALUE}
                ;;
            add_cn_common_chars)
                ADD_CN_COMMON_CHARS=${VALUE}
                ;;
            term_protection)
                TERM_PROTECTION=${VALUE}
                ;;
            *)
    esac
done


OUTPUT_FOLDER=$DATASET_DIR  # 分词模型和词表存放目录
SENTENCEPIECE_BIN=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh sentencepiece)
USER_DEFINE_SYMBOLS_FILE=$OUTPUT_FOLDER/.user_define_symbols.txt

rm -rf $USER_DEFINE_SYMBOLS_FILE
if [ "$TERM_PROTECTION" = true ]; then
    cat $(dirname $0)/assets/term_protect_symbols.txt >> $USER_DEFINE_SYMBOLS_FILE
fi 

if [ "$ADD_CN_COMMON_CHARS" = true ]; then
    cat $(dirname $0)/assets/common_cn_chars.txt >> $USER_DEFINE_SYMBOLS_FILE
fi


train () {
  # 给定文件序列,训练分词模型
  prefix=$1
  TMP_FILE="$OUTPUT_FOLDER/.dataset_all_in_one"  # 中间生成文件，脚本结束后删除
  echo "Merging files: ${@: 2:$#} ..."
  cat ${@: 2:$#} > $TMP_FILE

  numLines=$(wc -l $TMP_FILE | cut -d ' ' -f 1)
  maxLines=20000000  # TODO 这个值应当根据内存的大小进行设定
  if [ "$numLines" -gt "$maxLines" ];
  then
    echo "Corpus is too large to train. Random sample $maxLines from origin corpus."
    shuf -n $maxLines $TMP_FILE > $TMP_FILE.tmp && mv $TMP_FILE.tmp $TMP_FILE
  fi

  echo "Training sentencepiece model with prefix $prefix..."
  $SENTENCEPIECE_BIN/spm_train --input=$TMP_FILE \
    --model_prefix=$OUTPUT_FOLDER/$prefix \
    --vocab_size=$VOCAB_SIZE \
    --model_type=$ALGORITHM \
    --user_defined_symbols_file=$USER_DEFINE_SYMBOLS_FILE \
    --hard_vocab_limit=false \
    --unk_surface="" \
    --split_digits=true \
    --accept_language="$SOURCE_LANG,$TARGET_LANG" \
    --bos_id=-1 --eos_id=-1 \
    --train_extremely_large_corpus="true" > /dev/null 2>&1

  echo "Training tokenizer done."

  # 清除中间生成的文件
  rm $TMP_FILE 

  if [[ $FRAMEWORK_NAME == "fairseq" ]]; then
    sed -i "s/\t/ /g" $OUTPUT_FOLDER/$prefix.vocab
    sed -i '1d' $OUTPUT_FOLDER/$prefix.vocab  # <unk>
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

if [ "$TRAIN_SEPERATE_TOKENIZER" = true ];then
  for lang in $(getLangs); do
    train $lang.spm $(find $DATASET_DIR -mindepth 2 -maxdepth 2 -type f -name "$lang*" ! -name ".*")
  done
else
  train all.spm $(find $DATASET_DIR -mindepth 2 -maxdepth 2 -type f ! -name ".*") 
fi

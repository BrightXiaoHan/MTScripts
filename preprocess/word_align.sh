OUTPUT_FOLDER=$DATASET_DIR  # 词对齐训练结果存放目录

# import util functions
source $(dirname $0)/../utils/funcs.sh

getDatasetWords () {
  MOSES_SCRIPTS=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh moses)
  # 给定文件序列,训练分词模型
  lang=$1
  tmp_file="$OUTPUT_FOLDER/.$lang.words"  # 中间生成文件，脚本结束后删除
  if [[ $lang == "zh" ]]; then
    cat $(get_all_files_by_lang $lang) | python -m jieba -d " " > $tmp_file
  else
    cat $(get_all_files_by_lang $lang) | $MOSES_SCRIPTS/tokenizer/tokenizer.perl -a -l $lang > $tmp_file
  fi
  echo $tmp_file
}

fast_align () {
  FAST_ALIG_BIN=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh fast_align)
  for lang in $SOURCE_LANG $TARGET_LANG; do
    corpus+="$(getDatasetWords $lang) "
  done

  TRAIN_ALIGN_CORPUS=$DATASET_DIR/corpus_align.$SOURCE_LANG-$TARGET_LANG
  echo $corpus
  paste $corpus | awk -F '\t' '{print $1 " ||| " $2}' > $TRAIN_ALIGN_CORPUS
  $FAST_ALIG_BIN -i $TRAIN_ALIGN_CORPUS -d -o -v > $DATASET_DIR/alignment.$SOURCE_LANG-$TARGET_LANG
}

mgiza () {
  MGIZA_BIN=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh mgiza)
  for lang in $SOURCE_LANG $TARGET_LANG; do
    $MGIZA_BIN/mkcls -n10 -p$(getDatasetWords $lang) "$DATASET_DIR/.$lang.vcb.classes"
  done
}

mgiza

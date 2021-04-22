# 使用moses工具处理数据流水 Clean + Normalize + Tonkenize + Truecase
source $(dirname $0)/../utils/funcs.sh
MOSES_SCRIPTS=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh moses)
EXPORT_TRUECASE_MODEL=$DATASET_DIR/truecase_model
PIPLINE=$*

pipline_clean () {
  for folder in $(find $DATASET_DIR -maxdepth 1 -mindepth 1 -type d ! -name ".*"); do
    mv $folder/$SOURCE_LANG $folder/tmp.$SOURCE_LANG
    mv $folder/$TARGET_LANG $folder/tmp.$TARGET_LANG
    ${MOSES_SCRIPTS}/training/clean-corpus-n.perl -ratio 3 $folder/tmp $SOURCE_LANG $TARGET_LANG $folder/clean 1 120
    mv $folder/clean.$SOURCE_LANG $folder/$SOURCE_LANG
    mv $folder/clean.$TARGET_LANG $folder/$TARGET_LANG
    rm $folder/tmp*
  done
}

pipline_normal_tok () {
  for lang in "$SOURCE_LANG $TARGET_LANG"; do
    all_files=$(get_all_files_by_lang $lang)
    for file in $all_files; do
      # normalize and tokenize
      echo "Normalize and tokenize file $file."
      sacremoses -j 4 normalize < $file > $file.tmp
      sacremoses -l en -j 4 tokenize  < $file.tmp > $file
      rm $file.tmp
    done
  done
}

pipline_truecase () {
  all_corpus="$(get_all_files_by_lang $SOURCE_LANG) $(get_all_files_by_lang $TARGET_LANG)"
  cat $all_corpus > $DATASET_DIR/.corpus 
  # train truecase model
  $MOSES_SCRIPTS/recaser/train-truecaser.perl --model $EXPORT_TRUECASE_MODEL --corpus $DATASET_DIR/.corpus

  for file in $all_corpus; do
    # truecase
    ${MOSES_SCRIPTS}/recaser/truecase.perl --model ${EXPORT_TRUECASE_MODEL} < $file > $file.tmp
    rm $file
    mv $file.tmp $file
  done
}

if [[ $* =~ "normal_tok" ]]
then
  pipline_normal_tok
fi

if [[ $* =~ "clean" ]]
then
  pipline_clean
fi

if [[ $* =~ "truecase" ]]
then
  pipline_truecase
fi

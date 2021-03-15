# 使用moses工具处理数据流水线，针对非中文语料，主要针对拉丁语系 # Normalize + Tonkenize + Truecase
MOSES_SCRIPTS=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh moses)
EXPORT_TRUECASE_MODEL=$DATASET_DIR/truecase_model

source $(dirname $0)/../utils/funcs.sh

for lang in "$SRC_LANG $TGT_LANG"; do
  if [[ $lang != "zh" ]]; then
    all_files=$(get_all_files_by_lang $lang)
    for file in $all_files; do
      # normalize and tokenize
      echo "Normalize and tokenize file $file."
      cat $file | \
      ${MOSES_SCRIPTS}/tokenizer/normalize-punctuation.perl -l $lang | \
      ${MOSES_SCRIPTS}/tokenizer/tokenizer.perl -a -l $lang \
      > $file.tmp
      
      rm $file
      mv $file.tmp $file
      all_corpus+="$file "
    done
  fi
done

cat $all_corpus > $DATASET_DIR/.corpus 

# train truecase model
$MOSES_SCRIPTS/recaser/train-truecaser.perl --model $EXPORT_TRUECASE_MODEL --corpus $DATASET_DIR/.corpus

for file in all_corpus; do
   # truecase
  cat $file | \
      ${MOSES_SCRIPTS}/recaser/truecase.perl --model ${EXPORT_TRUECASE_MODEL}
      > $file.tmp
  rm $file
  mv $file.tmp $file
done

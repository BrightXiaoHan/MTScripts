# 使用sacre_bleu工具对测试集的生成译文进行测试
REF=$1
cat $DATASET_DIR/test.$TARGET_LANG.pred | sacrebleu $REF

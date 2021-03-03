# parse command line options
MODE=$1  # train or test
MODEL_PATH=$DATASET_DIR
DATA_BIN_PATH=$DATASET_DIR/.data_bin
FRAMEWORK_SOURCE_DIR=$(source $(dirname $0)/../utils/prepare_3rd_lib.sh fairseq)

set -e

RUN_PATH=$FRAMEWORK_SOURCE_DIR/fairseq_cli
export PYTHONPATH=$FRAMEWORK_SOURCE_DIR:$PYTHONPATH

if [ -f $DATASET_DIR/$SOURCE_LANG.spm.vocab ] && [ -f $DATASET_DIR/$TARGET_LANG.spm.vocab ]; then
  SOURCE_VOCAB=$DATASET_DIR/$SOURCE_LANG.spm.vocab
  TARGET_VOCAB=$DATASET_DIR/$TARGET_LANG.spm.vocab
elif [ -f $DATASET_DIR/all.spm.vocab ]; then
  SOURCE_VOCAB=$DATASET_DIR/all.spm.vocab
  TARGET_VOCAB=$DATASET_DIR/all.spm.vocab
else
  echo "Can't find vocab from $DATASET_DIR for training."
  exit 1
fi

echo $SOURCE_VOCAB
echo $TARGET_VOCAB
if [ "$MODE" == "train" ]
then
  # Preprocess/binarize the data
  echo "Start prapare data bins..."
  python $RUN_PATH/preprocess.py --source-lang $SOURCE_LANG --target-lang $TARGET_LANG \
      --trainpref $DATASET_DIR/train --validpref $DATASET_DIR/dev \
      --tgtdict $SOURCE_VOCAB \
      --srcdict $TARGET_VOCAB \
      --destdir $DATA_BIN_PATH \
      --workers 20

  echo "Start training..."

  PYTHONIOENCODING=utf-8 python -u $RUN_PATH/train.py  \
      $DATA_BIN_PATH \
      --arch transformer_vaswani_wmt_en_de_big --share-all-embeddings \
      --optimizer adam --adam-betas '(0.9, 0.98)' --clip-norm 0.0 \
      --lr 5e-4 --lr-scheduler inverse_sqrt --warmup-updates 4000 --warmup-init-lr 1e-07 \
      --dropout 0.3 --weight-decay 0.0001 \
      --criterion label_smoothed_cross_entropy --label-smoothing 0.1 \
      --max-update 300000 --max-epoch 200 \
      --patience 20 \
      --attention-dropout 0.1 \
      --max-tokens 8192 \
      --update-freq 2 \
      --eval-bleu \
      --eval-bleu-args '{"beam": 1, "max_len_a": 1.2, "max_len_b": 10}' \
      --eval-bleu-detok moses \
      --eval-bleu-remove-bpe \
      --eval-bleu-print-samples \
      --best-checkpoint-metric bleu --maximize-best-checkpoint-metric \
      --keep-best-checkpoints 10 \
      --ddp-backend=no_c10d \
      --fp16 \
      --save-dir $MODEL_PATH

  echo "Training process has been started in background. Please check $MODEL_PATH/train.log for details."

elif [ "$MODE" == "test" ]
then
  echo "Start prapare data bins for test data..."
  python $RUN_PATH/preprocess.py --source-lang $SOURCE_LANG --target-lang $TARGET_LANG \
      --testpref $DATASET_DIR/test\
      --tgtdict $SOURCE_VOCAB \
      --srcdict $TARGET_VOCAB \
      --destdir $DATA_BIN_PATH \
      --workers 20

  echo "Start eval test set. You can check $MODEL_PATH/test.log for details."
  PYTHONIOENCODING=utf-8 python -u $RUN_PATH/generate.py $DATA_BIN_PATH \
      --path $MODEL_PATH/checkpoint_best.pt \
      --batch-size 512 --beam 5 --remove-bpe sentencepiece --fp16 --lenpen 1.0 2>&1
fi

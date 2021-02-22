# parse command line options
PROJECT_NAME=$1 
SOURCE_LANG=$2
TARGET_LANG=$3 
SOURCE_VOCAB=$4
TARGET_VOCAB=$5
MODE=$6  # train or test

########################## 解析环境变量###################
if [ -z $CUDA_VISIBLE_DEVICES ];
then
  CUDA_VISIBLE_DEVICES=0
fi

if [ -z $MODEL_PATH ];
then
  MODEL_PATH=$EXE_DIR/checkpoints/$PROJECT_NAME
fi

if [ -z $DATA_BIN_PATH ];
then
  DATA_BIN_PATH=$EXE_DIR/data-bins/$PROJECT_NAME
fi

if [ -z $DATASET_DIR ];
then
  DATASET_DIR=$EXE_DIR/datasets/$PROJECT_NAME
fi
########################解析环境变量done################

EXE_DIR=$(dirname $0)  # directory where this script exist
BASE=$(dirname $EXE_DIR)  # prapare fairseq src root dir

RUN_PATH=$BASE/fairseq_cli
export PYTHONPATH=$BASE
export CUDA_VISIBLE_DEVICES=$CUDA_VISIBLE_DEVICES

if [ "$MODE" == "train" ]
then

# Preprocess/binarize the data
echo "Start prapare data bins..."
python $RUN_PATH/preprocess.py --source-lang $SOURCE_LANG --target-lang $TARGET_LANG \
    --trainpref $DATASET_DIR/train --validpref $DATASET_DIR/valid \
    --tgtdict $EXE_DIR/vocab/spm.vocab \
    --srcdict $EXE_DIR/vocab/spm.vocab \
    --destdir $DATA_BIN_PATH \
    --workers 20

echo "Start training..."
mkdir -p $MODEL_PATH

nohup python -u $RUN_PATH/train.py  \
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
    --save-dir $MODEL_PATH > $MODEL_PATH/train.log 2>&1 &

echo "Training process has been started in background. Please check $MODEL_PATH/train.log for details."
elif [ "$MODE" == "test" ]
then
echo "Start prapare data bins for test data..."
python $RUN_PATH/preprocess.py --source-lang $SOURCE_LANG --target-lang $TARGET_LANG \
    --testpref $DATASET_DIR/test\
    --tgtdict $EXE_DIR/vocab/spm.vocab \
    --srcdict $EXE_DIR/vocab/spm.vocab \
    --destdir $DATA_BIN_PATH \
    --workers 20

echo "Start eval test set. You can check $MODEL_PATH/test.log for details."
PYTHONIOENCODING=utf-8 python -u $RUN_PATH/generate.py $DATA_BIN_PATH \
    --path $MODEL_PATH/checkpoint_best.pt \
    --batch-size 512 --beam 5 --remove-bpe sentencepiece --fp16 --lenpen 1.0 2>&1 | tee $MODEL_PATH/test.log
fi


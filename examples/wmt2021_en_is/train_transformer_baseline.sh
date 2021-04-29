# 在英语冰岛语语项训练基线模型
set -e

DATASET_DIR=$(dirname $0)/is-en/parallel
SUBSET_NAME="dev ParaCrawl ParIce1.1 paricename parices-synthetic"
SCRIPTS_SOURCE_ROOT=$(dirname $0)/../..
# 在当前目录创建一个工作目录防止对原数据集目录的污染，或数据修改、丢失
WORKSPACE_DIR=".$(basename $DATASET_DIR)"
if [ -d $WORKSPACE_DIR ];then
  echo "Recreate folder $WORKSPACE_DIR."
  rm -rf $WORKSPACE_DIR
fi

echo "Copying data from $DATASET_DIR to $WORKSPACE_DIR..."
mkdir -p $WORKSPACE_DIR
for name in $SUBSET_NAME; do
  cp -r $DATASET_DIR/$name $WORKSPACE_DIR/$name
done

export DATASET_DIR=$WORKSPACE_DIR
export CUDA_VISIBLE_DEVICES=0,1
export FRAMEWORK_NAME="fairseq"
export SOURCE_LANG="en"
export TARGET_LANG="is"

bash $SCRIPTS_SOURCE_ROOT/preprocess/moses.sh clean normal_tok truecase
bash $SCRIPTS_SOURCE_ROOT/utils/mask_dataset_folder.sh parices-synthetic dev
bash $SCRIPTS_SOURCE_ROOT/preprocess/train_spm_tokenizer.sh 40000 False bpe
bash $SCRIPTS_SOURCE_ROOT/utils/unmask_dataset_folder.sh dev parices-synthetic
bash $SCRIPTS_SOURCE_ROOT/preprocess/tokenize_all.sh
bash $SCRIPTS_SOURCE_ROOT/preprocess/group_train_dev_test.sh "TRAIN=ParaCrawl ParIce1.1 paricename parices-synthetic" "DEV=dev" "TEST=dev"
bash $SCRIPTS_SOURCE_ROOT/fairseq/train_transformer_base.sh train
bash $SCRIPTS_SOURCE_ROOT/fairseq/train_transformer_base.sh test
bash $SCRIPTS_SOURCE_ROOT/fairseq/train_transformer_base.sh inference
bash $SCRIPTS_SOURCE_ROOT/postprocess/detokenize.sh

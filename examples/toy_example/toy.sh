# 中译英机器翻译模型训练示例
set -e

DATASET_DIR=$(dirname $0)/toydatasets
SUBSET_NAME="subset_one subset_two"
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
export CUDA_VISIBLE_DEVICES=0 
export FRAMEWORK_NAME="fairseq"
export SOURCE_LANG="zh"
export TARGET_LANG="en"

bash $SCRIPTS_SOURCE_ROOT/preprocess/segment_chinese_chars.sh
bash $SCRIPTS_SOURCE_ROOT/preprocess/moses.sh normal_tok truecase
# 使用基于非译元素的方法进行term保护
bash $SCRIPTS_SOURCE_ROOT/preprocess/term_protect.sh
# 使用bpe算法训练分词模型，并进行分词
bash $SCRIPTS_SOURCE_ROOT/preprocess/train_spm_tokenizer.sh vocab_size=10000 train_seperate_tokenizer=false algorithm=bpe add_cn_common_chars=true
bash $SCRIPTS_SOURCE_ROOT/preprocess/tokenize_all.sh
 
# 将数据集分为训练集、开发集、测试集
bash $SCRIPTS_SOURCE_ROOT/preprocess/split_train_dev_test.sh
 
# 合并数据集
bash $SCRIPTS_SOURCE_ROOT/preprocess/merge_datasets.sh
 
# # 训练+测试模型
bash $SCRIPTS_SOURCE_ROOT/fairseq/train_transformer_base.sh train
bash $SCRIPTS_SOURCE_ROOT/fairseq/train_transformer_base.sh test

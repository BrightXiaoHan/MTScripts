# 中译英机器翻译模型训练示例
set -e

DATASET_DIR=$(dirname $0)/toydatasets
SUBSET_NAME="subset_one subset_two"
SCRIPTS_SOURCE_ROOT=$(dirname $0)/..

# 在当前目录创建一个工作目录防止对原数据集目录的污染，或数据修改、丢失
WORKSPACE_DIR=".$(basename $DATASET_DIR)"
if [ -d $WORKSPACE_DIR ];then
  echo "Recreate folder $WORKSPACE_DIR."
  rm -rf $WORKSPACE_DIR
fi
mkdir -p $WORKSPACE_DIR
for name in $SUBSET_NAME; do
  cp -r $DATASET_DIR/$name $WORKSPACE_DIR/$name
  echo $WORKSPACE_DIR/$fname
done

export DATASET_DIR=$WORKSPACE_DIR

# 使用基于非译元素的方法进行term保护
bash $SCRIPTS_SOURCE_ROOT/preprocess/term_protect.sh

# 源语言是中文，如果原文和译文中包含中文，可以对中文进行分字处理（可选项）
bash $SCRIPTS_SOURCE_ROOT/preprocess/segment_chinese_chars.sh

# 使用bpe算法训练分词模型，并进行分词
bash $SCRIPTS_SOURCE_ROOT/preprocess/train_spm_tokenizer.sh 10000 False bpe
bash $SCRIPTS_SOURCE_ROOT/preprocess/tokenize_all.sh

# 将数据集分为训练集、开发集、测试集
bash $SCRIPTS_SOURCE_ROOT/preprocess/split_train_dev_test.sh

# 合并数据集
bash $SCRIPTS_SOURCE_ROOT/preprocess/merge_datasets.sh


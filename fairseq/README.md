# 模型训练脚本(fairseq)
本目录的脚本基于[fairseq v0.10.1](https://github.com/pytorch/fairseq/releases/tag/v0.10.1)

## 训练Transformer基线模型
```
usage:
  bash train_transformer_base.sh train $SRC_LANG $TGT_LANG
  bash train_transformer_base.sh test $SRC_LANG $TGT_LANG

environment variables:
  DATASET_DIR: 数据集存放文件夹, 工作目录
  FRAMEWORK_SOURCE_DIR: fairseq源码目录
  CUDA_VISIABLE_DEVICE: 可见的cuda设备

positional:
  mode: train or test
  source_lang: 原文语言类型，如zh，en等
  target_lang: 译文语言类型，如zh，en等

Notes:
  - 脚本会以nohup的形式在后台运行，输出模型和打印日志会存放在目录`DATASET_DIR`中
```

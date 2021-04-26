# 模型训练脚本(fairseq)
本目录的脚本基于[fairseq v0.10.1](https://github.com/pytorch/fairseq/releases/tag/v0.10.1)

## 训练Transformer基线模型
```
usage:
  bash train_transformer_base.sh train $SRC_LANG $TGT_LANG
  bash train_transformer_base.sh test $SRC_LANG $TGT_LANG

environment variables:
  DATASET_DIR: 数据集存放文件夹, 工作目录
  CUDA_VISIABLE_DEVICE: 可见的cuda设备

positional:
  mode: train or test
  source_lang: 原文语言类型，如zh，en等
  target_lang: 译文语言类型，如zh，en等

Notes:
  - 脚本会以nohup的形式在后台运行，输出模型和打印日志会存放在目录`DATASET_DIR`中
```

## 注意事项
脚本中运行fairseq-train, 以及fairseq-generate命令时指定的一些参数要根据系统的硬件配置进行调整。否则会出现系统资源利用不充分，或者显存溢出的情况。

在训练过程中通过--max-update, --max-epoch, --patience三个参数设置了训练停止条件，具体可以根据语料的大小进行调整。

具体参考[fairseq Command-line tools](https://fairseq.readthedocs.io/en/latest/command_line_tools.html)

# 数据预处理
本目录存放了数据预处理相关的脚本

## python 辅助脚本
python 脚本只作为辅助，供bash脚本调用，实现bash脚本无法实现的功能，无需直接调用这些python脚本

1. 中文分字脚本：[segment_chinese_chars.py](./python/segment_chinese_chars.py)
```
usage:
  python segment_chinese_chars.py input_file output_file

positional arguments:
  input_file   输入文件路径
  output_file  输出文件路径
```

2. 非译元素保护脚本：[term_protect.py](./python/term_protect.py)
```
usage:
  python term_protect.py [--suffix SUFFIX] [--src_lang SRC_LANG]
                       [--tgt_lang TGT_LANG] [--output_folder OUTPUT_FOLDER]
                       src tgt

positional arguments:
  src                   平行语料原文文件路径。
  tgt                   平行语料译文文件路径。

optional arguments:
  --suffix SUFFIX       datasets/zh.train ->
                        datasets/zh.train.mask,其中suffix的值为mask。
  --src_lang SRC_LANG   原文语言类型
  --tgt_lang TGT_LANG   译文语言类型
  --output_folder OUTPUT_FOLDER
                        进行术语保护后的语料的输出文件夹，如果不进行指定，则默认存如原文件对应的文件夹。
```

## bash 脚本
1. 中文分字脚本[segment_chinese_chars.sh](./segment_chinese_chars.sh) 
```
usage:
  [DATASET_DIR=dataset_dir] bash segment_chinese_chars.sh

environment variables:
  DATASET_DIR: 数据集存放文件夹

Note:
  该脚本执行生成结果会替换原文件，执行该脚本前请做好备份。只对文件夹中`zh`开头的文件进行处理。
```

2. 基于非译元素的term保护脚本[term_protect.sh](./term_protect.sh)
```
usage:
  [DATASET_DIR=dataset_dir] bash ./term_protect.sh

  environment variables:
    DATASET_DIR: 数据集存放文件夹

  Note:
    - 该脚本目前只能处理原文或者译文为中文时的语料。因为该脚本的原理是发现中文中的非中文字符，再去其他语言中找与之对应的元素来实现的。
    - 该脚本会在`DATASET_DIR`目录下创建一个独立的文件夹存储生成的数据, 文件夹名字为原文件夹名字后面加`_mask`
```


3. 基于sentencepiece工具的分词模型训练脚本[train_spm_tokenizer.sh](./train_spm_tokenizer.sh)
```
usage:
  [DATASET_DIR=dataset_dir] bash train_spm_tokenizer.sh vocab_size False bpe

environment variables:
  DATASET_DIR: 数据集存放文件夹

positional arguments:
  vocab_size: spm训练生成的词表大小
  train_seperate_tokenizer: 是否为原文译文训练单独的词表,True时分别训练词表,False时训练一个词表。（注意`True`之外的所有字符串都会被默认为`False`）
  algorithm: 指定分词模型算法。可用的分词算法有`bpe`，`unigram`

Notes:
  - 最终训练好的模型会存放在`DATASET_DIR`目录下，命名方式为`$lang.spm.vocab`，`$lang.spm.model`
  - 如果sentencepiece训练过程中报错，可能是训练数据集过大，可以在脚本中加入----input_sentence_size参数，参数的解释可以参考https://github.com/google/sentencepiece/blob/master/doc/options.md
```

4. 分词脚本[tokenzie_all.sh](./tokenize_all.sh)
```
bash tokenize_all.sh

environment variables:
  DATASET_DIR: 数据集存放文件夹
  FRAMEWORK_NAME: 机器翻译训练框架名称，fairseq或者opennmt

Notes:
  1. 该脚本会对`DATASET_DIR`中所有子目录的文件进行分词操作，使用存放在`DATASET_DIR`中的分词模型进行分词。分词后的语料将会替换原始语料，请做好数据备份。
  2. 如果`DATASET_DIR`中存在`all.spm.model`则对所有语言使用该分词模型进行分。词否则，则对每种语言使用不同的分词模型进行分词，比如所有`en`语料使用`en.spm.model`模型进行分词
  3. 如果训练框架为fairseq，由于框架要求的词表格式与sentencepiece输出的格式不一样，所以会对`$lang.spm.vocab`进行处理。 
```

5. 数据集分割脚本[split_train_dev_test.sh](./split_train_dev_test.sh)
```
bash split_train_dev_test.sh
environment variables:
  DATASET_DIR: 数据集存放文件夹

Notes:
  - 将原始数据集分为train,test,dev，分别命名为`$lang.train, $lang.dev, $lang.test`。分割后原始文件将被删除，请做好数据备份。
```


6. 合并不同数据集文件中的数据[merge_datasets.sh](./merge_datasets.sh)
```
usage:
  [DATASET_DIR=dataset_dir] bash merge_datasets.sh

environment variables:
  DATASET_DIR: 数据集存放文件夹
  FRAMEWORK_NAME: 框架名称，fairseq或者opennmt
Notes:
  - 该脚本将以`DATASET_DIR`中的一个子数据集文件夹中的文件作为基准，合并其他子数据集文件夹中的同名文件。合并生成的文件将以相同的名字存放在`DATASET_DIR`中。
  - 如果`FRAMEWORK_NAME`为fairseq，则输出`train.$lang, dev.$lang, test.$lang`，否则输出`$lang.train, $lang.dev, $lang.test`
```

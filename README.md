# MTModelTrainer
机器翻译模型训练脚本，基于开源机器翻译框架Opennmt以及fairseq。

## 环境配置
### 系统要求
- centos 7, 8
- nvidia gpu and cuda installed

### 软件要求
- gcc, make, cmake
- pytorch>1.5
- anaconda
- python>3.6
- fairseq==v0.10.2 (参考官方安装指南，如需要可安装apex、pyarrow等依赖包)

### 安装其他依赖包
```
pip install -i https://pypi.douban.com/simple -r requirements.txt
```

## 快速开始
```
bash examples/toy.sh
```


## 数据集准备
### 1. 准备数据集文件夹
按照数据集清洗要求对数据集进行清洗，将每个不同领域或者不同来源的数据集存放在一个单独的目录中。目录中应当有且仅有平行语料对文件，并且以语言类型的简写进行命名。语言简写与语言类型的映射关系如下表。

|  语言类型   | 简写 |
|  ----  | ----  |
| 中文 | zh |
| 英文 | en |

<span id="anchor">数据集文件夹文件结构示例如下：</span>
```
.
├── general_domain_zhen
│   ├── en
│   └── zh
├── short_terms_zhen
│   ├── en
│   └── zh
└── traffic_zh_en
    ├── en
    └── zh
```

### 2. 指定环境变量
本项目中的脚本执行会依赖下列环境变量进行执行。

| Variable Name | Example | Remarks |
| :-----| ----: | :----: |
| DATASET_DIR | /path/to/dataset_dir | 数据集所在的文件夹，目录中每个目录为一个子数据集。子数据集中的数据以语言类型命名，如zh，en。（注意子数据集目录中不要包含其他文件，每个原文文件对应一个译文文件，请确保以上条件满足，若不满足可能会造成错误）|
| SOURCE_LANG | zh  | 原文语言类型 |
| TARGET_LANG | en  | 译文语言类型 |
| FRAMEWORK_NAME | fairseq or opennmt | 机器翻译模型训练所使用的框架名称，fairseq或者opennmt。 |
| FRAMEWORK_VERSION | v0.10.2 | 训练框架的commit_id, tag 或者branch ｜ 
| CUDA_VISIABLE_DEVICE | 0,1 | 可见的cuda设备  |

### 3. 数据预处理
数据预处理的相关脚本都存放在[preprocess](./preprocess)目录，脚本相关说明及具体用法可以参考[README.md](./preprocess/README.md)。下面用具体例子说明如何使用这些脚本进行数据的预处理。

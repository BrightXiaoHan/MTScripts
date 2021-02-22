"""
做term保护，主要对非译元素进行，在inference的过程中可以通过mask term对专业术语进行保护。
"""
import argparse
import os
import re

from tqdm import tqdm

# 需要用到的一些正则表达式
RE_HAN = re.compile("([\u4E00-\u9FD5]+)")  # 用于提取连续的汉字部分
RE_SKIP = re.compile(r"([a-zA-Z0-9-. %:=°]+)")  # 用于分割连续的非汉字部分
RE_BLANK = re.compile(r"\s+$")
RE_EN = re.compile(r"([a-zA-Z0-9]+)")


def parse_args():
    """
    解析脚本参数
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("src", type=str, help="平行语料原文文件路径。")
    parser.add_argument("tgt", type=str, help="平行语料译文文件路径。")
    parser.add_argument("--suffix", type=str, default="",
                        help="datasets/zh.train -> datasets/zh.train.mask,"
                        "其中suffix的值为mask。")
    parser.add_argument("--src_lang", type=str, default="zh", help="原文语言类型")
    parser.add_argument("--tgt_lang", type=str, default="en", help="译文语言类型")
    parser.add_argument("--output_folder", type=str, default=None,
                        help="进行术语保护后的语料的输出文件夹，如果不进行指定，则默认存如原文件对应的文件夹。")
    args = parser.parse_args()
    return args


def extract_no_han(sentence):
    """
    抽取中文中的非译元素，如英文字符或者数字等

    Args:
        sentence (str): 输入文本

    Return:
        list: 返回句子中的所有非译元素，按照出现顺序

    Example:
        >>> sentence = "我出生于1995年，今年24岁"
        >>> extract_no_han(sentence)
        ['1995', '24']
    """
    blocks = RE_HAN.split(sentence)
    result = []
    for block in blocks:
        if not block:
            continue
        if RE_HAN.match(block):
            continue
        else:
            result.extend([i.strip() for i in RE_SKIP.split(
                block) if RE_SKIP.match(i) and RE_EN.search(i)])

    return result


def mask(src, tgt, src_lang="zh", tgt_lang="en"):
    """
    对于原文译文的非译元素进行保护，目前只支持中英之间的保护。

    Args:
        src (str): 原文
        tgt (str): 译文
        src_lang (str, optional): Default is "zh"
            由于是以中文中的非汉字部分作为种子去寻找非译元素，
            所以默认原文的语言是中文。如果需要调整，可指定原文译文的语言类型。
        tgt_lang (str, optional): Default is "en"

    Return:
        str, str: 被保护的元素被替换成<symbol1>, <symbol2>这些符号

    Example:
        >>> src = "我出生于1995年，今年ABD24RR岁"
        >>> tgt = "I was born in 1995, and I'm ABD24RR years old"
        >>> mask(src, tgt)
        ('我出生于<symbol1>年，今年<symbol0>岁', "I was born in <symbol1>, and I'm <symbol0> years old")
    """
    if src_lang != "zh" and tgt_lang == "zh":
        src, tgt = tgt, src

    no_han = list(set(extract_no_han(src)))
    no_han.sort(key=len, reverse=True)
    all_mask = []

    for i, symbol in enumerate(no_han):

        # 如果当前需要保护的元素会替换保护字符串 <symbol0>，则不对该元素进行替换
        flag = True
        for item in all_mask:
            if item.count(symbol) > 0:
                flag = False

        if not flag:
            continue
        mask_symbol = "<symbol%d>" % i
        if src.count(symbol) == tgt.count(symbol) == 1:
            src = src.replace(symbol, mask_symbol)
            tgt = tgt.replace(symbol, mask_symbol)
            all_mask.append(mask_symbol)

    return src, tgt


def main():
    """
    脚本入口函数
    """
    args = parse_args()
    with open(args.src) as src_file:
        src_corpus = src_file.readlines()

    with open(args.tgt) as tgt_file:
        tgt_corpus = tgt_file.readlines()

    assert len(src_corpus) == len(tgt_corpus)

    if args.output_folder:
        src_basename = os.path.basename(args.src) + args.suffix
        src_f = open(os.path.join(args.output_folder, src_basename), 'w')
        tgt_basename = os.path.basename(args.tgt) + args.suffix
        tgt_f = open(os.path.join(args.output_folder, tgt_basename), 'w')

    else:
        src_f = open(args.src + args.suffix, 'w')
        tgt_f = open(args.tgt + args.suffix, 'w')
    for src, tgt in tqdm(zip(src_corpus, tgt_corpus)):
        processed_src, processed_tgt = mask(
            src, tgt, args.src_lang, args.tgt_lang)
        if src != processed_src and tgt != processed_tgt:
            src_f.write(processed_src)
            tgt_f.write(processed_tgt)

    src_f.close()
    tgt_f.close()


if __name__ == "__main__":
    main()

"""
将分字的中文语料中的空格去掉
"""
import re
import argparse

from tqdm import tqdm


def remove_whitespace(input_file, output_file):
    re_han_left = re.compile("([\\u4e00-\\u9fef])(\\s+)")
    re_han_right = re.compile("(\\s+)([\\u4e00-\\u9fef])")
    with open(input_file) as inpf:
        with open(output_file, "w") as outf:
            for line in tqdm(inpf,
                             desc="Removing whitespace for file {}...".format(
                                 input_file)):
                line = line.strip()
                line = re_han_left.sub("\\g<1>", line)
                line = re_han_right.sub("\\g<2>", line)
                outf.write(line)
                outf.write("\n")


def parse_args():
    """
    解析脚本参数
    """
    parser = argparse.ArgumentParser("基础分词器，将中文按字符分开。")
    parser.add_argument("input_file", type=str, help="输入文件路径")
    parser.add_argument("output_file", type=str, help="输出文件路径")
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = parse_args()
    remove_whitespace(args.input_file, args.output_file)

"""
将中文进行分字的脚本，借鉴https://github.com/google-research/bert/blob/master/tokenization.py
"""
import argparse

from tqdm import tqdm


def tokenize_chinese_chars(text):
    """Adds whitespace around any CJK character."""
    output = []
    for char in text:
        cp = ord(char)
        if _is_chinese_char(cp):
            output.append(" ")
            output.append(char)
            output.append(" ")
        else:
            output.append(char)
    ans = "".join(output)
    return ans.replace("  ", " ")


def _is_chinese_char(cp):
    """Checks whether CP is the codepoint of a CJK character."""
    # This defines a "chinese character" as anything in the CJK Unicode block:
    #   https://en.wikipedia.org/wiki/CJK_Unified_Ideographs_(Unicode_block)
    #
    # Note that the CJK Unicode block is NOT all Japanese and Korean characters,
    # despite its name. The modern Korean Hangul alphabet is a different block,
    # as is Japanese Hiragana and Katakana. Those alphabets are used to write
    # space-separated words, so they are not treated specially and handled
    # like the all of the other languages.
    if ((cp >= 0x4E00 and cp <= 0x9FFF) or  #
        (cp >= 0x3400 and cp <= 0x4DBF) or  #
        (cp >= 0x20000 and cp <= 0x2A6DF) or  #
        (cp >= 0x2A700 and cp <= 0x2B73F) or  #
        (cp >= 0x2B740 and cp <= 0x2B81F) or  #
        (cp >= 0x2B820 and cp <= 0x2CEAF) or
        (cp >= 0xF900 and cp <= 0xFAFF) or  #
            (cp >= 0x2F800 and cp <= 0x2FA1F)):  #
        return True

    return False


def basic_tokenize(input_file, output_file):
    with open(input_file) as inpf:
        with open(output_file, "w") as outf:
            for line in tqdm(inpf, desc="Tokenizing file {}...".format(input_file)):
                line = line.strip()
                line = tokenize_chinese_chars(line)
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
    basic_tokenize(args.input_file, args.output_file)

import os
import re
import json
import fileinput
from translate.storage.tmx import tmxfile
from tqdm import tqdm
from joblib import parallel_backend, delayed, Parallel
from pylib._third_party import download


def download_corpus(parallel_pairs, monolingual):
    """
    下载和语项相关的所有语料

    Args:
        parallel_pairs (list): 平行语料对，如"zh-en", "is-en"等
        monolingual (list): 单语语料，如"zh", "en"
    """
    config_dir = "datasets"
    jobs = []
    for pair in parallel_pairs:
        if not os.path.isdir(
                os.path.join(config_dir, "parallel", pair + ".json")):
            pair = "-".join(reversed(pair.split("-")))
        with open(os.path.join(config_dir, "parallel", pair + ".json")) as f:
            corpus = json.load(f)

        for key, value in corpus.items():
            if isinstance(value, str):
                jobs.append((value, ".{}".format(pair)))
        else:
            for url in value:
                jobs.append((url, os.path.join(".{}".format(pair), key)))

    for lang in monolingual:
        with open(os.path.join(config_dir, "monolingual",
                               lang + ".json")) as f:
            corpus = json.load(f)

        for key, value in corpus.items():
            if isinstance(value, str):
                jobs.append((value, ".{}".format(lang)))
        else:
            for url in value:
                jobs.append((url, os.path.join(".{}".format(lang), key)))

    with parallel_backend('threading', n_jobs=len(jobs)):
        Parallel()(delayed(download.download_file_maybe_extract)(*job)
                   for job in jobs)


def write_corpus(destination, corpus, src_lang, tgt_lang=None):
    """
    Save parallel corpus to sepecific destination.

    Args:
        destination (Path): Path to save corpus.
        corpus (iterator): Each element is a pair of parallel sentences.
        src_langs (str): Source language type.
        tgt_langs (str, optional): Default is None. Target language type.

    Note:
        If you want to write monolingual corpus, you can set tgt_lang=None
        and each element of corpus contain only one sentence instead of two.
    """
    if not os.path.exists(destination):
        os.makedirs(destination)
    src_output_file = open(os.path.join(destination, src_lang), "w")
    if tgt_lang:
        tgt_output_file = open(os.path.join(destination, tgt_lang), "w")

    for item in tqdm(corpus):
        print(item[0], file=src_output_file)
        if tgt_lang:
            print(item[1], file=tgt_output_file)

    src_output_file.close()
    if tgt_lang:
        tgt_output_file.close()


def tsv_file_parser(files, src_index=0, tgt_index=1):
    """
    Extract parallel sentences from .tsv files

    Args:
        files (str or list): path or list of path of tsv files
        src_index (int): the row index of source sentence
        tgt_index (int): the row index of target sentence
    """
    if isinstance(files, str):
        files = [files]

    for filename in files:
        open_file = open(filename)

        for line in open_file:
            line = line.strip().split("\t")
            if len(line) <= max(src_index, tgt_index):
                continue
            yield [line[src_index], line[tgt_index]]

        open_file.close()


def linebyline_file_parser(files):
    """
    Extract parallel sentences from raw txt.
    One line of original and one line of translation
    """
    if isinstance(files, str):
        files = [files]

    for filename in files:
        open_file = open(filename)
        src, tgt = "", ""

        for i, line in enumerate(open_file):
            line = line.strip()
            if i % 2 == 0:
                src = line
            else:
                tgt = line
                yield [src, tgt]
        open_file.close()


def regx_file_parser(src_files, regx_src, tgt_files, regx_tgt):
    """
    Extract line from files which satisify given regx.
    """
    if isinstance(src_files, str):
        src_files = [src_files]

    if isinstance(tgt_files, str):
        tgt_files = [tgt_files]

    for src_file, tgt_file in zip(src_files, tgt_files):
        src_lines = map(lambda x: re.search(regx_src, x),
                        fileinput.input(src_file))
        src_lines = [obj.group(1) for obj in src_lines if obj]

        tgt_lines = map(lambda x: re.search(regx_tgt, x),
                        fileinput.input(tgt_file))
        tgt_lines = [obj.group(1) for obj in tgt_lines if obj]
        assert len(src_lines) == len(
            tgt_lines
        ), "The number of lines in the two files is different. {},{}".format(
            src_file, tgt_file)

        yield from zip(src_lines, tgt_lines)


def lambda_file_parser(src_files, func_src, tgt_files, func_tgt):
    """
    Extract line from files by given func
    """
    if isinstance(src_files, str):
        src_files = [src_files]

    if isinstance(tgt_files, str):
        tgt_files = [tgt_files]

    for src_file, tgt_file in zip(src_files, tgt_files):
        src_lines = map(func_src, fileinput.input(src_file))
        src_lines = list(filter(None, src_lines))
        tgt_lines = map(func_tgt, fileinput.input(tgt_file))
        tgt_lines = list(filter(None, tgt_lines))
        yield from zip(src_lines, tgt_lines)


def tmx_file_parser(files, src_lang, tgt_lang):
    """
    Extract parallel sentences from .tmx files

    Args:
        fiies (str or list): path or list of path of tmx files
        src_lang (str): language type of source sentences
        tgt_lang (str): language type of target sentences
    """
    if isinstance(files, str):
        files = [files]

    def parse_parice_tmx(file_path):
        with open(file_path, 'rb') as fin:
            tmx_file = tmxfile(fin, src_lang, tgt_lang)
        for node in tmx_file.unit_iter():
            yield [node.source, node.target]

    for path in files:
        yield from parse_parice_tmx(path)


def seperate_file_parser(src_files, tgt_files):
    """
    Extract parallel sentences from seperated files

    Args:
        src_files: files contain source sentences.
        tgt_files: files contain target sentences.
    """
    if isinstance(src_files, str):
        src_files = [src_files]

    if isinstance(tgt_files, str):
        tgt_files = [tgt_files]

    for src_file, tgt_file in zip(src_files, tgt_files):
        with open(src_file) as f1, open(tgt_file) as f2:
            for src_line, tgt_line in zip(f1, f2):
                yield [src_line.strip(), tgt_line.strip()]


def monolingual_seperate_file_parser(files):
    """
    Extract monolingual corpus from seperated files

    Args:
        files: files contain monolingual sentences
    """
    for filename in files:
        with open(filename, "r") as f:
            for line in f:
                yield [line.strip()]

import os
import wget
import shutil

from xtract import xtract
from translate.storage.tmx import tmxfile
from tqdm import tqdm


def download_warpper(url, destination, derivation):
    """
    Wrap functions with this wrapper will automantic download corpus and extract files from achieves.

    Args:
        url (str): url of corpus to be downloaded.
        destination (str): path to save downloaded file. if "url" is a, this argument is a folder path, else is a file path.
        derivation (str): specify where corpus files should be extracted.
    """
    def wrapper(func):
        def inner_func(*args, **kwargs):
            if not os.path.exists(destination) and not os.path.exists(derivation):
                try:
                    print("Downloading dataset from url {} to {}...".format(
                        url, destination))
                    wget.download(url, destination)
                except Exception as e:
                    if os.path.exists(destination):
                        os.remove(destination)
                    raise e
            if not os.path.exists(derivation):
                try:
                    print("Extracting dataset from {} to {}...".format(
                        destination, derivation))
                    xtract(destination, derivation, all=True)
                except Exception as e:
                    shutil.rmtree(derivation)

            return func(*args, **kwargs)
        return inner_func

    return wrapper


def write_corpus(destination, corpus, src_lang, tgt_lang):
    """
    Save parallel corpus to sepecific destination.

    Args:
        destination (Path): Path to save corpus.
        corpus (iterator): Each element is a pair of parallel sentences.
        src_langs (str): Source language type.
        tgt_langs (str): Target language type.
    """
    if not os.path.exists(destination):
        os.makedirs(destination)
    src_output_file = open(os.path.join(destination, src_lang), "w")
    tgt_output_file = open(os.path.join(destination, tgt_lang), "w")

    for src_line, tgt_line in tqdm(corpus):
        print(src_line, file=src_output_file)
        print(tgt_line, file=tgt_output_file)

    src_output_file.close()
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
    for src_file, tgt_file in zip(src_files, tgt_files):
        with open(src_file) as f1, open(tgt_file) as f2:
            for src_line, tgt_line in zip(f1, f2):
                yield [src_line.strip(), tgt_line.strip()]

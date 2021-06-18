"""
Inference script for fairseq model
"""
import argparse
from tqdm import tqdm
from more_itertools import chunked
from fairseq.models.transformer import TransformerModel


def parse_args():
    """
    解析参数
    """
    parser = argparse.ArgumentParser()
    parser.add_argument("input_file", type=str)
    parser.add_argument("output_file", type=str)
    parser.add_argument("--device", type=str, default="cuda:0")
    parser.add_argument("--folder", type=str)
    parser.add_argument("--beam_size", type=int)
    parser.add_argument("--batch_size", type=int)
    parser.add_argument("--replace_unk", action="store_true", default=False)
    args = parser.parse_args()
    return args


def translate(input_file,
              output_file,
              device,
              folder,
              beam_size=3,
              batch_size=256,
              replace_unk=False):
    translator = TransformerModel.from_pretrained(
        folder,
        checkpoint_file='checkpoint_best.pt',
        beam=beam_size)
    translator.to(device)
    translator.eval()

    input_f = open(input_file, "r")
    output_f = open(output_file, "w")

    for batch in tqdm(chunked(input_f, batch_size)):
        for src, sentence in zip(batch, translator.translate(batch)):
            if replace_unk:
                sentence = sentence.replace("<unk>", "")
                sentence = sentence.replace("▁< unk >", "")
                sentence = sentence.replace("  ", " ")
            print("Source text: {}".format(src.strip()))
            print("Translation text: {}".format(sentence))
            print(sentence, file=output_f)

def main():
    args = parse_args()
    translate(args.input_file,
              args.output_file,
              args.device,
              args.folder,
              args.beam_size,
              args.batch_size,
              args.replace_unk)


if __name__ == "__main__":
    main()

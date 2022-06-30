#!/bin/bash

path_to_conda_sh=/home/ubuntu/anaconda3/etc/profile.d/conda.sh
# differentiate between running on kubeflow vs ec2
if [[ -f $path_to_conda_sh ]]; then
    . /home/ubuntu/anaconda3/etc/profile.d/conda.sh && conda deactivate && conda activate nisqa
else
    . /opt/conda/etc/profile.d/conda.sh && conda deactivate && conda activate nisqa
fi

n_flag=''
q_flag=''

print_usage() {
  printf "Usage: ..."
}

while getopts 'nq' flag; do
  case "${flag}" in
    n) n_flag='true' ;;
    q) q_flag='true' ;;
    *) print_usage
       exit 1 ;;
    esac
done 


if $q_flag; then
    for speaker_dir in to_evaluate/input/*/; do
        speaker=$(basename $speaker_dir)
        echo $speaker $speaker_dir
        mkdir -p ./to_evaluate/results/quality/"$speaker"
        python ./run_predict.py --mode predict_dir --pretrained_model weights/nisqa.tar --data_dir "${speaker_dir}" --num_workers 0 --bs 10 --output_dir to_evaluate/results/quality/"${speaker}"
    done
fi

if $n_flag; then
    for speaker_dir in to_evaluate/input/*/; do
        speaker=$(basename $speaker_dir)
        echo $speaker $speaker_dir
        mkdir -p ./to_evaluate/results/naturalness/"$speaker"
        python ./run_predict.py --mode predict_dir --pretrained_model weights/nisqa_tts.tar --data_dir "${speaker_dir}" --num_workers 0 --bs 10 --output_dir to_evaluate/results/naturalness/"${speaker}"
        
    done
fi

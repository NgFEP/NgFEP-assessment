sed -id "s/GTX_1080_Ti/RTX_3090/g" extract_results.sh
./extract_results.sh
sed -id "s/RTX_3090/RTX_A4500/g" extract_results.sh
sed -id "s/gpu_cuda_0_/gpu_cuda_1_/g" extract_results.sh
./extract_results.sh
sed -id "s/RTX_A4500/RTX_5000/g" extract_results.sh
sed -id "s/gpu_cuda_1_/gpu_cuda_2_/g" extract_results.sh
./extract_results.sh


sed -id "s/GTX_1080_Ti/TITAN_V/g" extract_results.sh
./extract_results.sh
sed -id "s/TITAN_V/RTX 5000/g" extract_results.sh
sed -id "s/gpu_cuda_0_/gpu_cuda_2_/g" extract_results.sh
./extract_results.sh
rm *.shd

export RISCV=/home/artemi/thesis/RISCV/
# Make sure to source this script from the root directory 
# to correctly set the environment variables related to the tools
source verif/sim/setup-env.sh

# Set the NUM_JOBS variable to increase the number of parallel make jobs
# export NUM_JOBS=

export DV_SIMULATORS=veri-testharness
export VERILATOR_ROOT=/home/artemi/thesis/cva6/tools/verilator-v5.008/build-v5.008
export TRACE_FAST=1

cd ./verif/sim


#python3 cva6.py --target cv64a6_mmu or cv64a6_imafdc_sv39 --iss=$DV_SIMULATORS --iss_yaml=cva6.yaml --asm_tests /home/artemi/thesis/cva6/verif/tests/custom/cv_xif/cvxif_rs3.S --linker=../tests/custom/common/test.ld --gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib \
#-nostartfiles -g ../tests/custom/common/syscalls.c \
#../tests/custom/common/crt.S -lgcc \
#-I../tests/custom/env -I../tests/custom/common" -v


#python3 cva6.py --target cv64a6_imafdc_sv39 --iss=$DV_SIMULATORS --iss_yaml=cva6.yaml --c_tests ../tests/custom/hello_world/hello_world.c --linker=../tests/custom/common/test.ld --gcc_opts="-static -mcmodel=medany -fvisibility=hidden -nostdlib \
python3 cva6.py --target cv64a6_imafdc_sv39 --iss=$DV_SIMULATORS --iss_yaml=cva6.yaml --c_tests /home/artemi/Matrix-Multiplication-Simulation/matrix_mult_v1.c --linker=../tests/custom/common/test.ld --gcc_opts="-static -mcmodel=medany -nostdlib \
-nostartfiles -g ../tests/custom/common/syscalls.c \
../tests/custom/common/crt.S -lgcc \
-I../tests/custom/env -I../tests/custom/common" -v

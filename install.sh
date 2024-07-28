cd $R4L_DRV
git clone --depth=20 https://github.com/happy-thw/linux_raspberrypi.git
cd linux_raspberrypi
# Requires dependent libraries
apt install libelf-dev libgmp-dev libmpc-dev bc flex bison u-boot-tools
apt install llvm-17 lld-17 clang-17
# 这里选择的是clang-17的版本，rust for linux 最少也要12以上，并且下面的LLVM根据相应的版本选择

# Requires Rust dependent libs
rustup override set $(scripts/min-tool-version.sh rustc)
rustup component add rust-src
cargo install --locked --version $(scripts/min-tool-version.sh bindgen) bindgen-cli
make ARCH=arm64  O=build_4b LLVM=-17 rustavailable
# Rust is available!  即支持rust

make ARCH=arm64 O=build_4b LLVM=-17 bcm2711_rust_defconfig
make ARCH=arm64 O=build_4b LLVM=-17 -j$(nproc)

# (可选项) 修改.config可通过
make ARCH=arm64 O=build_4b LLVM=-17 menuconfig
# (可选项) 保存修改的.config为默认config
make ARCH=arm64 O=build_4b LLVM=-17 savedefconfig && mv build_4b/defconfig arch/arm64/configs/bcm2711_rust_defconfig
# (可选项) 删除之前编译所生成的文件和配置文件
make ARCH=arm64 O=build_4b LLVM=-17 mrproper
# (可选项) 使用rust-analyzer
make ARCH=arm64 O=build_4b LLVM=-17 rust-analyzer

# 没有出现error，则编译成功，相应的kernel镜像文件和设备树文件在以下路径
ls ./build_4b/arch/arm64/boot/Image
ls ./build_4b/arch/arm64/boot/dts/broadcom/*.dtb


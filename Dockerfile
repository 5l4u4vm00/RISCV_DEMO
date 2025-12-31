# RISC-V CPU Development Environment
# Contains Verilog simulation, waveform viewer, RISC-V toolchain, Neovim + LazyVim

FROM ubuntu:22.04

LABEL maintainer="RISC-V CPU Dev Environment"
LABEL description="Complete development environment for RISC-V CPU design with Verilog"

# Avoid interactive installation prompts
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Taipei

# Basic tools and dependencies
RUN apt-get update && apt-get install -y \
    # Basic development tools
    build-essential \
    git \
    curl \
    wget \
    # Verilog simulation tools
    iverilog \
    verilator \
    # Waveform viewer
    gtkwave \
    # Python environment (for cocotb, etc.)
    python3 \
    python3-pip \
    python3-venv \
    # RISC-V toolchain dependencies
    autoconf \
    automake \
    autotools-dev \
    libmpc-dev \
    libmpfr-dev \
    libgmp-dev \
    gawk \
    bison \
    flex \
    texinfo \
    gperf \
    libtool \
    patchutils \
    bc \
    zlib1g-dev \
    libexpat-dev \
    ninja-build \
    # Other useful tools
    make \
    cmake \
    device-tree-compiler \
    # Neovim dependencies
    software-properties-common \
    unzip \
    ripgrep \
    fd-find \
    fzf \
    xclip \
    && rm -rf /var/lib/apt/lists/*

# Install lazygit (download from GitHub release)
RUN LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": "v\K[^"]*') && \
    curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/latest/download/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz" && \
    tar xf lazygit.tar.gz lazygit && \
    install lazygit /usr/local/bin && \
    rm lazygit.tar.gz lazygit

# ============================
# Install Neovim (v0.11.5 stable)
# ============================
RUN curl -LO https://github.com/neovim/neovim/releases/download/v0.11.5/nvim-linux-x86_64.tar.gz && \
    tar -xzf nvim-linux-x86_64.tar.gz -C /opt && \
    ln -s /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim && \
    rm nvim-linux-x86_64.tar.gz

# Set fd alias (Ubuntu's fd-find is installed as fdfind)
RUN ln -s $(which fdfind) /usr/local/bin/fd

# ============================
# Install Node.js (required by some LazyVim plugins)
# ============================
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && \
    apt-get install -y nodejs && \
    rm -rf /var/lib/apt/lists/*

# ============================
# Install Lua Language Server
# ============================
RUN mkdir -p /opt/lua-language-server && \
    curl -L https://github.com/LuaLS/lua-language-server/releases/download/3.10.6/lua-language-server-3.10.6-linux-x64.tar.gz | \
    tar -xz -C /opt/lua-language-server && \
    ln -s /opt/lua-language-server/bin/lua-language-server /usr/local/bin/lua-language-server

# Install Python packages
RUN pip3 install --no-cache-dir \
    cocotb \
    pytest \
    pyverilog \
    hdl-checker

# Create working directory
WORKDIR /workspace

# Download pre-compiled RISC-V GNU Toolchain (RV32)
# Use pre-compiled version provided by SiFive to save compilation time
RUN mkdir -p /opt/riscv && \
    cd /tmp && \
    wget -q https://github.com/stnolting/riscv-gcc-prebuilt/releases/download/rv32i-131023/riscv32-unknown-elf.gcc-13.2.0.tar.gz && \
    tar -xzf riscv32-unknown-elf.gcc-13.2.0.tar.gz -C /opt/riscv --strip-components=1 && \
    rm riscv32-unknown-elf.gcc-13.2.0.tar.gz

# Set environment variables
ENV RISCV=/opt/riscv
ENV PATH="${RISCV}/bin:${PATH}"
ENV EDITOR=nvim
ENV VISUAL=nvim

# Create project directory structure
RUN mkdir -p /workspace/rtl \
             /workspace/tb \
             /workspace/sim \
             /workspace/sw \
             /workspace/docs

# ============================
# Configure LazyVim
# ============================
# Create Neovim configuration directory
RUN mkdir -p /root/.config/nvim

# Copy LazyVim configuration
COPY nvim/ /root/.config/nvim/

# Copy entrypoint script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set working directory
WORKDIR /workspace

# Default command
CMD ["/bin/bash"]

FROM debian:stable-slim AS builder

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    curl \
    xz-utils \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*


RUN curl -L https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-arm64.tar.gz | tar -xz -C /usr/local/ --strip-components=1


FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    git \
    iproute2 \
    iptables \
    ca-certificates && \
    rm -rf /var/lib/apt/lists/*

COPY --from=builder /usr/local/bin/nvim /usr/local/bin/
COPY --from=builder /usr/local/lib/nvim /usr/local/lib/nvim
COPY --from=builder /usr/local/share/nvim /usr/local/share/nvim

COPY nvim /home/neovim_user/.config/nvim

WORKDIR /home/neovim_user
RUN useradd --create-home --shell /bin/bash neovim_user
USER neovim_user

CMD ["nvim", "--headless", "-u", "NONE", "-S", "/home/neovim_user/.config/nvim/lua/vault.lua", "+ServeVault"]

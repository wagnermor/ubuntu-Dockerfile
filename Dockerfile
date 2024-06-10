FROM ubuntu

# Instala pacotes necessários
RUN apt-get update \
    && apt-get install -y \
    zsh \
    git \
    curl \
    wget \
    gnupg \
    lsb-release \
    sudo \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala o oh-my-zsh e configura o tema Powerlevel10k
RUN sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
    && git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k \
    && sed -i 's/^ZSH_THEME=.*/ZSH_THEME="powerlevel10k\/powerlevel10k"/' ~/.zshrc \
    && echo "POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(context dir vcs)" >> ~/.p10k.zsh \
    && echo "POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)" >> ~/.p10k.zsh

# Instala o asdf
RUN git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.8.0 \
    && echo ". $HOME/.asdf/asdf.sh" >> ~/.zshrc \
    && echo ". $HOME/.asdf/completions/asdf.bash" >> ~/.zshrc

# Instala o MySQL
RUN apt-get update \
    && apt-get install -y mysql-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Instala o Visual Studio Code
RUN curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg \
    && install -o root -g root -m 644 microsoft.gpg /usr/share/keyrings/microsoft-archive-keyring.gpg \
    && sh -c 'echo "deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list' \
    && apt-get update \
    && apt-get install -y code \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Configura o path para o WSL
RUN echo "export PATH=$PATH:/mnt/c/Windows/System32" >> ~/.zshrc

# Configura o usuário e o diretório de trabalho
WORKDIR /root
USER root

## New code to added nnew user Default
# Add new user
RUN useradd -m -s /bin/bash mor && \
    echo 'mor:MyPassWord' | chpasswd && \
    usermod -aG sudo mor

# Add sudo permission
RUN echo 'mor ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers

# Set work directory
WORKDIR /home/mor
USER mor

# Copy local directory to container work directory

COPY . /home/mor

# Set apropertie ppermissions to new user
RUN sudo chown -R mor:mor /home/mor

# Default command when start container
CMD [ "zsh" ]

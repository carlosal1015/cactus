FROM archlinux:base-devel

RUN --mount=type=tmpfs,target=/var/cache/pacman \
  ln -s /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && \
  sed -i 's/^#Color/Color/' /etc/pacman.conf && \
  sed -i '/#CheckSpace/a ILoveCandy' /etc/pacman.conf && \
  sed -i 's/^ParallelDownloads = 5/ParallelDownloads = 30/' /etc/pacman.conf && \
  printf '\n[multilib]\nInclude = /etc/pacman.d/mirrorlist\n' >> /etc/pacman.conf && \
  sed -i 's/^#MAKEFLAGS="-j2"/MAKEFLAGS="-j$(nproc)"/' /etc/makepkg.conf && \
  sed -i 's/^#BUILDDIR/BUILDDIR/' /etc/makepkg.conf && \
  sed -i 's/^#PACKAGER=\"John Doe <john@doe.com/PACKAGER=\"Auto update bot <auto-update-bot@jingbei.li/' /etc/makepkg.conf && \
  sed -i 's/^#GPGKEY=\"/GPGKEY=\"5BC6FBBAB02C73E4724B2CFC8C43C00BA8F06ECA/' /etc/makepkg.conf && \
  sed -i 's/purge debug lto/purge !debug !lto/' /etc/makepkg.conf && \
  sed -i 's/man,//g' /etc/makepkg.conf && \
  sed -i 's/doc,//g' /etc/makepkg.conf && \
  useradd -l -u 33333 -md /home/gitpod -s /bin/bash gitpod && \
  passwd -d gitpod && \
  echo 'gitpod ALL=(ALL) ALL' > /etc/sudoers.d/gitpod && \
  sed -i "s/PS1='\[\\\u\@\\\h \\\W\]\\\\\\$ '//g" /home/gitpod/.bashrc && \
  { echo && echo "PS1='\[\e]0;\u \w\a\]\[\033[01;32m\]\u\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \\\$ '" ; } >> /home/gitpod/.bashrc

USER gitpod

ARG PACKAGES="\
  act \
  devtools \
  dbus \
  docker \
  git \
  github-cli \
  jq \
  libnotify \
  nvchecker \
  openssh \
  pacman-contrib \
  pyalpm \
  python-awesomeversion \
  python-django \
  python-gobject \
  python-mysqlclient \
  python-lxml \
  python-packaging \
  python-requests \
  python-setuptools \
  python-toposort \
  python-tornado \
  python-yaml \
  python-toml \
  yq \
  zsh \
  "

RUN curl -s https://gitlab.com/dune-archiso/dune-archiso.gitlab.io/-/raw/main/templates/add_arch4edu.sh | bash && \
  sudo pacman --needed --noconfirm --noprogressbar -Syuq >/dev/null 2>&1 && \
  sudo pacman --needed --noconfirm --noprogressbar -S ${PACKAGES} && \
  sudo mkdir -p /etc/docker && \
  sudo systemctl enable docker.socket && \
  sudo usermod -a -G docker gitpod && \
  sudo pacman -Scc <<< Y <<< Y && \
  sudo rm -r /var/lib/pacman/sync/* && \
  printf 'Y\n' | bash -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" --unattended && \
  cat <<EOF | sudo tee -a /etc/docker/daemon.json
{
  "ipv6": true,
  "fixed-cidr-v6": "fd00::/80"
}
EOF

ENV SHELL=/usr/bin/zsh

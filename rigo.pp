# Terrible hack for GHC: sudo ln -s libncursesw.so libtinfo.so.5

node default {
  service { "systemd-networkd":
    provider => systemd,
    ensure => running,
    enable => true,
  }

  package { "cronie": ensure => installed }
  service { "cronie.service":
    provider => systemd,
    ensure => running,
    enable => true,
  }

  file_line { 'bash_PS1':
    path => '/etc/profile',
    line => 'export PS1="[\u@\h \w]\\$ \[$(tput sgr0)\]"',
    match => '^export PS1=',
  }

  file { '/etc/ld.so.conf.d/local.conf':
    ensure => 'present',
    content => "/usr/local/lib\n",
    mode => '0644',
  }

  user { 'ron':
    ensure => 'present',
    home => '/home/ron',
    password => '!!',
    password_max_age => '99999',
    password_min_age => '0',
    shell => '/bin/bash',
    uid  => '501',
    managehome => 'true',
  }

  class { "ssh":
    server_options => {
      'PasswordAuthentication' => 'yes',
      'Port' => 2937,
      'X11Forwarding' => 'no',
      'AllowTcpForwarding' => 'no',
      'Match User ron' => {
        'X11Forwarding' => 'yes',
      	'AllowTcpForwarding' => 'yes',
      },
    }
  }

  package { "sudo": ensure => installed }

  package { "xorg-xclock": ensure => installed }

  package { "sox": ensure => installed }

  package { "unzip": ensure => installed }
  package { "zip": ensure => installed }
  package { "unrar": ensure => installed }

  package {
    "tmux": ensure => installed
  } ->
  file { '/etc/tmux.conf':
    ensure => present,
    mode => '0644',
  } ->
  file_line { 'tmux-vikeys':
    path => '/etc/tmux.conf',
    line => 'setw -g mode-keys vi',
  } ->
  file_line { 'tmux-fastescape':
    path => '/etc/tmux.conf',
    line => 'set -s escape-time 0',
  } ->
  file_line { 'tmux-colors':
    path => '/etc/tmux.conf',
    line => 'set -g default-terminal "screen-256color"',
  }

  package { "mc": ensure => installed }
  package { "links": ensure => installed }
  package { "htop": ensure => installed }
  package { "net-tools": ensure => installed }

  package { "rsync": ensure => installed }
  package { "lftp": ensure => installed }
  package { "wget": ensure => installed }
  package { "curl": ensure => installed }
  package { "smartmontools": ensure => installed }
  package { "hdparm": ensure => installed }
  package { "gptfdisk": ensure => installed }
  package { "tree": ensure => installed }
  package { "time": ensure => installed }

  package { "tcpdump": ensure => installed }
  package { "wireshark-cli": ensure => installed }
  package { "gnu-netcat": ensure => installed }
  package { "mtr": ensure => installed }

  package { "nginx": ensure => installed }

  package { "base-devel": ensure => installed }
  package { "zlib": ensure => installed }
  package { "jdk8-openjdk": ensure => installed }
  package { "swig": ensure => installed }
  package { "python2": ensure => installed }
  package { "stack": ensure => installed }
  package { "docker": ensure => installed }
  package { "git": ensure => installed }

  package { "ctags": ensure => installed }
  package { "hasktags": ensure => installed }

  package { "vim": ensure => installed }
  package { "vim-bufexplorer": ensure => installed }
  package { "vim-tagbar": ensure => installed }

  package { "adobe-source-code-pro-fonts": ensure => installed }

  package { "scrot": ensure => installed }
  package { "imagemagick": ensure => installed }
  package { "gimp": ensure => installed }
  package { "inkscape": ensure => installed }

  package { "emacs": ensure => installed }

  # Add dep on user and git?
  vcsrepo { '/home/ron/.emacs.d':
    ensure   => present,
    provider => git,
    source   => 'https://github.com/syl20bnr/spacemacs',
    revision => 'v0.105.18',
    user     => 'ron',
  }

  file { '/home/ron/.Xresources':
    ensure => present,
    mode => '0644',
    owner => 'ron',
  } ->
  file_line { 'ron_xresources_xterm_colors':
    path => '/home/ron/.Xresources',
    line => 'XTerm*termName: xterm-256color',
  } ->
  file_line { 'ron_xresources_xterm_inverted':
    path => '/home/ron/.Xresources',
    line => 'XTerm*reverseVideo: on',
  }

  exec { 'retrieve_bazel_installer':
    command => '/usr/bin/wget -q https://github.com/bazelbuild/bazel/releases/download/0.2.2/bazel-0.2.2-installer-linux-x86_64.sh -O /opt/bazel-installer.sh',
    creates => '/opt/bazel-installer.sh',
    require => Package['wget'],
  } ->
  file { '/opt/bazel-installer.sh':
    mode => '0755',
  } ->
  exec { 'install_bazel':
    command => '/opt/bazel-installer.sh',
    creates => [
      '/usr/local/bin/bazel',
      '/usr/local/lib/bazel/bin/bazel-complete.bash',
    ],
    require => Package['jdk8-openjdk'],
  } ->
  file_line { 'bash_bazel_autocomp':
    path => '/etc/bash.bashrc',
    line => 'source /usr/local/lib/bazel/bin/bazel-complete.bash',
  }

}

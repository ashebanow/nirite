#!/bin/bash

set -ouex pipefail

RELEASE="$(rpm -E %fedora)"

#######################################################################
# Setup Repositories
#######################################################################

# NOTE: RPMFusion repos are available by default
# NOTE: chrome .repo file is installed in the Containerfile prior
# to running this script.

dnf5 -y copr enable yalter/niri
dnf5 -y copr enable lihaohong/chezmoi
dnf5 -y copr enable ulysg/xwayland-satellite
# dnf5 -y copr enable solopasha/hyprland
# dnf5 -y copr enable tofik/sway
# dnf5 -y copr enable pgdev/ghostty
# dnf5 -y copr enable heus-sueh/packages                    # for matugen/swww

#######################################################################
## Install Packages
#######################################################################

# NOTE: ***ALL*** the nerd fonts in che/nerdfonts COPR are preinstalled.
# (I think, see https://github.com/ublue-os/bazzite/blob/main/Containerfile#L249)
#
# These non-nerd fonts are also preinstalled:
#
# * google-noto-sans-cjk-fonts
# * fira-code-fonts
FONTS=(
  adobe-source-code-pro-fonts
  fontawesome-fonts-all
  google-noto-color-emoji-fonts
  google-noto-emoji-fonts
  google-droid-sans-fonts
  jetbrains-mono-fonts
)

# other apps that are needed to make Niri's bluetooth, audio,
# clipboard, wallpapers, and similar apps work.
# TODO: strip this down even more
NIRI_DEPS=(
  blueman
  bluez-tools
  cava
  cliphist
  mpv
  network-manager-applet
  pamixer
  pavucontrol
  playerctl
  qt5ct
  qt6ct
  wlogout

  # screenshot/wallpaper tools
  grim
  matugen
  slurp
  swappy
  tumbler
  swww

  # Preincluded in bazzite-dx base image:
  #
  # bluez
  # btop
  # gnome-bluetooth
  # gnome-keyring
  # gvfs
  # upower
  # wallust
  # wireplumber
  # wl-clipboard
  # wlr-randr
  # xdg-desktop-portal-gnome
  # xdg-desktop-portal-gtk
)

# Niri and its dependencies from its default config
NIRI_PKGS=(
    niri
    alacritty
    brightnessctl
    fuzzel
    mako
    swaylock
    waybar
    xwayland-satellite
    # bazzite hs these preinstalled:
    #
    # gnome-keyring
    # wireplumber
    # xdg-desktop-portal-gnome
    # xdg-desktop-portal-gtk
)

# chrome etc are installed as flatpaks. We generally prefer that
# for most things with GUIs, and homebrew for CLI apps. This list is
# only special GUI apps that need to be installed at the system level.
ADDITIONAL_SYSTEM_APPS=(
  chezmoi

  firefox

  # ghostty is broken in Fedora 42 right now
  # ghostty

  kitty
  kitty-terminfo

  nodejs

  thunar
  thunar-volman
  thunar-archive-plugin

  xarchiver
)

# we do all package installs in one rpm-ostree command
# so that we create minimal layers in the final image
dnf5 install -y \
  ${FONTS[@]} \
  ${NIRI_DEPS[@]} \
  ${NIRI_PKGS[@]} \
  ${ADDITIONAL_SYSTEM_APPS[@]}

#######################################################################
### Disable repositeories so they aren't cluttering up the final image

dnf5 -y copr disable yalter/niri
dnf5 -y copr disable lihaohong/chezmoi
dnf5 -y copr disable ulysg/xwayland-satellite
# dnf5 -y copr disable solopasha/hyprland
# dnf5 -y copr disable erikreider/SwayNotificationCenter
# dnf5 -y copr disable tofik/sway
# dnf5 -y copr disable pgdev/ghostty
# dnf5 -y copr disable heus-sueh/packages

#######################################################################
### Enable Services

# TODO: these need to be run at first boot, not during image build

# Setting Thunar as the default file manager
# xdg-mime default thunar.desktop inode/directory
# xdg-mime default thunar.desktop application/x-wayland-gnome-saved-search

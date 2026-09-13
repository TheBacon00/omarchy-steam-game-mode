# Maintainer: Garet Wirth
pkgname=omarchy-steam-game-mode-git
_gitdir=omarchy-steam-game-mode
pkgver=r1.0000000
pkgrel=1
pkgdesc="SteamOS-style Gamescope/Big Picture session toggle for Omarchy, with adaptive sync (VRR) kept forced on against Steam's own gamepadui resetting it"
arch=('any')
url="https://github.com/TheBacon00/omarchy-steam-game-mode"
license=('MIT')
depends=('omarchy' 'gamescope' 'steam' 'sddm' 'sxhkd' 'jq' 'gum' 'python3' 'sudo')
optdepends=('mangohud: performance overlay inside Game Mode'
            'libdrm: modetest-based refresh-rate detection (falls back to a sysfs+EDID read if absent)')
makedepends=('git')
install=omarchy-steam-game-mode.install
source=("${_gitdir}::git+${url}.git")
md5sums=('SKIP')

pkgver() {
    cd "$srcdir/${_gitdir}"
    printf "r%s.%s" "$(git rev-list --count HEAD)" "$(git rev-parse --short HEAD)"
}

package() {
    cd "$srcdir/${_gitdir}"
    cp -rv usr "$pkgdir/usr"
    install -Dm440 etc/sudoers.d/omarchy-steam-game-mode "$pkgdir/etc/sudoers.d/omarchy-steam-game-mode"
    install -Dm644 LICENSE "$pkgdir/usr/share/licenses/${pkgname}/LICENSE"
}

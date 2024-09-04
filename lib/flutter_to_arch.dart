String generateDesktopFile(String version, String name, String pkgName, String description, String categories, String keywords) {
  return '''
[Desktop Entry]
Version=$version
Name=$name
GenericName=$name
Comment=$description
Terminal=false
Type=Application
Categories=$categories
Exec=/usr/bin/${pkgName}_pkg/$pkgName
Keywords=$keywords
Icon=/usr/share/icons/hicolor/64x64/apps/$pkgName.png
'''.trim();
}

String generatePkgBuild(String pkgName, String description, String version, String buildNumber, String url, String depends) {
  return '''
pkgname=$pkgName
pkgver=$version
pkgrel=$buildNumber
pkgdesc="$description"
arch=('x86_64')
source=("app.tar.gz")
md5sums=('SKIP')
url="$url"
depends=($depends)

package() {
    cd "\$srcdir"
    install -Dm755 app/pica_comic "\$pkgdir/usr/bin/${pkgName}_pkg/pica_comic"
    install -d "\$pkgdir/usr/bin/${pkgName}_pkg/lib"
    cp -r app/lib/* "\$pkgdir/usr/bin/${pkgName}_pkg/lib/"
    install -d "\$pkgdir/usr/bin/${pkgName}_pkg/data"
    cp -r app/data/* "\$pkgdir/usr/bin/${pkgName}_pkg/data/"
    install -Dm644 app/icon.png "\$pkgdir/usr/share/icons/hicolor/64x64/apps/$pkgName.png"
    install -Dm644 app/app.desktop "\$pkgdir/usr/share/applications/\$pkgname.desktop"
    ln -s "\$pkgdir/usr/bin/${pkgName}_pkg/$pkgName" "\$pkgdir/usr/bin/$pkgName"
}
'''.trim();
}

String generateDockerFile() {
  return '''
FROM archlinux:latest

RUN pacman -Syu --noconfirm base-devel

WORKDIR /build

COPY PKGBUILD ./

COPY app.tar.gz ./

RUN makepkg -si --noconfirm
'''.trim();
}
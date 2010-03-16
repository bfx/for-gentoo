# Copyright 2004-2009 Sabayon Linux
# Distributed under the terms of the GNU General Public License v2

EAPI="2"
inherit eutils python

DESCRIPTION="Official Sabayon Linux Entropy Notification Applet (GTK version)"
HOMEPAGE="http://www.sabayon.org"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""
SRC_URI="http://distfiles.sabayonlinux.org/sys-apps/entropy-${PV}.tar.bz2"
RESTRICT="mirror"
S="${WORKDIR}/entropy-${PV}"

DEPEND="~app-misc/magneto-loader-${PV}
        dev-python/notify-python
	dev-python/pygtk
"
RDEPEND="${DEPEND}"

src_compile() {
	emake -j1 || die "make failed"
}

src_install() {
	emake DESTDIR="${D}" LIBDIR="usr/$(get_libdir)" magneto-gtk-install || die "make install failed"
}

pkg_postinst() {
	python_mod_compile "/usr/$(get_libdir)/entropy/magneto/magneto/gtk"
}

pkg_postrm() {
        python_mod_cleanup "/usr/$(get_libdir)/entropy/magneto/magneto/gtk"
}

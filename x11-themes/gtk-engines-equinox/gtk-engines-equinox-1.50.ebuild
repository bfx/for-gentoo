# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

MY_PN="equinox"
ODTAG="121881"
FILE="${ODTAG}-${MY_PN}-${PV}"

DESCRIPTION="Sleek GTK Theme engine"
HOMEPAGE="http://gnome-look.org/content/show.php?content=121881"
SRC_URI="http://gnome-look.org/CONTENT/content-files/${FILE}.tar.gz"

LICENSE="GPL"
SLOT="0"
KEYWORDS="~amd64 ~x86"
IUSE=""

DEPEND=""
RDEPEND="${DEPEND}"

S="${WORKDIR}/${MY_PN}-${PV}"

src_configure () {
	ls
	pwd
	econf --enable-animation
}
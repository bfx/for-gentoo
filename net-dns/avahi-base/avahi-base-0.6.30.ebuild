# Copyright 1999-2011 Sabayon
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="3"

PYTHON_DEPEND="python? 2"
PYTHON_USE_WITH="gdbm"
PYTHON_USE_WITH_OPT="python"

DBUS_DEPEND=">=sys-apps/dbus-0.30"
IUSE="autoipd bookmarks dbus doc gdbm howl-compat introspection ipv6
	mdnsresponder-compat python test"
COMMON_DEPEND=">=dev-libs/libdaemon-0.14
	dev-libs/expat
	dev-libs/glib:2
	gdbm? ( sys-libs/gdbm )
	dbus? (
			${DBUS_DEPEND}
			python? ( dev-python/dbus-python )
	)
	howl-compat? ( ${DBUS_DEPEND} )
	introspection? ( >=dev-libs/gobject-introspection-0.9.5 )
	mdnsresponder-compat? ( ${DBUS_DEPEND} )
	bookmarks? (
			dev-python/twisted
			dev-python/twisted-web
	)
	kernel_linux? ( sys-libs/libcap )
	"
AVAHI_MODULE_DEPEND="${COMMON_DEPEND}
	doc? ( app-doc/doxygen )"
AVAHI_MODULE_RDEPEND="${COMMON_DEPEND}
	howl-compat? ( !net-misc/howl )
	mdnsresponder-compat? ( !net-misc/mDNSResponder )"

inherit eutils multilib python avahi

pkg_setup() {
	if use python; then
		python_set_active_version 2
		python_pkg_setup
	fi
}

pkg_preinst() {
	enewgroup netdev
	enewgroup avahi
	enewuser avahi -1 -1 -1 avahi

	if use autoipd; then
		enewgroup avahi-autoipd
		enewuser avahi-autoipd -1 -1 -1 avahi-autoipd
	fi
}

src_prepare() {
	if use ipv6; then
		sed -i \
			-e s/use-ipv6=no/use-ipv6=yes/ \
			avahi-daemon/avahi-daemon.conf || die
	fi
}

src_configure() {
	local myconf=""
	if use python; then
		myconf+=" $(use_enable dbus python-dbus)"
	fi

	# these require dbus enabled
	if use mdnsresponder-compat || use howl-compat; then
		myconf+=" --enable-dbus"
	fi

	myconf+="
		$(use_enable test tests)
		$(use_enable autoipd)
		$(use_enable mdnsresponder-compat compat-libdns_sd)
		$(use_enable howl-compat compat-howl)
		$(use_enable doc doxygen-doc)
		$(use_enable dbus)
		$(use_enable python)
		$(use_enable introspection)
		$(use_enable gdbm)
		--disable-qt4
		--disable-gtk
		--disable-gtk3
		--disable-pygtk
		--disable-mono"
	if use python; then
		myconf+=" $(use_enable dbus python-dbus)"
	else
		myconf+=" --disable-python-dbus"
	fi
	avahi_src_configure "${myconf}"
}

src_compile() {
	emake || die "emake failed"
	use doc && { emake avahi.devhelp || die ; }
}

src_install() {
	emake install py_compile=true DESTDIR="${D}" || die "make install failed"
	use bookmarks || rm -f "${D}"/usr/bin/avahi-bookmarks

	use howl-compat && ln -s avahi-compat-howl.pc "${D}"/usr/$(get_libdir)/pkgconfig/howl.pc
	use mdnsresponder-compat && ln -s avahi-compat-libdns_sd/dns_sd.h "${D}"/usr/include/dns_sd.h

	if use autoipd; then
		insinto /$(get_libdir)/rcscripts/net
		doins "${FILESDIR}"/autoipd.sh || die

		insinto /$(get_libdir)/rc/net
		newins "${FILESDIR}"/autoipd-openrc.sh autoipd.sh || die
	fi

	dodoc docs/{AUTHORS,NEWS,README,TODO} || die

	if use doc; then
		dohtml -r doxygen/html/. || die
		insinto /usr/share/devhelp/books/avahi
		doins avahi.devhelp || die
	fi

	echo
	elog "If you changed USE flags or did a version/revision bump, make sure"
	elog "to rebuild all the modules:"
	for mod in ${SUPPORTED_AVAHI_MODULES}; do
		elog "  net-dns/avahi-${mod}"
	done
	echo

	avahi_src_install-cleanup
}

pkg_postrm() {
	use python && python_mod_cleanup avahi
}

pkg_postinst() {
	use python && python_mod_optimize avahi

	if use autoipd; then
		echo
		elog "To use avahi-autoipd to configure your interfaces with IPv4LL (RFC3927)"
		elog "addresses, just set config_<interface>=( autoipd ) in /etc/conf.d/net!"
	fi

	if use dbus; then
		echo
		elog "If this is your first install of avahi please reload your dbus config"
		elog "with /etc/init.d/dbus reload before starting avahi-daemon!"
	fi
}
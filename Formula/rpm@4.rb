class RpmAT4 < Formula
  desc "RPM package manager"
  homepage "http://rpm.org/"
  url "http://ftp.rpm.org/releases/testing/rpm-4.14.0-rc1.tar.bz2"
  sha256 "db9a4c9c0c6d927ed7e451b23297aa06bc40341635dd0857a25d91d76d7a5736"

  head do
    url "https://github.com/rpm-software-management/rpm.git"

    depends_on "autoconf" => :build
    depends_on "automake" => :build
    depends_on "libtool" => :build
  end

  depends_on "berkeley-db"
  depends_on "gettext"
  depends_on "libarchive"
  depends_on "nspr"
  depends_on "nss"

  def install
    system "autoreconf", "-f", "-i" if build.head?

    ENV.append "CPPFLAGS", "-I#{Formula["nspr"].opt_include}/nspr"
    ENV.append "CPPFLAGS", "-I#{Formula["nss"].opt_include}/nss"

    args = %W[
      --prefix=#{prefix}
      --localstatedir=#{var}
      --sysconfdir=#{etc}
      --disable-dependency-tracking
      --with-external-db
      --without-lua
    ]

    inreplace %w[
      doc/fr/rpm.8
      doc/ja/rpm.8
      doc/ja/rpmbuild.8
      doc/ko/rpm.8
      doc/pl/rpm.8
      doc/pl/rpmbuild.8
      doc/rpm.8
      doc/rpmbuild.8
      doc/ru/rpm.8
      doc/sk/rpm.8
    ] do |s|
      s.gsub! "/usr/lib/rpm", HOMEBREW_PREFIX/"lib/rpm"
      s.gsub! "/etc/rpm", etc/"rpm"
      s.gsub! "/var/lib/rpm", var/"rpm"
    end

    inreplace %w[
      scripts/check-rpaths
      scripts/check-rpaths-worker
      scripts/find-provides
      scripts/find-requires
      scripts/rpmdb_loadcvt
      scripts/vpkg-provides.sh
    ] do |s|
      s.gsub! "/usr/lib/rpm", lib/"rpm"
    end

    system "./configure", *args
    system "make", "install"
  end

  def test_spec
    <<-EOS.undent
      Summary:   Test package
      Name:      test
      Version:   1.0
      Release:   1
      License:   Public Domain
      Group:     Development/Tools
      BuildArch: noarch

      %description
      Trivial test package

      %prep
      %build
      %install
      mkdir -p $RPM_BUILD_ROOT/tmp
      touch $RPM_BUILD_ROOT/tmp/test

      %files
      /tmp/test

      %changelog

    EOS
  end

  def rpmdir(macro)
    Pathname.new(`#{bin}/rpm --eval #{macro}`.chomp)
  end

  test do
    (testpath/"rpmbuild").mkpath
    (testpath/".rpmmacros").write <<-EOS.undent
      %_topdir		#{testpath}/rpmbuild
      %_tmppath		%{_topdir}/tmp
    EOS

    system "#{bin}/rpm", "-vv", "-qa", "--dbpath=#{testpath}"
    rpmdir("%_builddir").mkpath
    specfile = rpmdir("%_specdir")+"test.spec"
    specfile.write(test_spec)
    system "#{bin}/rpmbuild", "-ba", specfile
    assert File.exist?(rpmdir("%_srcrpmdir")/"test-1.0-1.src.rpm")
    assert File.exist?(rpmdir("%_rpmdir")/"noarch/test-1.0-1.noarch.rpm")
    system "#{bin}/rpm", "-qpi", rpmdir("%_rpmdir")/"noarch/test-1.0-1.noarch.rpm"
  end
end

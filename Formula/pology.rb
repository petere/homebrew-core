class Pology < Formula
  homepage "http://pology.nedohodnik.net/"
  head "svn://anonsvn.kde.org/home/kde/trunk/l10n-support/pology"

  depends_on "cmake" => :build
  depends_on "gettext"

  def install
    system "cmake", ".", *std_cmake_args
    system "make", "install"
  end
end

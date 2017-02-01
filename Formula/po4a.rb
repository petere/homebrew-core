class Po4a < Formula
  homepage "http://po4a.alioth.debian.org/"
  url "https://alioth.debian.org/frs/download.php/file/4176/po4a-0.48.tar.gz"
  sha256 "a89595ca42e896c97ce4ffc231a075cc88692216b4bc05df40414d7428c4286c"

  head do
    url "https://alioth.debian.org/anonscm/git/po4a/po4a.git"
  end

  depends_on "gettext" => :build

  resource "Locale::Gettext" do
    url "http://search.cpan.org/CPAN/authors/id/P/PV/PVANDRY/gettext-1.05.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/P/PV/PVANDRY/gettext-1.05.tar.gz"
    sha256 "27367f3dc1be79c9ed178732756e37e4cfce45f9e2a27ebf26e1f40d80124694"
  end

  #resource "SGMLS" do
  #  url "http://search.cpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
  #  mirror "http://search.mcpan.org/CPAN/authors/id/R/RA/RAAB/SGMLSpm-1.1.tar.gz"
  #  sha256 "31d4199d71d5d809f5847bac594c03348c82e2e2"
  #end

  resource "Text::WrapI18N" do
    url "http://search.cpan.org/CPAN/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/K/KU/KUBOTA/Text-WrapI18N-0.06.tar.gz"
    sha256 "4bd29a17f0c2c792d12c1005b3c276f2ab0fae39c00859ae1741d7941846a488"
  end

  resource "Unicode::GCString" do
    url "http://search.cpan.org/CPAN/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2014.06.tar.gz"
    mirror "http://search.mcpan.org/CPAN/authors/id/N/NE/NEZUMI/Unicode-LineBreak-2014.06.tar.gz"
    sha256 "5c06dfb5036bbcc1043b366df48fd3a993a6cfaa1c2c5b4efd2b0d87fec54f8d"
  end

  def install
    ENV.prepend_create_path "PERL5LIB", libexec+"lib/perl5"
    #ENV.prepend_create_path "PERLLIB", '/usr/local/lib/perl5'  # for SGMLS

    resources.each do |r|
      r.stage do
        system "perl", "Makefile.PL", "INSTALL_BASE=#{libexec}"
        system "make", "install"
      end
    end

    %w[po4a po4a-gettextize po4a-normalize po4a-translate po4a-updatepo].each do |f|
      chmod 0644, f  # FIXME
      inreplace f, "use warnings", "use warnings;\nuse lib '#{lib}/perl5/site_perl';"
    end
    system "perl", "Build.PL", "--prefix", prefix
    system "./Build"
    system "./Build", "install"

    bin.env_script_all_files(libexec+"bin", "PERL5LIB" => ENV["PERL5LIB"])
  end

  test do
    system bin/"po4a", "--version"
    system bin/"po4a-build", "--version"
    system bin/"po4a-gettextize", "--version"
    system bin/"po4a-normalize", "--version"
    system bin/"po4a-translate", "--version"
    system bin/"po4a-updatepo", "--version"
    system bin/"po4aman-display-po", "-h"
    system bin/"po4apod-display-po", "-h"
  end
end

class Rmblast < Formula
  desc "RepeatMasker compatible version of the standard NCBI BLAST suite"
  homepage "https://www.repeatmasker.org/RMBlast.html"
  url "https://ftp.ncbi.nlm.nih.gov/blast/executables/blast+/2.11.0/ncbi-blast-2.11.0+-src.tar.gz"
  version "2.11.0"
  sha256 "d88e1858ae7ce553545a795a2120e657a799a6d334f2a07ef0330cc3e74e1954"

  bottle do
    root_url "https://ghcr.io/v2/brewsci/bio"
    sha256 cellar: :any_skip_relocation, sierra:       "bd7e6df63714fb2cc07ea1bc5dc3fcfb23364d8f86a66fd6bf8af333d8a18dc1"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "e4179700df3ad81604cb6031a9d82e971d3fa88ac0c9b6d8f949af3b8be3edb8"
  end

  keg_only "rmblast conflicts with blast"

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  uses_from_macos "bzip2"
  uses_from_macos "sqlite"
  uses_from_macos "zlib"

  patch do
    url "https://www.repeatmasker.org/isb-2.11.0+-rmblast.patch.gz"
    sha256 "0fc27781c2ea2f17645247e2f3775b5d18c56f0b62761a865347be745ea4f6be"
  end

  def install
    cd "c++" do
      cd "src/build-system" do
        # Hack to fix weird nested autoconf scripts
        mkdir "src/build-system"
        system "autoreconf", "-fvi"
        mv "src/build-system/config.h.in", "."
      end
      args = std_configure_args - %w[--disable-debug --disable-dependency-tracking]
      args += %w[--without-debug --with-mt --without-krb5 --without-openssl
                 --with-projects=scripts/projects/rmblastn/project.lst]
      system "./configure", *args
      system "make"
      system "make", "install"
    end
  end

  test do
    assert_match "USAGE", shell_output("#{bin}/rmblastn -help")
  end
end

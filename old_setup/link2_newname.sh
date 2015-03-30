srcdir=$1
dstdir=$2

mkdir -p $dstdir
srctable=${srcdir##*/}
dsttable=${dstdir##*/}

srckeyspacepath=${srcdir%/*}
dstkeyspacepath=${dstdir%/*}

srckeyspace=${srckeyspacepath##*/}
dstkeyspace=${dstkeyspacepath##*/}

srcroot=${srckeyspacepath%/*}
dstroot=${dstkeyspacepath%/*}

for file in $srcdir/$srckeyspace-$srctable-*; do echo $file;  echo $file | sed 's#\(.*/\)\([^-]*-[^-]*\)\(.*\)#sudo ln \1\2\3 '$dstdir'/'$dstkeyspace'-'$dsttable'\3#' | bash   ; done


# No taps needed.
#
# homebrew/cask-fonts was archived upstream in 2024 and its casks were folded
# into homebrew/cask under the same names, so the font-* entries below still
# resolve with no tap at all. Leaving the line in only made `brew bundle` fail
# on a tap that can no longer be tapped.
#
# modularml/packages went the same way in practice: it pins modular 0.9.3, whose
# tarball 404s at dl.modular.com. That mattered more than a dead formula usually
# does -- brew bundle fetches every bottle before installing any of them, so the
# one bad download aborted the whole run and nothing got installed. mojo is
# already on PATH from ~/.modular, put there by Modular's standalone installer
# and wired up in .zshrc:199-203, so nothing was relying on the brew copy. The
# vscode mojo extension below is independent of the tap and stays.
# C++ Common Libraries
brew "abseil"
# C/C++ resolver library and DNS resolver utilities
brew "adns"
# Audio encoder which generates ATSC A/52 compressed audio streams
brew "aften"
# Perceptual video quality assessment based on multi-method fusion
brew "libvmaf"
# Codec library for encoding and decoding AV1 video streams
brew "aom"
# Apache Portable Runtime library
brew "apr"
# Companion library to apr, the Apache Portable Runtime library
brew "apr-util"
# Library for manipulating PNG images
brew "libpng"
# Extremely Fast Compression algorithm
brew "lz4"
# General-purpose data compression with high compression ratio
brew "xz"
# Zstandard is a real-time compression algorithm
brew "zstd"
# Collection of portable C++ source libraries
brew "boost"
# Library for decimal floating point arithmetic
brew "mpdecimal"
# Library for command-line editing
brew "readline"
# Command-line interface for SQLite
brew "sqlite"
# Formatter/translator for text files to numerous formats
brew "asciidoc"
# Spell checker with better logic than ispell
brew "aspell"
# Macro processing language
brew "m4"
# Automatic configure script builder
brew "autoconf"
# Collection of over 500 reusable autoconf macros
brew "autoconf-archive"
# Tool for generating GNU Standards-compliant Makefiles
brew "automake"
# C string library for manipulating Unicode strings
brew "libunistring"
# GNU internationalization (i18n) and localization (l10n) library
brew "gettext"
# Text-based UI library
brew "ncurses"
# Bourne-Again SHell, a UNIX command interpreter
brew "bash"
# Programmable completion for Bash 3.2
brew "bash-completion"
# Parser generator
brew "bison"
# Generic-purpose lossless compression algorithm by Google
brew "brotli"
# BSD version of the Make build tool
brew "bsdmake"
# Freely available high-quality data compressor
brew "bzip2"
# Asynchronous DNS library
brew "c-ares"
# Blocking, shuffling and loss-less compression library
brew "c-blosc"
# Software library to render fonts
brew "freetype"
# XML-based font configuration API for X Windows
brew "fontconfig"
# Perl compatible regular expressions library with a new API
brew "pcre2"
# Vector graphics library with cross-device output support
brew "cairo"
# C library implementing the SSH2 protocol
brew "libssh2"
# C library of Git core methods that is re-entrant and linkable
brew "libgit2"
# Helper program to build and install c-like libraries
brew "cargo-c"
# Library and utilities for processing GIFs
brew "giflib"
# Smart font renderer for non-Roman scripts
brew "graphite2"
# OpenType text shaping engine
brew "harfbuzz"
# Library for OS-independent pseudo-TTY management
brew "libptytty"
# Readline wrapper: adds readline support to tools that lack it
brew "rlwrap"
# Dynamic, general-purpose programming language
brew "clojure"
# Cross-platform make
brew "cmake"
# YAML Parser
brew "libyaml"
# Dependency manager for Cocoa projects
brew "cocoapods"
# GNU multiple precision arithmetic library
brew "gmp"
# GNU File, Shell, and Text utilities
brew "coreutils"
# Unit testing framework for C++
brew "cppunit"
# Reimplementation of ctags(1)
brew "ctags"
# Get a file from an HTTP, HTTPS or FTP server
brew "curl"
# AV1 decoder targeted to be small and fast
brew "dav1d"
# Message bus system, providing inter-application communication
brew "dbus"
# File comparison utilities
brew "diffutils"
# DjVu viewer
brew "djvulibre"
# Binary-decimal and decimal-binary routines for IEEE doubles
brew "double-conversion"
# Generate documentation for several programming languages
brew "doxygen"
# Implementation of the Unicode BiDi algorithm
brew "fribidi"
# Library for encoding and decoding .avif files
brew "libavif"
# Image format providing lossless and lossy compression for web images
brew "webp"
# GNU database manager
brew "gdbm"
# JBIG2 decoder and library (for monochrome documents)
brew "jbig2dec"
# Library for JPEG-2000 image manipulation
brew "openjpeg"
# Image processing and image analysis library
brew "leptonica"
# Secure hashing function
brew "libb2"
# Multi-format archive and compression library
brew "libarchive"
# International domain name library
brew "libidn"
# Framework for layout and rendering of i18n text
brew "pango"
# OCR (Optical Character Recognition) engine
brew "tesseract"
# Interpreter for PostScript and PDF
brew "ghostscript"
# Open h.265 video codec implementation
brew "libde265"
# H.265/HEVC encoder
brew "x265"
# ISO/IEC 23008-12:2017 HEIF file format decoder and encoder
brew "libheif"
# Generic library support script
brew "libtool"
# Tools and libraries to manipulate images in select formats
brew "imagemagick"
# C library for reading, creating, and modifying zip archives
brew "libzip"
# C library for multiple-precision floating-point computations
brew "mpfr"
# C/C++ function library for exporting 2-D vector graphics
brew "plotutils"
# Convert bitmaps to vector graphics
brew "potrace"
# Utilities to create and convert Web Open Font File (WOFF) files
brew "woff2"
# Fast DVI to SVG converter
brew "dvisvgm"
# Text to speech, software speech synthesizer
brew "espeak"
# XML 1.0 parser
brew "expat"
# Modern, maintained replacement for ls
brew "eza"
# High quality MPEG Audio Layer III (MP3) encoder
brew "lame"
# VP8/VP9 video codec
brew "libvpx"
# AV1 encoder
brew "svt-av1"
# H.264/AVC encoder
brew "x264"
# Play, record, convert, and stream select audio and video codecs
brew "ffmpeg", link: false
# Ogg Bitstream Library
brew "libogg"
# Free lossless audio codec
brew "flac"
# LLVM's OpenMP runtime library
brew "libomp"
# International domain name library (IDNA2008, Punycode and TR46)
brew "libidn2"
# ASN.1 structure parser library
brew "libtasn1"
# Low-level cryptographic library
brew "nettle"
# Library to load and enumerate PKCS#11 modules
brew "p11-kit"
# GNU Transport Layer Security (TLS) Library
brew "gnutls"
# Library of 2D and 3D vector, matrix, and math operations
brew "imath"
# Heavily optimized DEFLATE/zlib/gzip compression and decompression
brew "libdeflate"
# Open-source implementation of JPEG2000 Part-15 (or JPH or HTJ2K)
brew "openjph"
# High dynamic-range image file format
brew "openexr"
# Subtitle renderer for the ASS/SSA subtitle format
brew "libass"
# Blu-Ray disc playback library for media players like VLC
brew "libbluray"
# Asynchronous event library
brew "libevent"
# Library for sample rate conversion of audio data
brew "libsamplerate"
# Vorbis general audio compression codec
brew "libvorbis"
# MP3 player for Linux and UNIX
brew "mpg123"
# C library for files containing sampled sound
brew "libsndfile"
# NaCl networking and cryptography library
brew "libsodium"
# C library SSHv1/SSHv2 client and server protocols
brew "libssh"
# Transcode video stabilization plugin
brew "libvidstab"
# Fastest and safest AV1 video encoder
brew "rav1e"
# Compression/decompression library aiming for high speed
brew "snappy"
# Audio codec designed for speech
brew "speex"
# High-performance, high-quality MPEG-4 video library
brew "xvid"
# Scaling, colorspace conversion, and dithering library
brew "zimg"
# Play, record, convert, and stream many audio and video codecs
brew "ffmpeg-full", link: true
# C routines to compute the Discrete Fourier Transform
brew "fftw"
# Collection of GNU find, xargs, and locate
brew "findutils"
# Fast Lexical Analyzer, generates Scanners (tokenizers)
brew "flex"
# Command-line outline and bitmap font editor/converter
brew "fontforge"
# XSL-FO print formatter for making PDF or PS documents
brew "fop"
# Infamous electronic fortune-cookie generator
brew "fortune"
# Command-line fuzzy finder written in Go
brew "fzf"
# GNU awk utility
brew "gawk"
# Integer Set Library for the polyhedral model
brew "isl"
# C library for the arithmetic of high precision complex numbers
brew "libmpc"
# GNU compiler collection
brew "gcc"
# GitHub command-line tool
brew "gh"
# Glorious Glasgow Haskell Compilation System
brew "ghc"
# Documentation tool for GObject-based libraries
brew "gi-docgen"
# Distributed revision control system
brew "git"
# Common error values for all GnuPG components
brew "libgpg-error"
# Assuan IPC Library
brew "libassuan"
# Cryptographic library based on the code from GnuPG
brew "libgcrypt"
# X.509 and CMS library
brew "libksba"
# Library for USB device access
brew "libusb"
# New GNU portable threads library
brew "npth"
# GNU Privacy Guard (OpenPGP)
brew "gnupg"
# Open source programming language to build simple/reliable/efficient software
brew "go"
# Converts markdown into roff (man pages)
brew "go-md2man"
# Package compiler and linker metadata toolkit
brew "pkgconf"
# Generate introspection data for GObject libraries
brew "gobject-introspection"
# Perfect hash function generator
brew "gperf"
# Multi-threaded malloc() and performance analysis tools
brew "gperftools"
# Library access to GnuPG
brew "gpgme"
# C++ bindings for gpgme
brew "gpgmepp"
# Library for manipulating JPEG-2000 images
brew "jasper"
# Image manipulation
brew "netpbm"
# GNU triangulated surface library
brew "gts"
# Library to render SVG files using Cairo
brew "librsvg"
# Graph visualization software from AT&T and Bell Labs
brew "graphviz"
# GNU grep, egrep and fgrep
brew "grep"
# Library for handling paper characteristics
brew "libpaper"
# Utilities for manipulating PostScript documents
brew "psutils"
# Encoding detector library
brew "uchardet"
# GNU troff text-formatting system
brew "groff"
# GSettings schemas for desktop components
brew "gsettings-desktop-schemas"
# GTK+ documentation tool
brew "gtk-doc"
# GNU Ubiquitous Intelligent Language for Extensions
brew "guile"
# C99 library for parsing HTML5
brew "gumbo-parser"
# Popular GNU data compression program
brew "gzip"
# Automatically generate simple man pages
brew "help2man"
# Improved top (interactive process viewer)
brew "htop"
# Library for reading RAW files from digital photo cameras
brew "libraw"
# Tools and libraries to manipulate images in many formats
brew "imagemagick-full"
# GNOME XML library
brew "libxml2"
# Make XML documents translatable through PO files
brew "itstool"
# Audio Connection Kit
brew "jack"
# C library for encoding, decoding, and manipulating JSON
brew "jansson"
# Implementation of malloc emphasizing fragmentation avoidance
brew "jemalloc"
# User-friendly front-end to ssh-agent(1)
brew "keychain"
# Ultravideo HEVC encoder
brew "kvazaar"
# Compare and mark up LaTeX file differences
brew "latexdiff"
# Parallel bzip2 utility
brew "lbzip2"
# Adaptive Entropy Coding implementing Golomb-Rice algorithm
brew "libaec"
# Implementations for atomic memory update operations
brew "libatomic_ops"
# CBOR protocol implementation for C and others
brew "libcbor"
# CSS parsing and manipulation toolkit for GNOME
brew "libcroco"
# BSD-style licensed readline alternative
brew "libedit"
# ELF object file access library
brew "libelf"
# Portable Foreign Function Interface library
brew "libffi"
# Provides library functionality for FIDO U2F & FIDO 2.0, including USB
brew "libfido2"
# JIT library for the GNU compiler collection
brew "libgccjit"
# Conversion library
brew "libiconv"
# Implementation of the file(1) command
brew "libmagic"
# C library to parse Metalink XML files
brew "libmetalink"
# Library from the Modplug-XMMS project
brew "libmodplug"
# Portable library for network traffic capture
brew "libpcap"
# Library that provides automatic proxy configuration management
brew "libproxy"
# C library for the Public Suffix List
brew "libpsl"
# Library to Access SMI MIB Information
brew "libsmi"
# C API for determining the call-chain of a program
brew "libunwind-headers"
# Library for USB device access
brew "libusb-compat"
# Multi-platform support library with a focus on asynchronous I/O
brew "libuv"
# C XSLT library for GNOME
brew "libxslt"
# Library providing read access on ZIP-archives
brew "libzzip"
# Lynx-like WWW browser that supports tables, menus, etc.
brew "links"
# Next-gen compiler infrastructure
brew "llvm"
# Lightning memory-mapped database: key-value data store
brew "lmdb"
# Clone of ls with colorful output, file type icons, and more
brew "lsd"
# LZMA-based compression program similar to gzip or bzip2
brew "lzip"
# Apple Silicon Monitor Top written in Go Lang
brew "mactop"
# Utility for directing compilation
brew "make"
# UNIX manpage compiler toolset
brew "mandoc"
# Small build system for use with gyp or CMake
brew "ninja"
# Fast and user friendly build system
brew "meson"
# Feature-rich command-line audio/video downloader
brew "yt-dlp"
# Media player based on MPlayer and mplayer2
brew "mpv"
# Lightweight PDF and XPS viewer
brew "mupdf"
# Experimental optional static type checker for Python
brew "mypy"
# Netwide Assembler (NASM) is an 80x86 assembler
brew "nasm"
# Single-player roguelike video game
brew "nethack"
# HTTP/2 C Library
brew "nghttp2"
# Port scanning utility for large networks
brew "nmap"
# Open-source, cross-platform JavaScript runtime environment
brew "node"
# Platform-neutral API for system-level and libc-like functions
brew "nspr"
# Libraries for security-enabled client and server applications
brew "nss"
# Adds an OCR text layer to scanned PDF files
brew "ocrmypdf"
# Optimized BLAS library
brew "openblas"
# H.264 codec from Cisco
brew "openh264"
# Open source suite of directory software
brew "openldap"
# OpenBSD freely-licensed SSH connectivity tools
brew "openssh"
# ISO-C API and CLI for generating UUIDs
brew "ossp-uuid"
# 7-Zip (high compression file archiver) implementation
brew "p7zip"
# Swiss-army knife of markup format conversion
brew "pandoc"
# Perl compatible regular expressions library
brew "pcre"
# Pinentry for GPG on Mac
brew "pinentry-mac"
# Python dependency management tool
brew "pipenv"
# PDF rendering library (based on the xpdf-3.0 code base)
brew "poppler"
# Library like getopt(3) with a number of enhancements
brew "popt"
# Convert PostScript to EPS files
brew "ps2eps"
# Show ps output as a tree
brew "pstree"
# GNU Portable THreads
brew "pth"
# Implementation of Python 3 in Python
brew "pypy3.10"
# Computes convex hulls in n dimensions
brew "qhull"
# Rsync for cloud storage
brew "rclone"
# Alternative to backtracking PCRE-style regular expression engines
brew "re2"
# Generate C-based recognizers from regular expressions
brew "re2c"
# Convert character set (charsets)
brew "recode"
# Perl-powered file rename script with many helpful built-ins
brew "rename"
# Search tool like grep and The Silver Searcher
brew "ripgrep"
# Utility that provides fast incremental file transfer
brew "rsync"
# Safe, concurrent, practical language
brew "rust"
# Steel Bank Common Lisp system
brew "sbcl"
# Database of common MIME types
brew "shared-mime-info"
# Speex audio processing library
brew "speexdsp"
# Add a public key to a remote machine's authorized_keys file
brew "ssh-copy-id"
# Generate scripting interfaces to C/C++ code
brew "swig"
# C library to generate/rasterize bitmaps from Type 1 fonts
brew "t1lib"
# Command-line tools for dealing with Type 1 fonts
brew "t1utils"
# Official documentation format of the GNU project
brew "texinfo"
# Simplified and community-driven man pages
brew "tldr"
# Terminal multiplexer
brew "tmux"
# Incremental parsing library
brew "tree-sitter"
# Parser generator tool
brew "tree-sitter-cli"
# Language for application scale JavaScript development
brew "typescript"
# Collection of Linux utilities
brew "util-linux"
# Extremely fast Python package installer and resolver, written in Rust
brew "uv"
# Compiler for the GObject type system
brew "vala"
# Vi 'workalike' with many additional features
brew "vim"
# Pager/text based browser
brew "w3m"
# Internet file retriever
brew "wget"
# Manipulate SGML and XML catalogs
brew "xmlcatmgr"
# Convert XML to another format (based on XSL or other tools)
brew "xmlto"
# Modular BSD reimplementation of NASM
brew "yasm"
# General-purpose lossless data-compression library
brew "zlib"
# UNIX shell (command interpreter)
brew "zsh"
# Additional completion definitions for zsh
brew "zsh-completions"
# Vertical Blanking Interval (VBI) decoding library
brew "zvbi"
# Desktop client for the chat platform Cabal
cask "cabal"
# E-books management software
cask "calibre"
# OpenAI's coding agent that runs in your terminal
cask "codex"
cask "font-bitstream-vera-sans-mono-nerd-font"
cask "font-go-mono-nerd-font"
cask "font-hack-nerd-font"
cask "font-jetbrains-mono-nerd-font"
cask "font-mononoki-nerd-font"
cask "font-roboto-mono-nerd-font"
cask "font-ubuntu-mono-nerd-font"
cask "font-ubuntu-nerd-font"
# Set of tools to manage resources and applications hosted on Google Cloud
cask "gcloud-cli"
# Terminal emulator that uses platform-native UI and GPU acceleration
cask "ghostty"
# Personal online hard drive to store, view and share files
cask "stack"
# Network protocol analyzer
cask "wireshark-chmodbpf"
# OpenJDK distribution from Azul
cask "zulu"
# No vscode entries: brew bundle no longer manages VS Code extensions here.
#
# The 40 that used to be listed were whatever happened to be installed when this
# file was dumped, not a set anyone chose -- kiteco.kite was still among them,
# for a product that shut down in 2022. Two others,
# ms-azuretools.vscode-containers and ms-python.vscode-python-envs, failed every
# run by requiring a newer VS Code than the 1.93.0 installed, and since bundle
# treats any failure as a failed run, they kept the whole thing red.
#
# Extensions already installed are untouched; this only stops declaring them, so
# a fresh machine gets none of them.
go "github.com/koron/c3tr-client"
go "golang.org/x/tools/cmd/callgraph"
go "golang.org/x/tools/cmd/digraph"
go "golang.org/x/tools/cmd/godoc"
go "golang.org/x/tools/cmd/goimports"
go "golang.org/x/tools/gopls"
go "golang.org/x/tools/cmd/guru"
go "golang.org/x/tools/cmd/present"
go "golang.org/x/tools/cmd/stringer"
npm "@google/gemini-cli"
npm "chrome-devtools-mcp"
npm "typescript-language-server"
# typescript is declared as a formula above and must not be repeated here: npm's
# global prefix is /opt/homebrew, so both want to own /opt/homebrew/bin/tsc. The
# formula gets there first and npm then fails with EEXIST rather than overwrite
# it, which failed every `brew bundle` run. Project-local toolchains come from
# node_modules regardless, so nothing needs the global npm copy.

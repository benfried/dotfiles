### Makefile for Dmacro

## Installation parameters  --   CHANGE these before running "make install"

INSTALL = install
#INSTALL = cp

# A directory on your load path (to which you have write permission)

ELISP_DIR = /usr/local/share/elisp

# A directory on your Info-directory-list (to which you have write permission)
# If you don't want to install the manual, set this variable to "."

INFO_DIR  = /usr/local/share/info


## Make parameters

ELC = emacs -nw -batch -l ~/.emacs -f batch-byte-compile
INFO = emacs -nw -batch -l ~/.emacs -f batch-texinfo-format
.SUFFIXES: .elc .el
.SUFFIXES: .info .texinfo

.el.elc:
	$(ELC) $<

.texinfo.info:
	$(INFO) $<


## Dmacro parameters

ver = 2_1
sharcnt = 3

.PHONY: all install tree-killer  shar ship

DMACROS = demo.dm elisp.dm fortran.dm
OBJS1 = dmacro-bld.elc dm-c.elc  dm-compat.elc 
TEXT1 = README $(DMACROS) Makefile
OBJS2 = dmacro.elc dmacro-sv.elc
TEXT2 = 
OBJS3 = 
TEXT3 = dmacro.texinfo

OBJS  = $(OBJS1) $(OBJS2) $(OBJS3)
SRCS  = $(SRCS1) $(SRCS2) $(SRCS3)

SRCS1 = $(OBJS1:.elc=.el)
SRCS2 = $(OBJS2:.elc=.el)
SRCS3 = $(OBJS3:.elc=.el)

# SRCS2 goes first because dmacro.el must compile first!
all:
	$(ELC) $(SRCS2) $(SRCS1) $(SRCS3)

install: $(OBJS) dmacro.info
	$(INSTALL) $(OBJS) $(SRCS)  $(ELISP_DIR)
	$(INSTALL) $(DMACROS)	    $(ELISP_DIR)
	$(INSTALL) dmacro.info      $(INFO_DIR)
	@echo "## dmacro.info installed in $(INFO_DIR)."
	@echo "## Remember to add the appropriate line to the "dir" file!"

tree-killer:
	mkdir -p temp_doc_dir
	-cd temp_doc_dir; \
	 tex ../dmacro.texinfo; texindex dmacro.??; tex ../dmacro.texinfo; echo
	mv temp_doc_dir/dmacro.dvi .
	rm -rf temp_doc_dir
	@echo "## dmacro.dvi created.  Now print it using whatever magic"
	@echo "## works at your site.  For example: lpr -h -d dmacro.dvi"
	

TAGS: $(SRCS)
	etags $^

shar: dmacro$(ver).shar1 dmacro$(ver).shar2 dmacro$(ver).shar3

dmacro$(ver).shar1: $(TEXT1) $(SRCS1) 
	shar -n1 -e$(sharcnt) -o $@ $^

dmacro$(ver).shar2: $(TEXT2) $(SRCS2) 
	shar -n2 -e$(sharcnt) -o $@ $^

dmacro$(ver).shar3: $(TEXT3) $(SRCS3)
	cp dmacro.texinfo dm.texinfo
	compress dm.texinfo
	uuencode dm.texinfo.Z dm.texinfo.Z > manual.Z.uu
	rm dm.texinfo.Z
	shar -n3 -e$(sharcnt) -o temp.shar manual.Z.uu
	sed 's/^exit 0$$//' temp.shar >dmacro$(ver).shar3
	cat shar3-additions >>dmacro$(ver).shar3
	rm temp.shar
	rm manual.Z.uu

dmacro.tar: $(SRCS) $(TEXT1) $(TEXT2) $(TEXT3)
	tar cvf dmacro.tar $^

ship:
	mail -s "dmacro$(ver) (part 1 of $(sharcnt))" $(to)<dmacro$(ver).shar1
	mail -s "dmacro$(ver) (part 2 of $(sharcnt))" $(to)<dmacro$(ver).shar2
	mail -s "dmacro$(ver) (part 3 of $(sharcnt))" $(to)<dmacro$(ver).shar3

ciall:
	ci -l $(SRCS) $(TEXT1) $(TEXT2) $(TEXT3)

mciall:
	yes n | ci -l -m"$(LOG)" $(SRCS) $(TEXT1) $(TEXT2) $(TEXT3)

clean:
	rm *~

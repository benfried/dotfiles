27-Aug-92 22:42:20-GMT,65520;000000000001
Return-Path: <help-lucid-emacs-request@lucid.com>
Received: from lucid.com by banzai.cc.columbia.edu (5.59/FCB)
	id AA00949; Thu, 27 Aug 92 18:41:48 EDT
Received: by heavens-gate.lucid.com id AA03202g; Thu, 27 Aug 92 15:18:14 PDT
Received: from motgate.mot.com by heavens-gate.lucid.com id AA03195g; Thu, 27 Aug 92 15:15:46 PDT
Received: from pts1.pts.mot.com ([145.4.3.2]) by pobox.mot.com (4.1/SMI-4.0)
	id AA23657; Thu, 27 Aug 92 17:24:29 CDT
Received: from pts4.pts.mot.com by pts1.pts.mot.com (4.1/SMI-4.1)
	id AA13371; Thu, 27 Aug 92 18:15:09 EDT
Received: from msn25.motorola by pts4.pts.mot.com (4.1/SMI-4.1)
	id AA19956; Thu, 27 Aug 92 18:27:24 EDT
Date: Thu, 27 Aug 92 18:27:23 EDT
From: ex594bw@pts.mot.com (Bob Weiner)
Message-Id: <9208272227.AA19956@pts4.pts.mot.com>
Received: by msn25.motorola (4.1/SMI-4.1)
	id AA01252; Thu, 27 Aug 92 18:26:34 EDT
To: hyperbole@cs.brown.edu, help-lucid-emacs@lucid.com
Subject: Code and installation instructions for Hyperbole Lucid Emacs support.
Reply-To: hyperbole@pts.mot.com

Read the contents of the first file included below, LEMACS-INSTALL.
If you don't know what Lucid Emacs is or you don't use it,
just ignore this message.

#!/bin/sh
# This is a shell archive (produced by shar 3.49)
# To extract the files from this archive, save it to a file, remove
# everything above the "!/bin/sh" line above, and type "sh file_name".
#
# made 08/27/1992 22:22 UTC by ex594bw@msn25
# Source directory /tmp_mnt/home/apl_ind/research/info/hypb
#
# existing files will NOT be overwritten unless -c is specified
#
# This shar contains:
# length  mode       name
# ------ ---------- ------------------------------------------
#   1316 -rw-r--r-- LEMACS-INSTALL
#   3372 -rw-r--r-- MANIFEST
#  16661 -rw-r--r-- hui-le-but.el
#   6326 -rw-r--r-- hinit.el
#  11171 -rw-r--r-- hmouse-key.el
#  13603 -rw-r--r-- hui-menus.el
#   7288 -rw-r--r-- hsite-ex.el
#
# ============= LEMACS-INSTALL ==============
if test -f 'LEMACS-INSTALL' -a X"$1" != X"-c"; then
	echo 'x - skipping LEMACS-INSTALL (File already exists)'
else
echo 'x - extracting LEMACS-INSTALL (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'LEMACS-INSTALL' &&
To: hyperbole@cs.brown.edu, help-lucid-emacs@lucid.com
Subject: Code and installation instructions for Hyperbole Lucid Emacs support.
Reply-to: hyperbole@cs.brown.edu
X
If you don't know what Lucid Emacs is or you don't use it,
just ignore this message.
X
If you don't know what Hyperbole is or don't have a copy,
see the README file or get the compressed, tarred archive
from:
X
X	"/wilma.cs.brown.edu:pub/hyperbole"
X
The Lucid Emacs support provides highlighting and flashing of
Hyperbole buttons, smart key mouse control (as explained in a prior message),
and event-based key handling.  This code will be included as a
standard part of the next Hyperbole release, whenever that is.
X
To install it, first get a Hyperbole distribution (V3.04 would be
best) and unpack it or use your current version, then OVERWRITE the
files from the distribution with those included in this message (2 of
the files included here did not exist in prior Hyperbole
distributions: LEMACS-INSTALL and hui-le-but.el),
X
Then follow the site-specific configuration instructions in the README
file, use {C-u M-x byte-recompile-directory RTN} to byte-compile the
files from this posting which does not include .elc files and finally
load it for use.
X
Send all replies concerning Hyperbole to the hyperbole mail list
given in the Reply-to above.
SHAR_EOF
chmod 0644 LEMACS-INSTALL ||
echo 'restore of LEMACS-INSTALL failed'
Wc_c="`wc -c < 'LEMACS-INSTALL'`"
test 1316 -eq "$Wc_c" ||
	echo 'LEMACS-INSTALL: original size 1316, current size' "$Wc_c"
fi
# ============= MANIFEST ==============
if test -f 'MANIFEST' -a X"$1" != X"-c"; then
	echo 'x - skipping MANIFEST (File already exists)'
else
echo 'x - extracting MANIFEST (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'MANIFEST' &&
--- INTRODUCTION ---
DEMO            - Demonstration of basic Hyperbole button capabilities.
README          - Intro information on Hyperbole.  
REDISTRIB       - Optional info on redistributing Hyperbole. 
ChangeLog       - Summary of changes in recent Hyperbole releases.
X
--- DOCUMENTATION ---
hypb.info       - The Hyperbole Manual  (online version, top-level).
hypb.info-N     - The Hyperbole Manual  (online version, subpart N).
hypb.ps         - The Hyperbole Manual  (Postscript form).
hypb.texinfo    - The Hyperbole Manual  (source form).
hmouse-doc      - Summarizes Smart Key behaviors in different contexts.
X
--- SYSTEM ---
hact.el         - Hyperbole button action handling.
hactypes.el     - Default action types for Hyperbole.
hargs.el        - Obtains user input through Emacs for Hyperbole.
hbdata.el       - Hyperbole button attribute accessor methods.
hbmap.el        - Hyperbole button map maintenance for queries and lookups.
hbut.el         - Hyperbole button constructs.
hhist.el        - Maintains history of Hyperbole buttons selected.
hibtypes.el     - Hyperbole System Implicit Button Types.
hib-kbd.el      - Implicit button type for key sequences delimited with {}.
hinit.el        - Standard initializations for Hyperbole hypertext system.
hlvar.el        - Permits use of Hyperbole variables in local variable lists.
hmoccur.el      - Multi-buffer or multi-file regexp occurrence location.
hpath.el        - Hyperbole support routines for handling UNIX paths.  
hsite-ex.el     - Site-specific setup template for Hyperbole.
htz.el          - Timezone-based time and date support for Hyperbole.
hypb.el         - Miscellaneous Hyperbole support features.
set.el          - Provide general mathematical operators on unordered sets.
X
--- MAIL SUPPORT ---
hmail.el        - Support for Hyperbole buttons embedded in e-mail messages.
hmh.el          - Support for Hyperbole buttons in mail reader:   Mh.
hrmail.el       - Support for Hyperbole buttons in mail reader:   Rmail.
hsmail.el       - Support for Hyperbole buttons in mail composer: mail.
hvm.el          - Support for Hyperbole buttons in mail reader:  {Vm.
g#
--- USENET NEWS SUPPORT ---
hgnus.el        - Support Hyperbole buttons in news reader/poster: Gnus.
X
--- ROLODEX SUPPORT ---
wrolo.el        - Hierarchical, multi-file rolodex system
wrolo-logic.el  - Performs logical retrievals on rolodex files
Also a portion of hui-menus.el.
X
--- USER INTERFACE ---
hmous-info.el   - Walks through Info networks using one key.
hmouse-drv.el   - Smart Key/Mouse driver functions.
hmouse-key.el   - Key bindings for Hyperbole mouse control.
hmouse-tag.el   - Smart Key support of programming language tags location.
hui-ep-but.el   - Shared support for highlighting/flashing buttons under Epoch.
hui-epV3-b.el   - Epoch V3-specific button support.
hui-epV4-b.el   - Epoch V4-specific button support.
hui-le-but.el   - Lucid Emacs button highlighting and flashing support.
hui-menus.el    - One line command menus for Hyperbole.
hui-mouse.el    - Use key or mouse key for many functions, e.g. Hypb menus.
hui.el          - GNU Emacs User Interface to Hyperbole.
X
--- SYSTEM ENCAPSULATIONS ---
hsys-hbase.el   - Hyperbole support for the Hyperbase system.
hsys-wais.el    - Hyperbole support for WAIS browsing.
hsys-www.el     - Hyperbole support for WorldWide Web (WWW) document browsing.
SHAR_EOF
chmod 0644 MANIFEST ||
echo 'restore of MANIFEST failed'
Wc_c="`wc -c < 'MANIFEST'`"
test 3372 -eq "$Wc_c" ||
	echo 'MANIFEST: original size 3372, current size' "$Wc_c"
fi
# ============= hui-le-but.el ==============
if test -f 'hui-le-but.el' -a X"$1" != X"-c"; then
	echo 'x - skipping hui-le-but.el (File already exists)'
else
echo 'x - extracting hui-le-but.el (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'hui-le-but.el' &&
;;!emacs
;; $Id: 
;;
;; FILE:         hui-le-but.el
;; SUMMARY:      Lucid Emacs button highlighting and flashing support.
;; USAGE:        Lucid Emacs Lisp Library
;;
;; AUTHOR:       Bob Weiner
;; ORG:          Brown U.
;;
;; ORIG-DATE:    21-Aug-92
;; LAST-MOD:     26-Aug-92 at 22:53:35 by Bob Weiner
;;
;; This file is part of Hyperbole.
;; It is for use with Lucid Emacs, a modified version of GNU Emacs V19.
;;
;; Copyright (C) 1992  Brown University
;; Developed with support from Motorola Inc.
;; Available for use and distribution under the same terms as GNU Emacs.
;;
;; DESCRIPTION:  
;;
;;   This is truly prototype code.
;;
;;   Can't use read-only buttons here because then outline-mode
;;   becomes unusable.
;;
;; DESCRIP-END.
X
(if (not hyperb:lemacs-p)
X    (error "(hui-le-but.el): Load only under Lucid Emacs."))
X
;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************
X
(require 'hbut)
X
(defun le:background ()
X  "Returns default background color for current screen."
X  (face-background (get-face 'default)))
X
(defun le:foreground ()
X  "Returns default foreground color for current screen."
X  (face-foreground (get-face 'default)))
X
;;; ************************************************************************
;;; Public variables
;;; ************************************************************************
X
(defvar le:item-highlight-color (le:foreground)
X  "Color with which to highlight list/menu selections.
Call (ep:set-item-highlight <color>) to change value.")
X
;;; ************************************************************************
;;; Public functions
;;; ************************************************************************
X
(fset 'ep:but-add 'le:but-add)
X
(defun le:but-color ()
X  "Return current color of buffer's buttons."
X  (if le:color-ptr
X      (car le:color-ptr)
X    (le:foreground)))
X
(defun ep:but-create (&optional start-delim end-delim regexp-match)
X  "Mark all hyper-buttons in buffer as Lucid Emacs extents.
Will use optional strings START-DELIM and END-DELIM instead of default values.
If END-DELIM is a symbol, e.g. t, then START-DELIM is taken as a regular
expression which matches an entire button string.
If REGEXP-MATCH is non-nil, only buttons matching this argument are
highlighted."
X  (interactive)
X  (le:but-clear)
X  (le:but-create-all start-delim end-delim regexp-match))
X
(fset 'le:but-create 'ep:but-create)
X
(defun le:but-clear ()
X  "Delete all Hyperbole buttons from current buffer."
X  (interactive)
X  ;; Should only delete an extent if it uses 'hbut face,
X  ;; but V19.2 has no operator to get the face of an extent.
X  (map-extents '(lambda (extent unused-arg) (delete-extent extent)))
X  )
X
(defun le:but-create-all (&optional start-delim end-delim regexp-match)
X  "Mark all hyper-buttons in buffer as Epoch buttons, for later highlighting.
Will use optional strings START-DELIM and END-DELIM instead of default values.
If END-DELIM is a symbol, e.g. t, then START-DELIM is taken as a regular
expression which matches an entire button string.
If REGEXP-MATCH is non-nil, only buttons matching this argument are
highlighted."
X  (ebut:map '(lambda (lbl start end) (le:but-add start end le:but-face))
X	    start-delim end-delim regexp-match 'include-delims))
X	       
(defun ep:but-delete (&optional pos)
X  (delete-extent (extent-at (or pos (point)))))
X
;;; ************************************************************************
;;; Private functions
;;; ************************************************************************
X
(defun le:but-add (start end face)
X  "Add between START and END a button using FACE in current buffer."
X  (set-extent-face (make-extent start end) face)
X  )
X
(defmacro le:list-cycle (list-ptr list)
X  "Move LIST-PTR to next element in LIST or when at end to first element."
X  (` (or (and (, list-ptr)
X	      (setq (, list-ptr) (cdr (, list-ptr))))
X	 (setq (, list-ptr) (, list)))))
X
;;; ************************************************************************
;;; Private variables
;;; ************************************************************************
X
(defconst le:color-list '( "red" "blue" "paleturquoise4" "mediumpurple2"
"lightskyblue3" "springgreen2" "salmon" "yellowgreen" "darkorchid2"
"aquamarine4" "slateblue4" "slateblue1" "olivedrab1" "goldenrod4"
"goldenrod3" "cadetblue2" "burlywood1" "slategrey" "mistyrose"
"limegreen" "lightcyan" "goldenrod" "gainsboro" "skyblue1" "honeydew"
"yellow2" "tomato3" "skyblue" "purple4" "orange3" "bisque3" "bisque2"
"grey34" "gray99" "gray63" "gray44" "gray37" "gray33" "gray26" "azure1"
"snow4" "peru" "red" "lightgoldenrod4" "mediumseagreen" "blush"
"mediumorchid2" "lightskyblue1" "darkslateblue" "midnightblue"
"lightsalmon1" "lemonchiffon" "yellow" "lightsalmon" "coral"
"dodgerblue3" "darkorange4" "blue" "royalblue4" "red" "green" "cyan"
"darkviolet" "darksalmon" "darkorange" "blue" "pink" "magenta2"
"sienna4" "khaki2" "grey75" "grey74" "grey73" "grey69" "grey68" "grey35"
"grey13" "gray90" "gray81" "gray55" "gray51" "gray31" "snow2" "pink3"
"grey7" "gray1" "red4" "red3" "tan" "red" "yellow" "mediumvioletred"
"lightslategrey" "lavenderblush4" "turquoise" "darkturquoise"
"darkslategrey" "lightskyblue" "lightsalmon4" "lightsalmon3"
"forestgreen" "dodgerblue4" "orchid" "rosybrown4" "brown" "peachpuff3"
"palegreen3" "orangered2" "rose" "lightcyan4" "indianred4" "indianred3"
"seagreen2" "indianred" "deeppink1" "navyblue" "lavender" "grey"
"deeppink" "salmon4" "salmon3" "oldlace" "grey78" "grey77" "grey54"
"grey45" "grey21" "gray97" "gray96" "gray95" "gray88" "gray87" "gray86"
"gray70" "gray57" "gray38" "gray12" "gray11" "plum3" "linen" "gray9"
"gray8" "blue4" "beige" "turquoise" "blue" "lemonchiffon4"
"darkseagreen1" "antiquewhite3" "mediumorchid" "springgreen"
"turquoise4" "steelblue3" "mistyrose2" "lightcyan2" "red" "firebrick2"
"royalblue" "cadetblue" "skyblue3" "yellow3" "salmon1" "orange4"
"hotpink" "grey90" "gray56" "gray39" "gray18" "gray14" "plum4" "grey6"
"gray6" "gold3" "gold1" "blue2" "tan2" "cyan" "mediumspringgreen"
"darkolivegreen2" "goldenrod" "lightsteelblue" "brown" "whip"
"chartreuse3" "violetred4" "royalblue2" "royalblue1" "papayawhip"
"mistyrose3" "lightcyan1" "aquamarine" "skyblue4" "hotpink4" "hotpink3"
"hotpink2" "dimgray" "tomato" "grey66" "grey65" "grey64" "grey33"
"grey27" "gray76" "gray69" "gray68" "grey0" "azure" "green"
"darkgoldenrod4" "darkgoldenrod3" "darkgoldenrod2" "darkgoldenrod"
"brown" "lightsalmon2" "deepskyblue4" "deepskyblue3" "deepskyblue2"
"deepskyblue" "darkorange1" "violetred3" "violetred2" "violetred1"
"slateblue3" "slateblue2" "drab" "indianred1" "firebrick1" "cadetblue4"
"violetred" "rosybrown" "blue" "firebrick" "grey100" "wheat4" "grey79"
"grey76" "grey61" "gray93" "gray84" "gray65" "gray36" "gray32" "gray13"
"gray10" "azure3" "snow1" "tan1" "gray" "darkolivegreen1" "blue"
"almond" "lavenderblush3" "lavenderblush2" "lavenderblush1"
"darkolivegreen" "lavenderblush" "aquamarine2" "red" "olivedrab2"
"mistyrose4" "mistyrose1" "lightcyan3" "lightcoral" "chartreuse"
"peachpuff" "palegreen" "mintcream" "skyblue2" "moccasin" "tomato1"
"orchid3" "maroon3" "salmon" "grey81" "grey62" "grey39" "grey38"
"grey37" "gray92" "gray83" "gray66" "gray54" "gray50" "gray30" "gray19"
"gray15" "azure4" "grey3" "tan3" "pink" "gray" "blue" "lightsteelblue2"
"lightsteelblue1" "green" "lightslategray" "lemonchiffon2"
"springgreen1" "greenyellow" "chartreuse2" "grey" "royalblue3"
"powderblue" "peachpuff2" "palegreen2" "cream" "slateblue" "seashell2"
"deeppink2" "darkkhaki" "maroon4" "sienna" "grey71" "grey67" "grey18"
"gray59" "gray43" "gray25" "bisque" "red1" "mediumslateblue"
"lightgoldenrod1" "goldenrod" "paleturquoise3" "lightskyblue4" "green"
"yellow" "smoke" "blue" "white" "steelblue4" "rosybrown3" "peachpuff1"
"palegreen1" "blueviolet" "seashell4" "sienna3" "grey40" "gray91"
"gray82" "gray5" "cyan2" "cyan1" "blue1" "snow" "lightgoldenrod2"
"lightslateblue" "mediumorchid3" "darkseagreen4" "springgreen3" "green"
"slategray4" "slategray3" "slategray2" "blue" "peachpuff4" "palegreen4"
"green" "orangered3" "goldenrod1" "ghostwhite" "firebrick4" "firebrick3"
"cadetblue3" "slategray" "seashell3" "honeydew3" "cornsilk4" "cornsilk2"
"purple1" "dimgrey" "khaki1" "ivory3" "grey70" "grey60" "grey32"
"grey22" "grey12" "gray98" "gray89" "gray71" "gray64" "gray60" "gray49"
"azure2" "gray3" "paleturquoise1" "mediumpurple1" "purple"
"lemonchiffon1" "blue" "navajowhite3" "darkorchid1" "orange"
"goldenrod2" "khaki" "chocolate2" "burlywood2" "honeydew1" "darkgreen"
"thistle3" "thistle2" "thistle1" "thistle" "maroon2" "maroon1" "grey53"
"grey44" "grey25" "gray74" "gray45" "gray41" "gray35" "gray27" "gray23"
"gray16" "brown4" "wheat" "coral" "tan4" "lightgoldenrodyellow" "blue"
"green" "gray" "palevioletred3" "mediumpurple4" "mediumpurple3"
"saddlebrown" "blue" "darkorchid4" "darkorchid3" "puff" "olivedrab4"
"lightblue4" "lightpink" "lightgray" "honeydew2" "cornsilk1" "lace"
"sienna1" "bisque4" "orchid" "khaki3" "grey84" "grey83" "grey82"
"grey72" "grey52" "grey43" "grey26" "grey14" "grey10" "gray75" "gray53"
"gray21" "gray20" "brown3" "grey8" "red2" "navy" "grey" "gold"
"mediumaquamarine" "lightgoldenrod" "darkslategray4" "darkseagreen3"
"darkseagreen2" "antiquewhite4" "white" "springgreen4" "lightyellow4"
"white" "aquamarine1" "turquoise3" "steelblue2" "rosybrown2" "pink"
"gray" "indianred2" "dodgerblue" "green" "seagreen1" "deeppink4"
"aliceblue" "magenta1" "pink" "sienna2" "orchid1" "gray100" "grey97"
"grey94" "grey87" "grey86" "grey51" "grey42" "grey19" "gray94" "gray85"
"gray61" "brown2" "khaki" "grey1" "gold4" "blue" "green" "grey"
"turquoise" "paleturquoise" "mediumorchid4" "antiquewhite2"
"lightyellow2" "violet" "salmon" "chartreuse1" "turquoise1" "sandybrown"
"orangered1" "lightpink1" "lightblue2" "lightblue1" "grey" "seagreen4"
"seagreen3" "lightblue" "deeppink3" "burlywood" "seashell" "hotpink1"
"gray" "yellow4" "yellow" "purple" "orange" "ivory4" "grey99" "grey89"
"grey63" "grey58" "grey49" "grey31" "grey24" "grey20" "green4" "green1"
"gray73" "gray67" "coral3" "coral2" "plum2" "pink4" "ivory" "gray4"
"gray2" "gold2" "aquamarine" "grey" "lightgoldenrod3" "darkolivegreen3"
"darkgoldenrod1" "goldenrod" "orchid" "chiffon" "navajowhite4"
"deepskyblue1" "lightyellow" "floralwhite" "blue" "mediumblue"
"chocolate4" "chocolate3" "burlywood4" "turquoise" "steelblue" "green"
"lawngreen" "honeydew4" "seagreen" "orchid4" "wheat1" "violet" "ivory1"
"grey88" "grey85" "grey57" "grey56" "grey55" "grey48" "grey47" "grey46"
"grey30" "grey17" "gray47" "gray29" "pink2" "grey5" "grey4" "green"
"gray0" "brown" "lightsteelblue4" "darkolivegreen4" "palevioletred4"
"blue" "darkslategray3" "darkslategray2" "darkslategray1"
"blanchedalmond" "palegoldenrod" "blue" "lightseagreen" "lemonchiffon3"
"darkslategray" "green" "darkseagreen" "antiquewhite" "darkorange2"
"chartreuse4" "blue" "rosybrown1" "olivedrab3" "lightpink2" "orangered"
"thistle4" "blue" "cornsilk" "salmon2" "orchid2" "ivory2" "grey93"
"grey92" "grey91" "grey36" "grey29" "grey28" "grey16" "gray79" "gray78"
"gray77" "gray48" "gray17" "coral4" "coral1" "plum1" "pink1" "grey9"
"grey2" "gray7" "cyan4" "blue3" "plum" "cornflowerblue" "lightskyblue2"
"antiquewhite1" "navajowhite2" "navajowhite1" "lightyellow3"
"navajowhite" "darkorange3" "whitesmoke" "turquoise2" "steelblue1"
"lightpink4" "lightblue3" "green" "chocolate1" "blue" "olivedrab"
"lightgrey" "chocolate" "magenta4" "magenta3" "yellow1" "purple3"
"purple2" "orange2" "orange1" "magenta" "bisque1" "wheat2" "maroon"
"khaki4" "grey96" "grey95" "grey80" "grey50" "grey41" "grey15" "grey11"
"gray80" "gray58" "gray40" "gray34" "gray22" "brown1" "snow3"
"mediumturquoise" "lightsteelblue3" "palevioletred2" "palevioletred1"
"paleturquoise2" "green" "palevioletred" "mediumorchid1" "white"
"mediumpurple" "lightyellow1" "dodgerblue2" "dodgerblue1" "violet"
"aquamarine3" "slategray1" "gray" "orangered4" "lightpink3" "blue"
"darkorchid" "cadetblue1" "burlywood3" "seashell1" "cornsilk3" "tomato4"
"tomato2" "wheat3" "grey98" "grey59" "grey23" "green3" "green2" "gray72"
"gray62" "gray52" "gray46" "gray42" "gray28" "gray24" "white" "cyan3"
"black" ))
X
(defvar le:color-ptr nil
X  "Pointer to current color name table to use for Hyperbole buttons in Lemacs.")
X
(defconst le:good-colors
X  '(
X    "medium violet red" "indianred4" "firebrick1" "DarkGoldenrod" "NavyBlue"
X    "darkorchid" "tomato3" "mediumseagreen" "deeppink" "forestgreen"
X    "mistyrose4" "slategrey" "purple4" "dodgerblue3" "mediumvioletred"
X    "lightsalmon3" "orangered2" "turquoise4" "Gray55"
X    )
X  "Good colors for contrast against wheat background and black foreground.")
X
X
;;; ************************************************************************
;;; Public functions
;;; ************************************************************************
X
(defun le:cycle-but-color (&optional color)
X  "Switches button color to optional COLOR name or next item referenced by le:color-ptr."
X  (interactive "sHyperbole button color: ")
X  (if (not (x-color-display-p))
X      nil
X    (if color (setq le:color-ptr nil))
X    (set-face-foreground
X     le:but-face (or color (car (le:list-cycle le:color-ptr le:good-colors))))
X    (set-face-background le:flash-face (le:but-color))
X    (sit-for 0)
X    t))
X
(defun le:but-flash ()
X  "Flash a Hyperbole button at point to indicate selection, when using Epoch."
X  (interactive)
X  (let ((ibut) (prev)
X	(start (hattr:get 'hbut:current 'lbl-start))
X	(end   (hattr:get 'hbut:current 'lbl-end)))
X    (and start end (setq prev (extent-at (point))
X			 ibut t)
X	 (if (not prev) (le:but-add start end le:but-face)))
X    (let* ((b (extent-at (point)))
X	   (a (and (extentp b)
X		   ;; This should be changed to (get-extent-face b) when that
X		   ;; function is available.
X		   le:but-face)))
X      (if a
X	  (progn
X	    (set-extent-face b le:flash-face)
X	    (sit-for 0)  ;; Force display update
X	    ;; Delay before redraw button
X	    (let ((i 0)) (while (< i le:but-flash-time) (setq i (1+ i))))
X	    (set-extent-face b le:but-face)
X	    (sit-for 0)  ;; Force display update
X	    )))
X    (if (and ibut (not prev)) (le:but-delete))
X    ))
X
(defun ep:set-item-highlight (&optional color-name)
X  "Setup or reset item highlight style using optional color-name."
X  (make-local-variable 'le:item-style)
X  (if (stringp color-name) (setq le:item-highlight-color color-name))
X  (if (not le:style_highlight)
X      (progn 
X	(setq le:style_highlight (make-face 'hbut-highlight))
X	(set-face-foreground le:style_highlight (le:background))
X	(set-face-background le:style_highlight le:item-highlight-color)
X	(set-face-underline-p le:style_highlight nil)))
X  (if (not (equal (face-background le:style_highlight)
X		  le:item-highlight-color))
X      (set-face-background le:style_highlight le:item-highlight-color))
X  (setq le:item-style le:style_highlight)
X  )
X
(defun le:select-item (&optional pnt)
X  "Select item in current buffer at optional position PNT using le:item-style."
X  (if le:item-button
X      nil
X    (set-extent-face (setq le:item-button (make-extent (point) (point)))
X		     le:item-style))
X  (if pnt (goto-char pnt))
X  (skip-chars-forward " \t")
X  (skip-chars-backward "^ \t\n")
X  (let ((start (point)))
X    (save-excursion
X      (skip-chars-forward "^ \t\n")
X      (update-extent le:item-button start (point))
X      ))
X  (sit-for 0)  ;; Force display update
X  )
X
(defun ep:select-line (&optional pnt)
X  "Select line in current buffer at optional position PNT using le:item-style."
X  (if le:item-button
X      nil
X    (set-extent-face (setq le:item-button (make-extent (point) (point)))
X		     le:item-style))
X  (if pnt (goto-char pnt))
X  (save-excursion
X    (beginning-of-line)
X    (update-extent le:item-button (point) (progn (end-of-line) (point)))
X    )
X  (sit-for 0)  ;; Force display update
X  )
X
;;; ************************************************************************
;;; Private variables
;;; ************************************************************************
X
(defvar le:but-face (make-face 'hbut) "Face for hyper-buttons.")
(setq ep:but le:but-face)
(defvar le:flash-face (make-face 'hbut-flash) "Style for flashing hyper-buttons.")
(set-face-foreground le:but-face (le:but-color))
(set-face-background le:but-face (le:background))
(set-face-background le:flash-face (le:but-color))
(set-face-foreground le:flash-face (le:foreground))
X
(make-variable-buffer-local 'le:item-button)
(defvar le:item-style nil "Style for item marking.")
(defvar le:style_highlight nil "Highlight style available for item marking.")
X
(provide 'hui-le-but)
SHAR_EOF
chmod 0644 hui-le-but.el ||
echo 'restore of hui-le-but.el failed'
Wc_c="`wc -c < 'hui-le-but.el'`"
test 16661 -eq "$Wc_c" ||
	echo 'hui-le-but.el: original size 16661, current size' "$Wc_c"
fi
# ============= hinit.el ==============
if test -f 'hinit.el' -a X"$1" != X"-c"; then
	echo 'x - skipping hinit.el (File already exists)'
else
echo 'x - extracting hinit.el (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'hinit.el' &&
;;!emacs
;; $Id: hinit.el,v 1.2 1992/05/14 10:11:00 rsw Exp $
;;
;; FILE:         hinit.el
;; SUMMARY:      Standard initializations for Hyperbole hypertext system.
;; USAGE:        GNU Emacs Lisp Library
;;
;; AUTHOR:       Bob Weiner
;; ORG:          Brown U.
;;
;; ORIG-DATE:     1-Oct-91 at 02:32:51
;; LAST-MOD:      3-Mar-92 at 00:23:38 by Bob Weiner
;;
;; This file is part of Hyperbole.
;; 
;; Copyright (C) 1991, Brown University, Providence, RI
;; Developed with support from Motorola Inc.
;; 
;; Permission to use, modify and redistribute this software and its
;; documentation for any purpose other than its incorporation into a
;; commercial product is hereby granted without fee.  A distribution fee
;; may be charged with any redistribution.  Any distribution requires
;; that the above copyright notice appear in all copies, that both that
;; copyright notice and this permission notice appear in supporting
;; documentation, and that neither the name of Brown University nor the
;; author's name be used in advertising or publicity pertaining to
;; distribution of the software without specific, written prior permission.
;; 
;; Brown University makes no representations about the suitability of this
;; software for any purpose.  It is provided "as is" without express or
;; implied warranty.
;;
;;
;; DESCRIPTION:  
;; DESCRIP-END.
X
;;; ************************************************************************
;;; Public variables
;;; ************************************************************************
X
(defconst hyperb:version "3.05P" "Hyperbole revision number.")
X
(defvar   hyperb:host-domain nil
X  "<@domain-name> for current host.  Set automatically by 'hyperb:init'.")
X
;;; ************************************************************************
;;; Required Init functions
;;; ************************************************************************
X
(require 'set)
X
(defun var:append (var-symbol-name list-to-add)
X  "Appends to value held by VAR-SYMBOL-NAME, LIST-TO-ADD.  Returns new value.
If VAR-SYMBOL-NAME is unbound, it is set to LIST-TO-ADD.
Often used to append to 'hook' variables."
X  (let ((val))
X    (if (and (boundp var-symbol-name)
X	     (setq val (symbol-value var-symbol-name))
X	     (or (if (symbolp val) (setq val (cons val nil)))
X		 (listp val)))
X	;; Don't add if list elts are already there.
X	(if (memq nil (mapcar '(lambda (elt) (set:member elt val))
X			      list-to-add))
X	    (set-variable var-symbol-name
X			  (if (eq (car val) 'lambda)
X			      (apply 'list val list-to-add)
X			    (append val list-to-add)))
X	  val)
X      (set-variable var-symbol-name list-to-add))))
X
(defun first-line-p ()
X  "Returns true if point is on the first line of the buffer."
X  (save-excursion (beginning-of-line) (bobp)))
X
(defun last-line-p ()
X  "Returns true if point is on the last line of the buffer."
X  (save-excursion (end-of-line) (eobp)))
X
;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************
X
(if (fboundp 'smart-menu)
X    (makunbound 'smart-key-alist))
(mapcar 'require '(hui-mouse hypb hui-menus hbmap hibtypes))
X
;;; Hyperbole msg reader autoloads.
(autoload 'Rmail-init "hrmail" "Initializes Hyperbole Rmail support.")
(autoload 'Mh-init    "hmh"    "Initializes Hyperbole Mh support.")
(autoload 'Vm-init    "hvm"    "Initializes Hyperbole Vm support.")
(autoload 'Pm-init    "hpm"    "Initializes Hyperbole PIEmail support.")
(autoload 'Gnus-init  "hgnus"  "Initializes Hyperbole Gnus support.")
X
;;; ************************************************************************
;;; Public functions
;;; ************************************************************************
X
(defun hyperb:init ()
X  "Standard configuration routine for Hyperbole."
X  (interactive)
X  (run-hooks 'hyperb:init-hook)
X  (hyperb:check-dir-user)
X  (or hyperb:host-domain (setq hyperb:host-domain (hypb:domain-name)))
X  (hyperb:act-set)
X  ;;
X  ;; Highlight explicit buttons whenever a file is read in.
X  ;;
X  (if (or hyperb:epoch-p hyperb:lemacs-p)
X      (var:append 'find-file-hooks '(ep:but-create)))
X  ;;
X  ;; Save button attribute file whenever same dir file is saved and
X  ;; 'ebut:hattr-save' is non-nil.
X  ;;
X  (var:append 'write-file-hooks '(hattr:save))
)
X
(defun hyperb:act-set ()
X  "COORDINATION IS NOT YET OPERATIONAL.  hui-coord.el IS NOT INCLUDED.
Sets Hyperbole action command to uncoordinated or coordinated operation.
Coordinated is used when 'hcoord:hosts' is a non-nil list.
See \"hui-coord.el\"."
X  (interactive)
X  (fset 'hyperb:act (if (and (boundp 'hcoord:hosts) hcoord:hosts)
X		     'hcoord:act 'hbut:act)))
X
(defun hyperb:action-v1 ()
X  "Signals error if Version 1 Hyperbole link button is selected."
X  (error "(hyperb:action-v1): Hyperbole version 1 buttons are not supported."))
X
;;; ************************************************************************
;;; Private functions
;;; ************************************************************************
X
(defun hyperb:check-dir-user ()
X  "Ensures 'hbmap:dir-user' exists and is writable or signals an error."
X  (if (or (null hbmap:dir-user) (not (stringp hbmap:dir-user))
X	  (and (setq hbmap:dir-user (file-name-as-directory
X				     (expand-file-name hbmap:dir-user)))
X	       (file-directory-p hbmap:dir-user)
X	       (not (file-writable-p hbmap:dir-user))))
X      (error
X       "(hyperb:init): 'hbmap:dir-user' must be a writable directory name."))
X  (let ((hbmap:dir-user (directory-file-name hbmap:dir-user)))
X    (or (file-directory-p hbmap:dir-user)   ;; Exists and is writable.
X	(let* ((parent-dir (file-name-directory
X			    (directory-file-name hbmap:dir-user))))
X	  (cond
X	   ((not (file-directory-p parent-dir))
X	    (error
X	     "(hyperb:init): 'hbmap:dir-user' parent dir does not exist."))
X	   ((not (file-writable-p parent-dir))
X	    (error
X	     "(hyperb:init): 'hbmap:dir-user' parent directory not writable."))
X	   ((hypb:call-process-p "mkdir" nil nil hbmap:dir-user)
X	    (or (file-writable-p hbmap:dir-user)
X		(or (progn (hypb:chmod '+ 700 hbmap:dir-user)
X			   (file-writable-p hbmap:dir-user))
X		    (error "(hyperb:init): Can't write to 'hbmap:dir-user'.")
X		    )))
X	   (t (error "(hyperb:init): 'hbmap:dir-user' create failed."))))))
X  t)
X
(provide 'hinit)
X
SHAR_EOF
chmod 0644 hinit.el ||
echo 'restore of hinit.el failed'
Wc_c="`wc -c < 'hinit.el'`"
test 6326 -eq "$Wc_c" ||
	echo 'hinit.el: original size 6326, current size' "$Wc_c"
fi
# ============= hmouse-key.el ==============
if test -f 'hmouse-key.el' -a X"$1" != X"-c"; then
	echo 'x - skipping hmouse-key.el (File already exists)'
else
echo 'x - extracting hmouse-key.el (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'hmouse-key.el' &&
;;!emacs
;; $Id: hmouse-key.el,v 1.2 1992/05/14 10:11:30 rsw Exp $
;;
;; FILE:         hmouse-key.el
;; SUMMARY:      System-dependent key bindings for Hyperbole mouse control.
;; USAGE:        GNU Emacs Lisp Library
;;
;; AUTHOR:       Bob Weiner
;; ORG:          Brown U.
;;
;; ORIG-DATE:     3-Sep-91 at 21:40:58
;; LAST-MOD:      9-Jan-92 at 09:04:27 by Bob Weiner
;;
;; This file is part of Hyperbole.
;; 
;; Copyright (C) 1991, Brown University, Providence, RI
;; Developed with support from Motorola Inc.
;; 
;; Permission to use, modify and redistribute this software and its
;; documentation for any purpose other than its incorporation into a
;; commercial product is hereby granted without fee.  A distribution fee
;; may be charged with any redistribution.  Any distribution requires
;; that the above copyright notice appear in all copies, that both that
;; copyright notice and this permission notice appear in supporting
;; documentation, and that neither the name of Brown University nor the
;; author's name be used in advertising or publicity pertaining to
;; distribution of the software without specific, written prior permission.
;; 
;; Brown University makes no representations about the suitability of this
;; software for any purpose.  It is provided "as is" without express or
;; implied warranty.
;;
;;
;; DESCRIPTION:  
;;
;;   Supports Epoch, Lucid Emacs, X, Sunview, NeXTstep, and Apollo DM
;;   window systems.
;;
;;   'sm-mouse-setup' globally binds middle and right mouse buttons as
;;   primary and secondary Smart Keys respectively.
;;
;;   'sm-mouse-toggle-bindings' may be bound to a key.  It switches between
;;   Smart Key mouse bindings and previous mouse key bindings any time
;;   after 'sm-mouse-setup' has been called.
;;
;; DESCRIP-END.
X
;;; ************************************************************************
;;; Required Elisp Libraries
;;; ************************************************************************
X
(defun sm-window-sys-term ()
X  "Returns the first part of the term-type if running under a window system, else nil.
Where a part in the term-type is delimited by a '-' or  an '_'."
X  (let ((term (cond (hyperb:epoch-p "epoch")
X		    (hyperb:lemacs-p "lemacs")
X		    ((eq window-system 'x) "xterm")
X		    ((or window-system 
X			 (featurep 'mouse)     (featurep 'x-mouse)
X			 (featurep 'sun-mouse) (featurep 'apollo)
X			 (featurep 'eterm-mouse))
X		     (getenv "TERM")))))
X    (and term
X	 (substring term 0 (string-match "[-_]" term)))))
X
(let ((wsys (sm-window-sys-term)))
X  (cond
X   ;; Epoch
X   ((equal wsys "epoch")   (require 'mouse))
X   ;; Lucid Emacs
X   ((equal wsys "lemacs")  (require 'x-mouse))
X   ;; X
X   ((equal wsys "xterm")   (require 'x-mouse))
X   ;; SunView
X   ((equal wsys "sun")     (require 'sun-fns))
X   ;; NeXT
X   ((equal wsys "next")    (require 'eterm-mouse))
X   ;; Apollo
X   ((equal wsys "apollo")  (require 'apollo))
X   ))
X
;;; ************************************************************************
;;; Public functions
;;; ************************************************************************
X
(defun sm-mouse-get-bindings ()
X  "Returns list of bindings for mouse keys prior to their use as Smart Keys."
X  (let ((wsys (sm-window-sys-term)))
X    (cond
X     ;; Epoch
X     ((equal wsys "epoch")
X      (mapcar '(lambda (key) (cons key (aref mouse::global-map key)))
X	      (list (mouse::index mouse-middle mouse-down)
X		    (mouse::index mouse-middle mouse-up)
X		    (mouse::index mouse-right mouse-down)
X		    (mouse::index mouse-right mouse-up))))
X     ;; Lucid Emacs
X     ((equal wsys "lemacs")
X      (mapcar '(lambda (key) (cons key (lookup-key global-map key)))
X	      '(button2 button2up button3 button3up)))
X     ;; X
X     ((equal wsys "xterm")
X      (mapcar '(lambda (key) (cons key (lookup-key mouse-map key)))
X	      (list x-button-middle x-button-middle-up
X		    x-button-right  x-button-right-up)))
X     ;; SunView or NeXT
X     ((or (equal wsys "sun") (equal wsys "next"))
X      (mapcar '(lambda (key)
X		 (setq key (mouse-list-to-mouse-code key))
X		 (cons key (mousemap-get key current-global-mousemap)))
X	      '((text        middle) (text     up middle)
X		(text         right) (text     up  right))))
X     ;; Apollo Display Manager
X     ((equal wsys "apollo")
X      (mapcar '(lambda (key-str) (apollo-mouse-key-and-binding key-str))
X	      '("M2D" "M2U" "M3D" "M3U")))
X     )))
X
(defun sm-mouse-set-bindings (key-binding-list)
X  "Sets mouse keys used as Smart Keys to bindings in KEY-BINDING-LIST.
KEY-BINDING-LIST is the value returned by 'sm-mouse-get-bindings' prior to
Smart Key setup."
X  (let ((wsys (sm-window-sys-term)))
X    (cond
X     ;; Epoch
X     ((equal wsys "epoch")
X      (mapcar
X       '(lambda (key-and-binding)
X	  (aset mouse::global-map (car key-and-binding)
X		(cdr key-and-binding)))
X       key-binding-list))
X     ;; Lucid Emacs
X     ((equal wsys "lemacs")
X      (mapcar
X       '(lambda (key-and-binding)
X	  (global-set-key (car key-and-binding) (cdr key-and-binding)))
X       key-binding-list))
X     ;; X
X     ((equal wsys "xterm")
X      (mapcar
X       '(lambda (key-and-binding)
X	  (define-key mouse-map (car key-and-binding) (cdr key-and-binding)))
X       key-binding-list))
X     ;; SunView or NeXT
X     ((or (equal wsys "sun") (equal wsys "next"))
X      (mapcar
X       '(lambda (key-and-binding)
X	  (global-set-mouse (car key-and-binding) (cdr key-and-binding)))
X       key-binding-list))
X     ;; Apollo Display Manager
X     ((equal wsys "apollo")
X      (mapcar
X       '(lambda (key-and-binding)
X	  (global-set-key (car key-and-binding) (cdr key-and-binding)))
X       key-binding-list))
X     )))
X
(defun sm-mouse-setup ()
X  "Binds mouse keys for use as Smart Keys."
X  (interactive)
X  (or sm-mouse-bindings-p
X      (setq sm-mouse-previous-bindings (sm-mouse-get-bindings)))
X  (let ((wsys (sm-window-sys-term)))
X    ;; Ensure Gillespie's Info mouse support is off since
X    ;; Hyperbole handles that.
X    (setq Info-mouse-support nil)
X    (cond ((equal wsys "epoch")
X	   (setq mouse-set-point-command 'mouse::set-point)
X	   (global-set-mouse mouse-middle mouse-down  'sm-depress)
X	   (global-set-mouse mouse-middle mouse-up    'smart-key-mouse)
X	   (global-set-mouse mouse-right  mouse-down  'sm-depress-meta)
X	   (global-set-mouse mouse-right  mouse-up    'smart-key-mouse-meta))
X	  ((equal wsys "lemacs")
X	   (setq mouse-set-point-command 'sm-lemacs-move-point)
X	   (global-set-key 'button2     'sm-depress)
X	   (global-set-key 'button2up   'smart-key-mouse)
X	   (global-set-key 'button3     'sm-depress-meta)
X	   (global-set-key 'button3up   'smart-key-mouse-meta))
X	  ((equal wsys "xterm")
X	   (setq mouse-set-point-command 'x-mouse-set-point)
X	   (define-key mouse-map x-button-middle 'sm-depress)
X	   (define-key mouse-map x-button-middle-up 'smart-key-mouse)
X	   (define-key mouse-map x-button-right 'sm-depress-meta)
X	   (define-key mouse-map x-button-right-up 'smart-key-mouse-meta)
X	   ;; Use these instead of the above for a true META-BUTTON binding.
X	   ;; (define-key mouse-map x-button-m-middle 'sm-depress-meta)
X	   ;; (define-key mouse-map x-button-m-middle-up 'smart-key-mouse-meta)
X	   )
X	  ;; SunView or NeXT
X	  ((or (equal wsys "sun") (equal wsys "next"))
X	   (setq mouse-set-point-command 'sm-sun-move-point)
X	   (global-set-mouse '(text        middle) 'sm-depress)
X	   (global-set-mouse '(text     up middle) 'smart-key-mouse)
X	   (global-set-mouse '(text         right) 'sm-depress-meta)
X	   (global-set-mouse '(text     up  right) 'smart-key-mouse-meta)
X	   ;; Use these instead of the above for a true META-BUTTON binding.
X	   ;; (global-set-mouse '(text meta   middle) 'sm-depress-meta)
X	   ;; (global-set-mouse '(text meta up middle) 'smart-key-mouse-meta)
X	   )
X	  ((equal wsys "apollo")
X	   (setq mouse-set-point-command 'apollo-mouse-move-point)
X	   (bind-apollo-mouse-button "M2D" 'sm-depress)
X	   (bind-apollo-mouse-button "M2U" 'smart-key-mouse)
X	   (bind-apollo-mouse-button "M3D" 'sm-depress-meta)
X	   (bind-apollo-mouse-button "M3U" 'smart-key-mouse-meta)
X	   ;; Use these instead of the above for a true META-BUTTON binding.
X	   ;; (bind-apollo-mouse-button "M2U" 'smart-key-mouse
X	   ;;  'smart-key-mouse-meta)
X	   ;; (bind-apollo-mouse-button "M2D" 'sm-depress 'sm-depress-meta)
X	   )))
X  (setq sm-mouse-bindings (sm-mouse-get-bindings)
X	sm-mouse-bindings-p t))
X
(defun sm-mouse-toggle-bindings ()
X  "Toggles between Smart Key mouse settings and their prior bindings."
X  (interactive)
X  (let ((key-binding-list (if sm-mouse-bindings-p
X			      sm-mouse-previous-bindings
X			    sm-mouse-bindings))
X	(other-list-var (if sm-mouse-bindings-p
X			    'sm-mouse-bindings
X			  'sm-mouse-previous-bindings)))
X    (if key-binding-list
X	(progn
X	  (set other-list-var (sm-mouse-get-bindings))
X	  (sm-mouse-set-bindings key-binding-list)
X	  (message "%s mouse bindings in use."
X		   (if (setq sm-mouse-bindings-p (not sm-mouse-bindings-p))
X		       "Smart Key" "Personal")))
X      (error "(sm-mouse-toggle-bindings): Null %s." other-list-var))))
X
;;; ************************************************************************
;;; Private functions
;;; ************************************************************************
X
(if (fboundp 'bind-apollo-mouse-button)
X    (defun apollo-mouse-key-and-binding (mouse-button)
X      "Returns binding for an Apollo MOUSE-BUTTON (a string) or nil if none."
X      (interactive "sMouse Button: ")
X      (let ((numeric-code (cdr (assoc mouse-button *apollo-mouse-buttons*))))
X	(if (null numeric-code)
X	    (error "(hmouse-key): %s is not a valid Apollo mouse key name."
X		   mouse-button))
X	(if (stringp numeric-code)
X	    (setq numeric-code
X		  (cdr (assoc numeric-code *apollo-mouse-buttons*))))
X	(let ((key-sequence (concat "\M-*" (char-to-string numeric-code))))
X	  (cons key-sequence (global-key-binding key-sequence))))))
X
(defun sm-depress (&rest args)
X  (interactive)
X  (and (car args) (listp (car args)) (setq args (car args)))
X  (smart-key-set-point args)
X  (setq *smart-key-depressed* args
X	*smart-key-window* (selected-window)
X	*smart-key-modeline-window*
X	(if *smart-key-window* nil (selected-window)))
X  (if *smart-key-meta-depressed*
X      (smart-key-help 'meta)))
X
(defun sm-depress-meta (&rest args)
X  (interactive)
X  (and (car args) (listp (car args)) (setq args (car args)))
X  (smart-key-set-point args)
X  (setq *smart-key-meta-depressed* args
X	*smart-key-window* (selected-window)
X	*smart-key-modeline-window*
X	(if *smart-key-window* nil (selected-window)))
X  (if *smart-key-depressed*
X      (smart-key-help nil)))
X
(defun sm-lemacs-move-point ()
X  (mouse-set-point current-mouse-event))
X
(defun sm-sun-move-point (arg-list)
X  (apply 'mouse-move-point arg-list))
X
;;; ************************************************************************
;;; Private variables
;;; ************************************************************************
X
(defvar sm-mouse-bindings nil
X  "List of (key . binding) pairs for Smart Mouse Keys.")
X
(defvar sm-mouse-bindings-p nil
X  "True if Smart Key mouse bindings are in use, else nil.")
X
(defvar sm-mouse-previous-bindings nil
X  "List of previous (key . binding) pairs for mouse keys used as Smart Keys.")
X
(provide 'hmouse-key)
SHAR_EOF
chmod 0644 hmouse-key.el ||
echo 'restore of hmouse-key.el failed'
Wc_c="`wc -c < 'hmouse-key.el'`"
test 11171 -eq "$Wc_c" ||
	echo 'hmouse-key.el: original size 11171, current size' "$Wc_c"
fi
# ============= hui-menus.el ==============
if test -f 'hui-menus.el' -a X"$1" != X"-c"; then
	echo 'x - skipping hui-menus.el (File already exists)'
else
echo 'x - extracting hui-menus.el (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'hui-menus.el' &&
;;!emacs
;; $Id: hui-menus.el,v 1.2 1992/05/14 10:12:25 rsw Exp $
;;
;; FILE:         hui-menus.el
;; SUMMARY:      One line command menus for Hyperbole
;; USAGE:        GNU Emacs Lisp Library
;;
;; AUTHOR:       Bob Weiner
;; ORG:          Brown U.
;;
;; ORIG-DATE:    15-Oct-91 at 20:13:17
;; LAST-MOD:     25-Feb-92 at 06:08:14 by Bob Weiner
;;
;; This file is part of Hyperbole.
;; 
;; Copyright (C) 1991, 1992  Brown University, Providence, RI
;; Developed with support from Motorola Inc.
;; 
;; Permission to use, modify and redistribute this software and its
;; documentation for any purpose other than its incorporation into a
;; commercial product is hereby granted without fee.  A distribution fee
;; may be charged with any redistribution.  Any distribution requires
;; that the above copyright notice appear in all copies, that both that
;; copyright notice and this permission notice appear in supporting
;; documentation, and that neither the name of Brown University nor the
;; author's name be used in advertising or publicity pertaining to
;; distribution of the software without specific, written prior permission.
;; 
;; Brown University makes no representations about the suitability of this
;; software for any purpose.  It is provided "as is" without express or
;; implied warranty.
;;
;;
;; DESCRIPTION:  
;; DESCRIP-END.
X
;;; ************************************************************************
;;; Other required Elisp libraries
;;; ************************************************************************
X
(require 'hui)
X
;;; ************************************************************************
;;; Public variables
;;; ************************************************************************
X
(defvar hui:menu-select "\C-m"
X  "*Upper case char-string which select Hyperbole menu item at point.")
(defvar hui:menu-quit   "Q"
X  "*Upper case char-string which quits from selecting a Hyperbole menu item.")
(defvar hui:menu-abort  "\C-g"
X  "*Same function as 'hui:menu-quit'.")
(defvar hui:menu-top    "\C-t"
X  "*Character which returns to top Hyperbole menu.")
X
(defvar hui:menu-p nil
X  "Non-nil iff a current Hyperbole menu activation exists.")
X
(defvar hui:menus nil
X  "Command menus for use with the default Hyperbole user interface.")
(setq
X hui:menus
X (list (cons
X	'hyperbole
X	(append
X	 (list (list (concat "Hypb" hyperb:version ">")))
X	 '(("Act"         hui:hbut-act
X	    "Activates button at point or prompts for explicit button.")
X	   ("ButFile/"    (menu . butfile)
X	    "Quick access button files menus.")
X	   ("Doc/"        (menu . doc)
X	    "Quick access to Hyperbole documentation.")
X	   ("EBut/"       (menu . ebut)
X	    "Explicit button commands.")
X	   ("GBut/"       (menu . gbut)
X	    "Global button commands.")
X	   ("Hist"        (hhist:remove current-prefix-arg)
X	    "Jumps back to location prior to last Hyperbole button follow.")
X	   ("IBut/"       (menu . ibut)
X	    "Implicit button and button type commands.")
X	   ("Msg/"        (menu . msg)
X	    "Mail and News messaging facilities.")
X	   ("Rolo/"       (progn (or (fboundp 'rolo-kill) (require 'wrolo))
X				 (hui:menu-act 'rolo))
X	    "Hierarchical, multi-file rolodex lookup and edit commands.")
X	   ("Types/"      (menu . types)
X	    "Provides documentation on Hyperbole types.")
X	   )))
X       '(butfile .
X	 (("ButFile>")
X	  ("DirFile"      (find-file hbmap:filename)
X	   "Edits directory-specific button file.")
X	  ("PersonalFile" (find-file (concat hbmap:dir-user hbmap:filename))
X	   "Edits user-specific button file.")
X	  ))
X       '(doc .
X	 (("Doc>")
X	  ("Demo"         (find-file-read-only (concat hyperb:dir "DEMO"))
X	   "Demonstrates Hyperbole features.")
X	  ("Files"        (find-file (concat hyperb:dir "MANIFEST"))
X	   "Summarizes Hyperbole system files.  Click on an entry to view it.")
X	  ("Glossary"     (progn
X			    (or (featurep 'info)
X				(progn (load "info") (provide 'info)))
X			    (hact 'link-to-Info-node "(hypb.info)Glossary"))
X	   "Glossary of Hyperbole terms.")
X	  ("HypbCopy"  (hact 'link-to-string-match "* Copyright" 2
X			     (concat hyperb:dir "README"))
X	   "Displays general Hyperbole copyright and license details.")
X	  ("InfoManual"   (progn (or (featurep 'info)
X				     (progn (load "info") (provide 'info)))
X				 (hact 'link-to-Info-node "(hypb.info)"))
X	   "Online Info version of Hyperbole manual.")
X	  ("MailLists"    (hact 'link-to-string-match "* Mail Lists" 2
X			     (concat hyperb:dir "README"))
X	   "Details on Hyperbole mail list subscriptions.")
X	  ("New"          (hact 'link-to-string-match "* What's New" 2
X			     (concat hyperb:dir "README"))
X	   "Recent changes to Hyperbole.")
X	  ("SmartKy"      (find-file (concat hyperb:dir "hmouse-doc"))
X	   "Summarizes Smart Key mouse or keyboard handling.")
X	 ))
X       '(ebut .
X	 (("EButton>")
X	  ("Act"    hui:hbut-act
X	    "Activates button at point or prompts for explicit button.")
X	  ("Create" hui:ebut-create)
X	  ("Delete" hui:ebut-delete)
X	  ("Edit"   hui:ebut-modify "Modifies any desired button attributes.")
X	  ("Help/"  (menu . ebut-help) "Summarizes button attributes.")
X	  ("Modify" hui:ebut-modify "Modifies any desired button attributes.")
X	  ("Rename" hui:ebut-rename "Relabels an explicit button.")
X	  ("Search" hui:ebut-search
X	   "Locates and displays personally created buttons in context.")
X	  ))
X       '(ebut-help .
X	 (("Help on>")
X	  ("BufferButs"   (hui:hbut-report -1)
X	   "Summarizes all explicit buttons in buffer.")
X	  ("CurrentBut"   (hui:hbut-report)
X	   "Summarizes only current button in buffer.")
X	  ("OrderedButs"  (hui:hbut-report 1)
X	   "Summarizes explicit buttons in lexicographically order.")
X	  ))
X       '(gbut .
X	 (("GButton>")
X	  ("Act"    gbut:act        "Activates global button by name.") 
X	  ("Create" hui:gbut-create "Adds a global button to gbut:file.")
X	  ("Help"   gbut:help       "Reports on a global button by name.") 
X	  ))
X       '(ibut .
X	 (("IButton>")
X	  ("Act"    hui:hbut-act    "Activates implicit button at point.") 
X	  ("Help"   hui:hbut-help   "Reports on button's attributes.")
X	  ("Types"  (hui:htype-help 'ibtypes 'no-sort)
X	   "Displays documentation for one or all implicit button types.")
X	  ))
X       '(msg .
X	 (("Msg>")
X	  ("Compose-Hypb-Mail"
X	   (progn
X	     (mail) (insert "hyperbole@cs.brown.edu")
X	     (forward-line 1) (end-of-line)
X	     (save-excursion
X	       (insert
X		"Use a full *sentence* here.  Make a statement or ask a question."))
X	     (hact 'hyp-config)
X	     (message "Edit and then mail."))
X	   "Send a message to the Hyperbole discussion list.")
X	  ("Edit-Hypb-Mail-List-Entry"
X	   (progn (mail) (insert "hyperbole-request@cs.brown.edu")
X		  (forward-line 1) (end-of-line)
X		  (hact 'hyp-request)
X		  (message "Edit and then mail."))
X	   "Add, remove or change your entry on a hyperbole mail list.")
X	  ))
X       '(rolo .
X	 (("Rolo>")
X	  ("Add"              rolo-add	  "Add a new rolo entry.")
X	  ("Display-again"    rolo-display-matches
X	   "Display last found rolodex matches again.")
X	  ("Edit"             rolo-edit   "Edit an existing rolo entry.")
X	  ("Kill"             rolo-kill   "Kill an existing rolo entry.")
X	  ("Order"            rolo-sort   "Order rolo entries in a file.")
X	  ("Regexp-find"      rolo-grep   "Find entries containing a regexp.")
X	  ("String-find"      rolo-fgrep  "Find entries containing a string.")
X	  ("Yank"             rolo-yank
X	   "Find an entry containing a string and insert it at point.")
X	  ))
X       '(types .
X	 (("Types>")
X	  ("ActionTypes"      (hui:htype-help   'actypes)
X	   "Displays documentation for one or all action types.")
X	  ("DeleteIButType"   (hui:htype-delete 'ibtypes)
X	   "Deletes specified button type.")
X	  ("IButTypes"        (hui:htype-help   'ibtypes 'no-sort)
X	   "Displays documentation for one or all implicit button types.")
X	  ))
X       ))
X
;;; ************************************************************************
;;; Public functions
;;; ************************************************************************
X
(defun hui:menu ()
X  "Invokes default Hyperbole menu user interface when not already active.
Suitable for binding to a key, e.g. {C-h h}.
Non-interactively, returns t if menu is actually invoked by call, else nil."
X  (interactive)
X  (condition-case ()
X      (if (and hui:menu-p (> (minibuffer-depth) 0))
X	  nil
X	(setq hui:menu-p t)
X	(hui:menu-act 'hyperbole)
X	(setq hui:menu-p nil)
X	t)
X    (quit (setq hui:menu-p nil))
X    (error (setq hui:menu-p nil))))
X
(defun hui:menu-act (menu)
X  "Prompts user with Hyperbole MENU (a symbol) and performs selected item."
X  (let ((set-menu '(or (and menu (symbolp menu)
X			    (setq menu-alist (cdr (assq menu hui:menus))))
X		       (error "(hui:menu-act): Invalid menu symbol arg: %s"
X			      menu)))
X	(show-menu t)
X	(rtn)
X	menu-alist act-form)
X    (while (and show-menu (eval set-menu))
X      (cond ((and (consp (setq act-form (hui:menu-select menu-alist)))
X		  (cdr act-form)
X		  (symbolp (cdr act-form)))
X	     ;; Display another menu
X	     (setq menu (cdr act-form)))
X	    (act-form
X	     (let ((prefix-arg current-prefix-arg))
X	       (cond ((symbolp act-form)
X		      (if (eq act-form t)
X			  nil
X			(setq show-menu nil
X			      rtn (call-interactively act-form))))
X		     ((stringp act-form)
X		      (hui:menu-help act-form)
X		      ;; Loop and show menu again.
X		      )
X		     (t (setq show-menu nil
X			      rtn (eval act-form))))))
X	    (t (setq show-menu nil))))
X    rtn))
X
(defun hui:menu-enter (&optional char-str)
X  "Uses CHAR-STR or last input character as minibuffer argument."
X  (interactive)
X  (erase-buffer)
X  (let ((input (or char-str (aref (recent-keys) (1- (length (recent-keys)))))))
X    (insert 
X     (if (and hyperb:lemacs-p (eventp input))
X	 (event-to-character input)
X       input)))
X  (exit-minibuffer))
X
(defun hui:menu-help (help-str)
X  "Displays HELP-STR in a small window.  HELP-STR must be a string."
X  (let* ((window-min-height 2)
X	 (owind (selected-window))
X	 (buf-name (hypb:help-buf-name "Menu")))
X    (unwind-protect
X	(progn
X	  (save-window-excursion
X	    (smart-key-help-show buf-name)) ;; Needed to save screen config.
X	  (if (eq (selected-window) (minibuffer-window))
X	      (other-window 1))
X	  (if (= (length (hypb:window-list 'no-mini)) 1)
X	      (split-window-vertically nil))
X	  (let* ((winds (hypb:window-list 'no-mini))
X		 (bot-list (mapcar
X			    '(lambda (wind)
X			       (nth 3 (window-edges wind))) winds))
X		 (bot (apply 'max bot-list)))
X	    (select-window
X	     (nth (- (length winds) (length (memq bot bot-list))) winds)))
X	  (switch-to-buffer (get-buffer-create buf-name))
X	  (setq buffer-read-only nil)
X	  (erase-buffer)
X	  (insert "\n" help-str)
X	  (set-buffer-modified-p nil)
X	  (shrink-window
X	   (- (window-height)
X	      (+ 3 (length
X		    (delq nil
X			  (mapcar '(lambda (chr) (= chr ?\n)) help-str)))))))
X      (select-window owind))))
X
(defun hui:menu-select (menu-alist)
X  "Prompts user to choose the first character of any item from MENU-ALIST.
Case is not significant.  If chosen by direct selection with the secondary
Smart Key, returns any help string for item, else returns the action form for
the item."
X  (let* ((menu-prompt (concat (car (car menu-alist)) "  "))
X	 (menu-items (mapconcat 'car (cdr menu-alist) "  "))
X	 (set:equal-op 'eq)
X	 (select-char (string-to-char hui:menu-select))
X	 (quit-char (string-to-char hui:menu-quit))
X	 (abort-char (string-to-char hui:menu-abort))
X	 (top-char  (string-to-char hui:menu-top))
X	 (item-keys (mapcar '(lambda (item) (aref item 0))
X			    (mapcar 'car (cdr menu-alist))))
X	 (keys (apply 'list select-char quit-char abort-char
X		      top-char item-keys))
X	 (key 0)
X	 (hargs:reading-p 'hmenu)
X	 sublist)
X    (while (not (memq (setq key (upcase
X				 (string-to-char
X				  (read-from-minibuffer
X				   "" (concat menu-prompt menu-items)
X				   hui:menu-mode-map))))
X		      keys))
X      (beep)
X      (setq hargs:reading-p 'hmenu)
X      (discard-input))
X    (cond ((eq key quit-char) nil)
X	  ((eq key abort-char) (beep) nil)
X	  ((eq key top-char) '(menu . hyperbole))
X	  ((and (eq key select-char)
X		(save-excursion
X		  (if (search-backward " " nil t)
X		      (progn (skip-chars-forward " ")
X			     (setq key (following-char))
X			     nil)  ;; Drop through.
X		    t))))
X	  (t (if (setq sublist (memq key item-keys))
X		 (let* ((label-act-help-list
X			 (nth (- (1+ (length item-keys)) (length sublist))
X			      menu-alist))
X			(act-form (car (cdr label-act-help-list))))
X		   (if (eq hargs:reading-p 'hmenu-help)
X		       (let ((help-str
X			      (or (car (cdr (cdr label-act-help-list)))
X				  "No help documentation for this item.")))
X			 (concat (car label-act-help-list) "\n  "
X				 help-str "\n    Action: "
X				 (prin1-to-string act-form)))
X		     act-form)))))))
X
;;; ************************************************************************
;;; Private variables
;;; ************************************************************************
X
;; Hyperbole menu mode is suitable only for specially formatted data.
(put 'hui:menu-mode 'mode-class 'special)
X
(defvar hui:menu-mode-map nil
X  "Keymap containing hui:menu commands.")
(if hui:menu-mode-map
X    nil
X  (setq hui:menu-mode-map (make-keymap))
X  (suppress-keymap hui:menu-mode-map)
X  (define-key hui:menu-mode-map hui:menu-quit   'hui:menu-enter)
X  (define-key hui:menu-mode-map hui:menu-abort  'hui:menu-enter)
X  (define-key hui:menu-mode-map hui:menu-top    'hui:menu-enter)
X  (define-key hui:menu-mode-map hui:menu-select 'hui:menu-enter)
X  (let ((i 32))
X    (while (<= i 126)
X      (define-key hui:menu-mode-map (char-to-string i) 'hui:menu-enter)
X      (setq i (1+ i)))))
X
(provide 'hui-menus)
SHAR_EOF
chmod 0644 hui-menus.el ||
echo 'restore of hui-menus.el failed'
Wc_c="`wc -c < 'hui-menus.el'`"
test 13603 -eq "$Wc_c" ||
	echo 'hui-menus.el: original size 13603, current size' "$Wc_c"
fi
# ============= hsite-ex.el ==============
if test -f 'hsite-ex.el' -a X"$1" != X"-c"; then
	echo 'x - skipping hsite-ex.el (File already exists)'
else
echo 'x - extracting hsite-ex.el (Text)'
sed 's/^X//' << 'SHAR_EOF' > 'hsite-ex.el' &&
;;!emacs
;; $Id: hsite-ex.el,v 1.2 1992/05/14 10:11:45 rsw Exp $
;;
;; FILE:         hsite.el
;; SUMMARY:      Site-specific setup for Hyperbole
;; USAGE:        GNU Emacs Lisp Library
;;
;; AUTHOR:       Bob Weiner
;; ORG:          Brown U.
;;
;; ORIG-DATE:    15-Apr-91 at 00:48:49
;; LAST-MOD:     24-Feb-92 at 17:15:30 by Bob Weiner
;;
;; This file is part of Hyperbole.
;; 
;; Copyright (C) 1991, Brown University, Providence, RI
;; Developed with support from Motorola Inc.
;; 
;; Permission to use, modify and redistribute this software and its
;; documentation for any purpose other than its incorporation into a
;; commercial product is hereby granted without fee.  A distribution fee
;; may be charged with any redistribution.  Any distribution requires
;; that the above copyright notice appear in all copies, that both that
;; copyright notice and this permission notice appear in supporting
;; documentation, and that neither the name of Brown University nor the
;; author's name be used in advertising or publicity pertaining to
;; distribution of the software without specific, written prior permission.
;; 
;; Brown University makes no representations about the suitability of this
;; software for any purpose.  It is provided "as is" without express or
;; implied warranty.
;;
;;
;; DESCRIPTION:  
;;
;;   COPY hsite-ex.el TO hsite.el AND THEN MODIFY AS DESIRED.
;;   A line of the form:
;;
;;      (load "<HYP-DIR>/hsite")
;;
;;   in your .emacs file will then initialize Hyperbole whenever you
;;   start up.  Substitute your chosen path for <HYP-DIR>.
;;
;;   Be sure to have users load any personal mail/news initializations
;;   before they load this file if any of Hyperbole's mail or news
;;   support features are enabled herein or within their personal
;;   Hyperbole initializations.  Otherwise, the mail/news support may
;;   not be configured properly.
;;
;; DESCRIP-END.
X
;; ************************************************************************
;; Suggestions of what to include here.
;; Comment out and uncomment lines as desired.
;; ************************************************************************
X
(message "Initializing Hyperbole...")
X
;;; Choose a key on which to place the Hyperbole menus.
;;; For most people this key binding will work and will be equivalent
;;; to {C-h h}.
;;;
(define-key help-map "h" 'hui:menu)
X
;;; Uncomment or select a key if you want a site standard way of
;;; performing explicit button renames without invoking the Hyperbole
;;; menu.
;; (global-set-key "\C-c\C-r" 'hui:ebut-rename)
X
;;; Uncomment this and choose a key binding, e.g. {C-c t}, if you want a
;;; site standard way to easily switch between the Smart Key mouse
;;; bindings and a set of personal mouse bindings.  You may instead show
;;; users how to bind this to a key via 'hyperb:init-hook' (see
;;; Hyperbole Manual).
;;;
;; (global-set-key "<KEY-BINDING>" 'sm-mouse-toggle-bindings)
X
;;; A value of t for 'smart-key-init' below will cause the Smart Keys to be
;;; bound to keyboard keys in addition to any mouse key bindings.
;;; Comment it out or set it to nil if you don't want these bindings.  Or
;;; change the bindings in the succeeding lines.
;;;
(or (boundp 'smart-key-init) (setq smart-key-init t))
(and (boundp 'smart-key-init) smart-key-init
X     (global-set-key
X      "\M-\C-m"
X      '(lambda (arg)
X	 (interactive "P")
X	 (funcall (if arg 'smart-key 'smart-key-meta)))))
;;;
;;; Smart Key bindings for many non-edit modes.
(defvar smart-key-read-only "\C-m"
X  "Local Smart Key binding for special read-only modes.")
(defvar smart-key-meta-read-only "\M-\C-m"
X  "Local secondary Smart Key binding for special read-only modes.")
X
;;; Substitute the directory in which you stored the Hyperbole code
;;; for <HYP-DIR> below.
;;;
(if (boundp 'hyperb:dir)
X    nil
X  (defconst hyperb:dir (file-name-as-directory "<HYP-DIR>")
X    "Directory where Hyperbole code and doc files are kept."))
(let (newpath)
X  (or (featurep 'set) (load (concat hyperb:dir "set")))
X  (if (setq newpath (set:add hyperb:dir load-path))
X      (setq load-path newpath)))
X
;;; Support button highlighting and flashing under Epoch.
;;;
(defvar hyperb:epoch-p
X  (if (boundp 'epoch::version)
X      (if (string< epoch::version "Epoch 4") "V3" "V4"))
X  "Simplified Epoch version string, e.g. \"V4\", else nil.")
X
(if hyperb:epoch-p
X    (progn
X      (cond ((string< hyperb:epoch-p "V4") (require 'hui-epV3-b))
X	    (t (require 'hui-epV4-b)))
X      (fset 'hui:but-flash 'ep:but-flash)
X      ;; This color cycling really must be done until a desired color is hit.
X      ;; See the hui-epV* files for how this works.
X      (ep:cycle-but-color)
X      ;; If you use Epoch and find that the Hyperbole button flash time is
X      ;; too slow or too fast, adjust it here.
X      (defvar ep:but-flash-time 1000
X	"Machine specific val for empty loop counter, Epoch but flash delay.")
X      )
X  (defun hui:but-flash ())
X  )
X
;;; Support button highlighting and flashing under Lucid Emacs.
;;;
(defvar hyperb:lemacs-p
X  (let ((case-fold-search t))
X    (if (string-match "Lucid" emacs-version)
X	emacs-version))
X  "Simplified Lucid Emacs version string, e.g. \"V4\", else nil.")
X
(if hyperb:lemacs-p
X    (progn
X      (require 'hui-le-but)
X      (fset 'hui:but-flash 'le:but-flash)
X      ;; This color cycling really must be done until a desired color is hit.
X      ;; See hui-le-but.el for how this works.
X      (le:cycle-but-color)
X      ;; If you find that the Hyperbole button flash time is too slow
X      ;; or too fast, adjust it here.
X      (defvar le:but-flash-time 1000
X	"Machine specific val for empty loop counter, Lucid Emacs but flash delay.")
X      )
X  (defun hui:but-flash ())
X  )
X
;;; You may want to look at this file just to see what it does.
;;;
(require 'hinit)
;;;
;;; This call initializes the whole Hyperbole system.
(hyperb:init)
X
;;; Even if you don't need some of the following hook settings, you might
;;; as well leave them in so that if they ever become useful to you, you
;;; need not reconfigure Hyperbole.  These settings do nothing if the
;;; corresponding subsystems are never invoked.
;;;
;;; GNUS USENET news reader/poster support.
;;;
(var:append 'gnus-Startup-hook '(Gnus-init))
;;;
;;; Hyperbole mail reader support configuration.
;;;
(var:append 'rmail-mode-hook    '(Rmail-init))
(var:append 'mh-inc-folder-hook '(Mh-init))
(var:append 'vm-mode-hooks      '(Vm-init))
(var:append 'pm-hook            '(Pm-init))
X
;;; Enables Smart Key mouse setup.
(sm-mouse-setup)
X
;;; Permits restore of screen configuration after any help buffer is shown
;;; by pressing either Smart Key at the end of the help buffer.  (Help buffer
;;; names end with "Help*".
;;;
(setq temp-buffer-show-hook 'smart-key-help-show)
X
;;; This may be removed if Hyperbole variables are never used in file local
;;; variable lists or if it causes a conflict with any local variable lists you
;;; use.  See the source file for more details.
;;;
(require 'hlvar)
X
;;; Support for encapsulations of any of these external systems may be
;;; enabled here.  You should be familiar with the external system before
;;; you try to use the Hyperbole support for it.
;;;
;(require 'hsys-hbase)
;(require 'hsys-wais)
;(require 'hsys-www)
X
(provide 'hsite)
X
(message "Hyperbole is ready for action.")
SHAR_EOF
chmod 0644 hsite-ex.el ||
echo 'restore of hsite-ex.el failed'
Wc_c="`wc -c < 'hsite-ex.el'`"
test 7288 -eq "$Wc_c" ||
	echo 'hsite-ex.el: original size 7288, current size' "$Wc_c"
fi
exit 0


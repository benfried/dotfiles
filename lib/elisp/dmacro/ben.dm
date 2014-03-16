# ALIAS: dm       ((month-num) :pad ?0)
# ALIAS: dd       ((chron) 8 10 :pad ?0)
# ALIAS: dy       ((chron) 22)
# ALIAS: initials ((user-initials) :down)

########################################

today		expand	today
~dm/~dd/~dy
#

copyright		expand	copyright
Copyright (c) ~(year) Morgan Stanley Dean Witter & Co. Inc., All Rights Reserved
#

perl-header	expand	perl-header
\#!/ms/dist/perl5/bin/perl
#

ksh-header	expand	ksh-header
\#!/bin/ksh
#

########################################

#
# MODE: c-mode
#

##########
ctemplate	expand	C source template
/*****************************************************************************
 *
 * ~(dmacro copyright)
 *
 * Unpublished copyright. All rights reserved. This material contains
 * proprietary information that shall be used or copied only within Morgan
 * Stanley Dean Witter, except with written permission of Morgan Stanley
 * Dean Witter.
 *
 *****************************************************************************/

/* static char *rcsID = "$Header$"; */

~@

#

##########
htemplate	expand	C header template
#ifndef ~((file-name) :up)_H
#define ~((file-name) :up)_H

/*****************************************************************************
 *
 * ~(dmacro copyright)
 *
 * Unpublished copyright. All rights reserved. This material contains
 * proprietary information that shall be used or copied only within Morgan
 * Stanley Dean Witter, except with written permission of Morgan Stanley
 * Dean Witter.
 *
 *****************************************************************************/

/* static char *rcsID = "$Header$"; */

~@

#endif /* ~((file-name) :up)_H */

#

########################################

#
# MODE: c++-mode
#

##########
cctemplate	expand	C++ source template
///////////////////////////////////////////////////////////////////////////////
//
// ~(dmacro copyright)
//
// Unpublished copyright. All rights reserved. This material contains
// proprietary information that shall be used or copied only within
// Morgan Stanley Dean Witter, except with written permission of Morgan
// Stanley Dean Witter.
//
///////////////////////////////////////////////////////////////////////////////

// static const char *rcsID = "$Header$";

~@
#

##########
hhtemplate	expand	C++ header template
#ifndef ~((file-name) :up)_H
#define ~((file-name) :up)_H

///////////////////////////////////////////////////////////////////////////////
//
// ~(dmacro copyright)
//
// Unpublished copyright. All rights reserved. This material contains
// proprietary information that shall be used or copied only within
// Morgan Stanley Dean Witter, except with written permission of Morgan
// Stanley Dean Witter.
//
///////////////////////////////////////////////////////////////////////////////

// static const char *rcsID = "$Header$";

~@

#endif // ~((file-name) :up)_H

#

##########
class		indent	class declaration
//
// ~(mark)
//
class ~(prompt name "Class name: ")~(prompt base "Base class: " dmik-prompter ": public %s") {

public:
    ~(prompt name)(void);
    virtual ~~~(prompt name)(void);
~@
}; // class ~(prompt name)

#


##########
static-cast	indent	static cast
static_cast<~(prompt type "Type: ")>(~@)
#
##########
dynamic-cast	indent	dynamic cast
dynamic_cast<~(prompt type "Type: ")>(~@)
#

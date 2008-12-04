####################################################################
# Distribution Makefile
####################################################################

.PHONY: configure install clean

all: configure

#
# BTDIR needs to point to the location of the build tools
#
BTDIR := ../quattor-build-tools
#
#
_btincl   := $(shell ls $(BTDIR)/quattor-buildtools.mk 2>/dev/null || \
             echo quattor-buildtools.mk)
include $(_btincl)


####################################################################
# Configure
####################################################################

configure: $(COMP) 


####################################################################
# Install
####################################################################

install: configure man
	@echo installing ...
	@mkdir -p $(PREFIX)/$(QTTR_BIN)
	@mkdir -p $(PREFIX)/$(QTTR_MAN)/man$(MANSECT)
	@mkdir -p $(PREFIX)/$(QTTR_DOC)

	@install -m 0755 $(COMP) $(PREFIX)/$(QTTR_BIN)/$(COMP)

	@install -m 0444 $(COMP).$(MANSECT).gz \
	                 $(PREFIX)$(QTTR_MAN)/man$(MANSECT)/$(COMP).$(MANSECT).gz
	@for i in LICENSE MAINTAINER ChangeLog README ; do \
		install -m 0444 $$i $(PREFIX)/$(QTTR_DOC)/$$i ; \
	done


man: configure
	@pod2man $(_podopt) $(COMP) >$(COMP).$(MANSECT)
	@gzip -f $(COMP).$(MANSECT)

####################################################################


clean::
	@echo cleaning $(NAME) files ...
	@rm -f $(COMP) $(COMP).pod $(NAME).$(NCM_MANSECT) Component.
	@rm -rf TEST



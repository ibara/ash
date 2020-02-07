#	$NetBSD: Makefile,v 1.115 2018/10/28 18:13:47 kre Exp $
#	@(#)Makefile	8.4 (Berkeley) 5/5/95

.include <bsd.own.mk>

PROG=	ash
SHSRCS=	alias.c arith_token.c arithmetic.c cd.c echo.c error.c eval.c exec.c \
	expand.c histedit.c input.c jobs.c mail.c main.c memalloc.c \
	miscbltin.c mystring.c options.c parser.c redir.c show.c trap.c \
	output.c var.c test.c kill.c syntax.c
GENSRCS=builtins.c init.c nodes.c
GENHDRS=builtins.h nodes.h token.h nodenames.h optinit.h
SRCS=	${SHSRCS} ${GENSRCS}
BUILDFIRST=${GENHDRS} ${GENSRCS}

DPSRCS+=${GENHDRS}

LDADD+=	-ledit -ltermcap
DPADD+=	${LIBEDIT} ${LIBTERMCAP}

# Environment for scripts executed during build.
SCRIPT_ENV= \
	AWK=/usr/bin/awk \
	MKTEMP=/usr/bin/mktemp \
	SED=/usr/bin/sed

CPPFLAGS+=-DSHELL -I. -I${.CURDIR}
CPPFLAGS+= -DUSE_LRAND48
CPPFLAGS+=-D__RCSID\(x\)= -D__printflike\(x,y\)= -D__COPYRIGHT\(x\)=
#XXX: For testing only.
#CPPFLAGS+=-DDEBUG=1
#COPTS+=-g
#CFLAGS+=-funsigned-char
#TARGET_CHARFLAG?= -DTARGET_CHAR="unsigned char" -funsigned-char

.ifdef SMALLPROG
CPPFLAGS+=-DSMALL
.endif
.ifdef TINYPROG
CPPFLAGS+=-DTINY
.else
SRCS+=printf.c
.endif

.PATH:	${.CURDIR}/bltin

CLEANFILES+= ${GENSRCS} ${GENHDRS} sh.html1
CLEANFILES+= trace.*

token.h: mktokens
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC}

.ORDER: builtins.h builtins.c
builtins.h builtins.c: mkbuiltins shell.h builtins.def
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} ${.OBJDIR}
	[ -f builtins.h ]

init.c: mkinit.sh ${SHSRCS}
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC}

.ORDER: nodes.h nodes.c
nodes.c nodes.h: mknodes.sh nodetypes nodes.c.pat
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} ${.OBJDIR}
	[ -f nodes.h ]

nodenames.h: mknodenames.sh nodes.h
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} > ${.TARGET}

optinit.h: mkoptions.sh option.list
	${SCRIPT_ENV} ${HOST_SH} ${.ALLSRC} ${.TARGET} ${.OBJDIR}

SUBDIR.roff+=USD.doc

COPTS.printf.c = -Wno-format-nonliteral
COPTS.jobs.c = -Wno-format-nonliteral
COPTS.var.c = -Wno-format-nonliteral

.include <bsd.prog.mk>
.include <bsd.subdir.mk>

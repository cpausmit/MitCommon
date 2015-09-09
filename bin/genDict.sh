#!/bin/bash

check-update () {
  local DEPENDANT=$1
  local SOURCES="$@"

  local UPDATED=false
    
  if ! [ -e $DEPENDANT ]
  then
    UPDATED=true
  else
    LASTUPDATE=$(stat -c %Z $DEPENDANT)
    local SOURCE
      
    for SOURCE in $SOURCES
    do
      if ! [ -e $SOURCE ]
      then
        echo "$SOURCE does not exist"
        exit 1
      fi
      
      if [ $LASTUPDATE -lt $(stat -c %Z $SOURCE) ]
      then
        UPDATED=true
        break
      fi
    done
  fi

  echo $UPDATED
}

usage () {
  echo "Usage: genDict.sh [-c] [-f] PACKAGES"
  echo "Generate ROOT dictionary source code. PACKAGE is e.g. MitAna/DataTree."
  echo ""
  echo "  -c  Clear generated source code."
  echo "  -f  Force generation. Otherwise dictionaries are written only if"
  echo "      header files are updated."

  exit $1
}


FORCE=false
CLEAR=false
while getopts fch OPT; do
  case $OPT in
    c)
      CLEAR=true
      ;;
    f)
      FORCE=true
      ;;
    h)
      usage 0
      ;;
    \?)
      echo " Invalid option: -$OPTARG" >& 2
      usage 1
      ;;
  esac
done

shift $((OPTIND-1))

if ! [ $CMSSW_BASE ] || ! [ $SCRAM_ARCH ]
then
  echo "CMSSW_BASE and SCRAM_ARCH must be set."
  exit 1
fi

PACKAGES="$@"

if ! [ "$PACKAGES" ]
then
  for DIR in $(ls $CMSSW_BASE/src)
  do
    for SUBDIR in $(ls $CMSSW_BASE/src/$DIR)
    do
      [ -d $CMSSW_BASE/src/$DIR/$SUBDIR/dict ] && PACKAGES="$PACKAGES $DIR/$SUBDIR"
    done
  done
fi

if $CLEAR
then
  echo "Clearing ROOT dictionaries in:"
else
  echo "Generating ROOT dictionaries for:"
fi
echo " $PACKAGES"

TMPDIR=$CMSSW_BASE/tmp/$SCRAM_ARCH

cd $CMSSW_BASE/src

for PACKAGE in $PACKAGES
do
  DICTDIR=$PACKAGE/dict
  SRCDIR=$PACKAGE/src
  INCDIR=$PACKAGE/interface

  if ! [ -d $DICTDIR ] || ! [ -d $SRCDIR ] || ! [ -d $INCDIR ]
  then
    echo "$PACKAGE does not appear to be a valid package."
    continue
  fi

  LIBDIR=$CMSSW_BASE/lib/$SCRAM_ARCH
  [ -d $LIBDIR ] || mkdir $LIBDIR

  # parse the BuildFile to find additional include directories
  INCDIRS="-I$CMSSW_BASE/src"
  DEPS=$(sed -n 's|<use  *name="\([^/]*\)"/>|\1|p' $PACKAGE/BuildFile.xml)
  for DEP in $DEPS
  do
    CONFIG=$CMSSW_BASE/config/toolbox/$SCRAM_ARCH/tools/selected/$DEP.xml
    [ -e $CONFIG ] || continue
    #read off all variables defined in xml
    #everything placed within a subshell to avoid exporting uncontrollable environments
    THISINCLUDE=$(eval $(sed -n 's|^ *<environment  *name="\(.*\)"  *default="\(.*\)"/>.*$|\1=\2|p' $CONFIG); echo $INCLUDE)
    [ $THISINCLUDE ] && INCDIRS="$INCDIRS -I$THISINCLUDE"
  done

  for LINKDEF in $(ls $DICTDIR/*LinkDef.h); do
    # the name of the dictionary code file generated from ABCLinkDef.h will be ABC_LinkDefDict.cc
    OUTPUT=$(sed 's/LinkDef.h/_LinkDefDict/' <<< $(basename $LINKDEF))

    if $CLEAR
    then
      rm -f $SRCDIR/$OUTPUT.cc 2>/dev/null
      rm -f $LIBDIR/${OUTPUT}_rdict.pcm 2>/dev/null
    else
      INCLUDES=$(makedepend -I. -f- $LINKDEF 2>/dev/null | awk '/Mit/ {print $2}' | tr '\n' ' ')
        
      # generate dictionary if $OUTPUT.cc does not exist or is older than one of the source files
      if $FORCE || $(check-update $SRCDIR/$OUTPUT.cc $INCLUDES $LINKDEF) || ! [ -e $LIBDIR/${OUTPUT}_rdict.pcm ]
      then
        HEADERS=$(sed -n 's|#include *"\([^"]*\)"|\1|p' $LINKDEF | tr '\n' ' ')

        echo rootcling -f $TMPDIR/$OUTPUT.cc $INCDIRS $HEADERS $LINKDEF
        rootcling -f $TMPDIR/$OUTPUT.cc $INCDIRS $HEADERS $LINKDEF

        [ $? -eq 0 ] || exit 1
  
        echo mv $TMPDIR/${OUTPUT}.cc $SRCDIR/
        mv $TMPDIR/${OUTPUT}.cc $SRCDIR/
        echo mv $TMPDIR/${OUTPUT}_rdict.pcm $LIBDIR/
        mv $TMPDIR/${OUTPUT}_rdict.pcm $LIBDIR/
      fi
    fi
  done
  
  if [ -e $DICTDIR/classes_def.xml ]
  then
    # the name of the dictionary code file generated from classes_xml will be PACKAGE_ReflexDict.cc
    OUTPUT=$(sed 's|\([^/]*\)/\(.*\)|\1\2|' <<< $PACKAGE)_ReflexDict

    if $CLEAR
    then
      rm -f $SRCDIR/$OUTPUT 2>/dev/null
      rm -f $LIBDIR/$OUTPUT.rootmap 2>/dev/null
      rm -f $LIBDIR/${OUTPUT}_rdict.pcm 2>/dev/null
    else
      INCLUDES=$(makedepend -I. -f- $DICTDIR/classes.h 2>/dev/null | awk '/Mit/ {print $2}' | tr '\n' ' ')      

      if $FORCE || $(check-update $SRCDIR/$OUTPUT.cc $DICTDIR/classes_def.xml $DICTDIR/classes.h $INCLUDES) ||
              ! [ -e $LIBDIR/$OUTPUT.rootmap ] || ! [ -e $LIBDIR/${OUTPUT}_rdict.pcm ]
      then
        echo genreflex $DICTDIR/classes.h -s $DICTDIR/classes_def.xml -o $TMPDIR/$OUTPUT.cc --rootmap=$TMPDIR/$OUTPUT.rootmap -I$CMSSW_BASE/src
        genreflex $DICTDIR/classes.h -s $DICTDIR/classes_def.xml -o $TMPDIR/$OUTPUT.cc --rootmap=$TMPDIR/$OUTPUT.rootmap -I$CMSSW_BASE/src
  
        echo mv $SRCDIR/$OUTPUT.cc $SRCDIR/
        mv $SRCDIR/$OUTPUT.cc $SRCDIR/
        echo mv $TMPDIR/$OUTPUT.rootmap $LIBDIR/
        mv $TMPDIR/$OUTPUT.rootmap $LIBDIR/
        echo mv ${OUTPUT}_rdict.pcm $LIBDIR/
        mv ${OUTPUT}_rdict.pcm $LIBDIR/
      fi
    fi
  fi
done

if ! $CLEAR
then
  echo "=== genDict.sh ==="
  echo "ROOT dictionary binaries were copied to $CMSSW_BASE/lib/$SCRAM_ARCH."
  echo "Do not forget to run"
  echo '$CMSSW_BASE/src/MitCommon/bin/genDict.sh [packages]'
  echo "after next scram build clean."
  echo "=================="
  echo ""
fi

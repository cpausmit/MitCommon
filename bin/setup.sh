#!/bin/bash
#----------------------------------------------------------------------------------------------
# Setup the MitAna package adjusting things that are needed for it to compile and run properly.
#
#                                                                   Apr 17, 2015 - V1 Y. Iiyama
#----------------------------------------------------------------------------------------------

# Generate ROOT dictionaries for classes defined in this module
$CMSSW_BASE/src/MitCommon/bin/genDict.sh MitCommon/{DataFormats,MathTools,OptIO,Utils}

//--------------------------------------------------------------------------------------------------
// $Id: MathUtils.h,v 1.8 2009/05/11 08:23:06 loizides Exp $
//
// TPFuncs
//
// Function for tag-and-probe fits.
//
// Authors: C.Loizides, G.Ceballos
//--------------------------------------------------------------------------------------------------

#ifndef MITCOMMON_MATHTOOLS_TPFUNCS_H
#define MITCOMMON_MATHTOOLS_TPFUNCS_H

#include "MitCommon/DataFormats/interface/Types.h"
#include <TMath.h>

class TF1;

namespace mithep
{
  class TPFuncs {
    public:
    static Double_t  BreitGaus(Double_t x, Double_t m, Double_t mwidth, Double_t msig, 
                               Double_t fintf, Double_t xmin, Double_t xmax);
    static Double_t  BreitGaus(Double_t *x, Double_t *par);
    static Double_t  BreitWignerGamma(Double_t x, Double_t mean, Double_t gamma);
    static Double_t  BreitWignerGamma(Double_t *x, Double_t *par);
    static Double_t  BreitWignerZ(Double_t x, Double_t mean, Double_t gamma);
    static Double_t  BreitWignerZ(Double_t *x, Double_t *par);
    static Double_t  ExpRange(Double_t x, Double_t lambda, Double_t xmin, Double_t xmax);
    static Double_t  ExpRange(Double_t *x, Double_t *par);
    static Double_t  SigPlusB(Double_t *x, Double_t *par);
    static TF1      *CreateSigPlusB(Double_t norm=1, Double_t xmin=60, Double_t xmax=110,
                                    const char *n="ZSigPlusB");
  };
}
#endif

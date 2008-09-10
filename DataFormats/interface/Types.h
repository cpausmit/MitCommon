//--------------------------------------------------------------------------------------------------
// $Id: Types.h,v 1.1 2008/09/04 17:10:54 loizides Exp $
//
// Types
//
// Here we define common types.
//
// Authors: C.Loizides
//--------------------------------------------------------------------------------------------------

#ifndef MITCOMMON_DATAFORMATS_TYPES_H
#define MITCOMMON_DATAFORMATS_TYPES_H
 
#include <Rtypes.h>
#include <Math/Point3Dfwd.h>
#include <Math/GenVector/LorentzVector.h>
#include <Math/SMatrix.h>

namespace mithep
{
  typedef ROOT::Math::LorentzVector< ::ROOT::Math::PxPyPzE4D<double> > FourVector;
//typedef ::ROOT::Math::LorentzVector< ::ROOT::Math::PtEtaPhiE4D<double> > FourVectorEtaPhi;
  typedef ROOT::Math::DisplacementVector3D<ROOT::Math::Cartesian3D<double>,
                                             ROOT::Math::DefaultCoordinateSystemTag> 
                                             ThreeVector;
  typedef ROOT::Math::DisplacementVector3D<ROOT::Math::CylindricalEta3D<double>,
                                             ROOT::Math::DefaultCoordinateSystemTag> 
                                             ThreeVectorEtaPhi;
  typedef ROOT::Math::SMatrix<double,3,3,ROOT::Math::MatRepSym<double,3> >   ThreeSymMatrix;
  typedef ROOT::Math::SMatrix<double,7,7,ROOT::Math::MatRepSym<double,7> >   SevenSymMatrix;
  typedef ROOT::Math::SMatrix<double,3,3,ROOT::Math::MatRepStd<double,3,3> > ThreeMatrix;
  typedef ROOT::Math::SMatrix<double,7,7,ROOT::Math::MatRepStd<double,7,7> > SevenMatrix;
}
#endif

#!/bin/sh
# Copyright 2005-2016 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# 
# In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
# virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
#

set -x
. ./include.sh

cd ${data_dir}/bufr

#Define a common label for all the tmp files
label="bufr_dump_filter_test"

#Create log file
fLog=${label}".log"
rm -f $fLog
touch $fLog

#Define tmp bufr file
fBufrTmp=${label}".bufr.tmp"

#Define filter rules file
fRules=${label}.filter

#-----------------------------------------------------------
files="207003.bufr PraticaTemp.bufr aaen_55.bufr aben_55.bufr ahws_139.bufr airc_142.bufr airc_144.bufr airs_57.bufr alws_139.bufr
amda_144.bufr amsa_55.bufr amsb_55.bufr amse_55.bufr amsu_55.bufr amv2_87.bufr amv3_87.bufr asbh_139.bufr asbl_139.bufr
asca_139.bufr asch_139.bufr ascs_139.bufr aseh_139.bufr asel_139.bufr ashs_139.bufr atap_55.bufr ateu_155.bufr atms_201.bufr
atov_55.bufr avhm_87.bufr avhn_87.bufr avhr_58.bufr b002_95.bufr b002_96.bufr b003_56.bufr b004_145.bufr b005_87.bufr
b005_89.bufr b006_96.bufr b007_31.bufr bssh_170.bufr bssh_176.bufr bssh_178.bufr bssh_180.bufr btem_109.bufr buoy_27.bufr
cmwi_87.bufr cmwn_87.bufr cnow_28.bufr cori_156.bufr crit_202.bufr csrh_189.bufr emsg_189.bufr emsg_87.bufr euwv_87.bufr
fy3a_154.bufr fy3b_154.bufr g2nd_208.bufr g2to_206.bufr go15_87.bufr goee_87.bufr goes_87.bufr goga_89.bufr gosat.bufr
grst_26.bufr gsd1_208.bufr gsd2_208.bufr gsd3_208.bufr gst4_26.bufr hirb_55.bufr hirs_55.bufr iasi_241.bufr ifco_208.bufr
ikco_217.bufr itrg_208.bufr itwt_233.bufr j2eo_216.bufr j2nb_216.bufr jaso_214.bufr kond_209.bufr maer_207.bufr meta_140.bufr
mhen_55.bufr mhsa_55.bufr mhsb_55.bufr mhse_55.bufr mloz_206.bufr modi_87.bufr modw_87.bufr monw_87.bufr new.bufr nomi_206.bufr
nos1_208.bufr nos2_208.bufr nos3_208.bufr nos4_208.bufr nos5_208.bufr nos6_208.bufr nos7_208.bufr nos8_208.bufr ocea_131.bufr
ocea_132.bufr ocea_133.bufr ocea_21.bufr pgps_110.bufr pilo_91.bufr profiler_european.bufr rada_250.bufr rado_250.bufr s4kn_165.bufr
sb19_206.bufr sbu8_206.bufr ship_11.bufr ship_12.bufr ship_13.bufr ship_14.bufr ship_19.bufr ship_9.bufr smin_49.bufr smis_49.bufr
smiu_49.bufr smos_203.bufr sn4k_165.bufr soil_7.bufr ssbt_127.bufr stuk_7.bufr syno_1.bufr syno_2.bufr syno_3.bufr syno_4.bufr
synop_multi_subset.bufr temp_101.bufr temp_102.bufr temp_106.bufr tmr7_129.bufr tros_31.bufr uegabe.bufr wavb_134.bufr"

exclude="
airc_142.bufr  b004_145.bufr  go15_87.bufr   monw_87.bufr            ship_11.bufr  syno_1.bufr       
airc_144.bufr  b005_87.bufr   goee_87.bufr   ocea_131.bufr           ship_12.bufr  syno_2.bufr       
amda_144.bufr  b005_89.bufr   goes_87.bufr   ocea_132.bufr           ship_13.bufr  syno_3.bufr       
amv2_87.bufr   cmwi_87.bufr   goga_89.bufr   ocea_133.bufr           ship_14.bufr  syno_4.bufr       
amv3_87.bufr   cmwn_87.bufr   jaso_214.bufr  ocea_21.bufr            ship_19.bufr  temp_101.bufr     
avhm_87.bufr   emsg_189.bufr  meta_140.bufr  pilo_91.bufr            ship_9.bufr   temp_102.bufr     
avhn_87.bufr   emsg_87.bufr   modi_87.bufr   profiler_european.bufr  soil_7.bufr   temp_106.bufr     
b002_96.bufr   euwv_87.bufr   modw_87.bufr   rado_250.bufr           stuk_7.bufr   uegabe.bufr
"

for f in $files
do
  echo "Test: bufr_dump -Efilter " >> $fLog
  echo "file: $f" >> $fLog

  ${tools_dir}bufr_dump -Efilter $f > $fRules
  ${tools_dir}bufr_filter -o $fBufrTmp $fRules $f
  ${tools_dir}bufr_compare $fBufrTmp $f

  # TODO: Some need to be excluded for now
  compare_dumps=1
  for ex in $exclude; do
    if [ "$f" = "$ex" ]; then compare_dumps=0; fi
  done

  if [ $compare_dumps -eq 1 ]; then
    TEMP_JSON1=${label}.$f.json
    TEMP_JSON2=${label}.$fBufrTmp.json
    ${tools_dir}bufr_dump $f        > $TEMP_JSON1
    ${tools_dir}bufr_dump $fBufrTmp > $TEMP_JSON2
    diff $TEMP_JSON1 $TEMP_JSON2
    rm -f $TEMP_JSON1 $TEMP_JSON2
  fi

  rm -f $fBufrTmp $fRules
done

rm -f $fLog $fBufrTmp $fRules

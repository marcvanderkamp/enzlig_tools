#!/bin/bash
#### run_analysis.sh is a script to aid analysis of the MD trajectory generated by DYNAM
#### It should be run from the dynam directory
#### It calls cpptraj to generate an average structure and then calculates the RMSF to this structure
#### It calls ante-mmpbsa.py to generate the necessary topology files for MMPBSA
#### It calls MMPBSA.py to run MM-GBSA calculations on 4 snapshots from the MD trajectory
###  Usage: run_analysis.sh <pdb_file>  <ligand_name> 
Usage="Usage: run_analysis.sh <pdb_file> <ligand_name>"

if [ $# -lt 2 ]; then
   echo $Usage
   exit
fi

pdb=$1         # for consistency with prep.sh
sys=`echo $pdb | sed -e 's,\.pdb,,' -e 's,\.PDB,,'`
lig_name=$2
top=$sys.sp20.top
sys2=$sys.sp20
# Generate necessary input files
if [ ! -d include ]; then
  mkdir include
fi
for name in rmsf mmgbsa; do
   rsync -a $ENLIGHTEN/analysis/$name.i include/
   if [ ! -f include/$name.i ]; then
      echo "Can't find $name.i in include/. Cannot continue. Exiting..."
      exit
   fi
   sed -e "s/PARMFILE/$top/" -e "s/SYS/$sys2/" -e "s/LIG_NAME/$lig_name/" include/$name.i > $name.i
done

#### Check for required software ($AMBERHOME)
if [ -z $AMBERHOME ]; then
   echo "Please set \$AMBERHOME and try again. Exiting..."
   exit
elif [ ! -f $AMBERHOME/bin/pdb4amber ]; then
   echo "Cannot find pdb4amber in $AMBERHOME/bin/. Cannot continue without. Exiting..."
   exit
elif [ ! -f $AMBERHOME/bin/cpptraj ]; then
   echo "Cannot find cpptraj in $AMBERHOME/bin/. Cannot continue without. Exiting..."
   exit
elif [ ! -f $AMBERHOME/bin/ante-mmpbsa.py ]; then
   echo "Cannot find ante-mmpbsa.py in $AMBERHOME/bin/. Cannot continue without. Exiting..."
   exit
elif [ ! -f $AMBERHOME/bin/MMPBSA.py ]; then
   echo "Cannot find MMPBSA.py in $AMBERHOME/bin/. Cannot continue without. Exiting..."
   exit
elif [ ! -f $AMBERHOME/bin/sander ]; then
   echo "Cannot find sander in $AMBERHOME/bin/. Cannot continue without. Exiting..."
   exit
fi

# Begin RMSF calculation

  nice $AMBERHOME/bin/cpptraj < rmsf.i &> rmsf.out
  nice $AMBERHOME/bin/ambpdb -p ../$top -c min_$sys2.rst > min_$sys2.pdb

temp=(`grep $lig_name min_$sys2.pdb | head -n 1 | awk '{print $2}'`)
num=$(($temp - 1))
resno=(`grep $lig_name min_$sys2.pdb | head -n 1 | awk '{print $5}'`)

# Prepare PDB file with RMSF data in B-factor column

  for at in `seq 1 $num`; do fluct=`awk -v atom=$at '{if ($1==atom) print $2}' rmsf_all.dat`; awk -v bfact=$fluct -v atom=$at '{if ($1=="ATOM" && $2==atom) printf("%s%6d %s\n",substr($0,0,60),bfact*100,substr($0,68,11))}' min_$sys2.pdb ; done > rmsf_all_$sys.pdb
awk '{if ($1=="ATOM" && $5>="$resno") print}' min_$sys2.pdb  >> rmsf_all_$sys.pdb

# Generate required topology files using ante-mmpbsa.py. AMBER will not overwrite these files if they already exist.

if [ -e complex.top ] && [ -e receptor.top ] && [ -e ligand.top ] ; then
   echo "Found separate topology files for complex, receptor and ligand and will use these. (If this is NOT what you want, delete these files and run again.)"
fi
  nice $AMBERHOME/bin/ante-mmpbsa.py -p ../$top -c complex.top -s ":WAT"
  nice $AMBERHOME/bin/ante-mmpbsa.py -p complex.top -r receptor.top -l ligand.top -n ":$lig_name"
  nice $AMBERHOME/bin/cpptraj -p ../$top -y md_$sys2.rst_12500 -x md.crd_12500
  nice $AMBERHOME/bin/cpptraj -p ../$top -y md_$sys2.rst_25000 -x md.crd_25000
  nice $AMBERHOME/bin/cpptraj -p ../$top -y md_$sys2.rst_37500 -x md.crd_37500
  nice $AMBERHOME/bin/cpptraj -p ../$top -y md_$sys2.rst_50000 -x md.crd_50000

# Begin MM-GBSA calculation

  nice $AMBERHOME/bin/MMPBSA.py -O -i mmgbsa.i -cp complex.top -rp receptor.top -lp ligand.top -y md.crd*
 

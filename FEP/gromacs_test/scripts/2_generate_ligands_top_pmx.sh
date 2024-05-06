echo "Activating conda environment"
eval "$($(which conda) 'shell.bash' 'hook')"
conda activate pmx

ligand1_path="ligands/lig_1h1q-1"
ligand2_path="ligands/lig_1h1r-1"
#For Lig1~Lig2
pmx atomMapping -i1 $ligand1_path/1h1q.pdb -i2 $ligand2_path/1h1r.pdb  
pmx ligandHybrid -i1 $ligand1_path/1h1q.pdb -i2 $ligand2_path/1h1r.pdb -itp1 $ligand1_path/1h1q_GMX.itp -itp2 $ligand2_path/1h1r_GMX.itp -pairs pairs1.dat -offitp ffmerged_1.itp -oitp merged_1.itp

#For Lig2~Lig1

pmx atomMapping -i2 $ligand1_path/1h1q.pdb -i1 $ligand2_path/1h1r.pdb
pmx ligandHybrid -i2 $ligand1_path/1h1r.pdb -i1 $ligand2_path/1h1q.pdb -itp2 $ligand1_path/1h1r_GMX.itp -itp1 $ligand2_path/1h1q_GMX.itp -pairs pairs1.dat -offitp ffmerged_2.itp -oitp merged_2.itp

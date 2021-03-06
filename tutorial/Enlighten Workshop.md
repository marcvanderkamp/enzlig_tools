# Enlighten Tutorial 1
As an example, we will make a model of the class A beta-lactamase TEM-1 with sulbactam. There is no crystal structure available for the complex of TEM-1 with sulbactam, so we will use PyMOL to create a model from two different crystal structures.

**NB**: Whenever text is written in a `box like this`, it is a command that should be typed on a "command line", either in a "terminal" or in the PyMOL control panel.

## Preparation

### Step 1

---

We will first obtain the Enlighten plugin from the github repository. Open a terminal and type:
 
`git clone https://github.com/marcvanderkamp/enlighten.git`

Once the files have downloaded we need to set the ENLIGHTEN variable to indicate the location of the repository. 

`export ENLIGHTEN=/my/path/to/enlighten/`

where /my/path/to/enlighten/ will be something like "/Users/kr8728/enlighten"

-------


### Step 2
Open PyMOL. 
On typical Linux PCs (e.g. in Bristol in MVB 2.11), this can be done by opening a "terminal" (click on top left icon on a Linux PC) and in this "terminal", type:

`pymol`

Two windows will appear: a viewing window and a control panel. 

![](PyMOL_Startup.png)

We now need to load the enlighten plugin into PyMOL. From the Plugin drop-down menu choose Plugin and then Plugin Manager.

![](Plugin_manager.png)

In the Plugin manager choose the Install New Plugin tab and then select install from local file. When you click on the "Choose file" button you will need to navigate to the enlighten directory and then choose the Pymol sub-folder. Click on the \_init_.py file and choose Open to install the plugin.

![](enlighten_directory.png)

A new window will pop-up asking you to select a plugin directory. Choose the first option and click OK.

![](select_plugin_directory.png)

A message will appear to say that the plugin has been successfull installed. Exit the Plugin manager.

![](successful_install.png)


## Part 1: Making a model of the TEM-1-Sulbactam complex

*NB: if you want to skip Part 1 and go straight to Part 2, you can set up the model by running a pre-prepared PyMOL script.
This script can be found here: $ENLIGHTEN/tutorial/setup.pml*

*To load the script, type in the PyMOL control panel (replacing /my/path/to/enlighten/ as appropriate):*

`@ /my/path/to/enlighten/tutorial/setup.pml`

------

We will use PyMOL to obtain the crystal structures we need directly from the protein databank. In the control panel type:

`fetch 1BTL`

A crystal structure will appear in the viewing window. You will also see an object called 1BTL appear in the right-hand viewing panel. There are buttons A,S,H etc. which contain drop down menus that allow you to make changes to how the object is viewed. 

![](1BTL_load.png)

`fetch 4FH2`

A second structure will appear, partly overlapping the first. We now need to align the structures so that we can use the coordinates of sulbactam from 4FH2.

![](1BTL_4FH2.png)


`align 4FH2 and name CA, 1BTL and name CA`

You will see that structure 4FH2 move so that it is aligned with 1BTL based on the positions of the alpha carbons.

![](alignment.png)

We will now create a new PyMOL object which has the protein coordinates from PDB 1BTL and the coordinates of sulbactam from PDB 4FH2. The residue name for sulbactam is 0RN.

`select tmp, 1BTL (or 4FH2 and resname 0RN)`

`create 1btl_0rn, tmp`

![](1btl_0rn.png)

We now have a new object in the right-hand panel of the viewing window called 1btl_0rn. Hide the original structures 1BTL and 4FH2 by clicking on their names in the right-hand panel.

-------

We need to tidy up the structure a little bit before we can begin simulations. Firstly, we need to remove an sulfate (SO4) ion that is present from the crystalisation conditions. Information about the crystalisation conditions and other small molecules that have been identified in the structure is given in the header of the PDB and also on the structure page of the Protein databank: <http://www.rcsb.org/pdb/explore/explore.do?structureId=1BTL>

To remove all sulfate ions (in this case just one):

`remove (1btl_0rn and resname SO4)`

![](SO4.png)

-------

We also need to remove the water molecules that were part of 1BTL in the region we have just placed sulbactam. To do this we need to identlfy the water molecules overlapping with 0RN in our new model 1btl_0rn.  Now we will zoom in on the ligand.

`select 0RN, (1btl_0rn and resname 0RN)`

The new object 0RN will appear in the right-hand panel. Click on the S button and choose sticks from the drop down menu. 

![](0RN_sticks.png)

This will show the ligand in stick form. From the menu that appears when you click the A button for this object choose zoom. 

![](0RN_zoom.png)

![](0rn_zoomed_in.png)

We will now identify the water molecules.

`select HOH, (1btl_0rn and resname HOH within 2.0 of resname 0RN)`

This command will select 4 water molecules, you may wish to zoom on the HOH object to see them better. You can also change how the water molecules are displayed e.g. choose spheres from the drop-down menu that appears when you click on the S button for the HOH object. 

![](waters.png)
 
If you want to delete all water molecules in the selection HOH (which is sensible), you can do:

`remove (1btl_0rn and HOH)`

or go to the A button for the HOH object and choose remove atoms.

![](remove_atoms.png)

For removing specific water molecules, you can click on the water molecules to find their residue numbers. This information will appear in the control window e.g. 

Selector: selection "sele" defined with 1 atoms.  
You clicked /1btl_0rn/C/A/HOH`404/O

When you have found the residue numbers of the water molecules you want to delete, this is how they can be deleted from the structure:

`remove (1btl_0rn and resname HOH and res 323+391+404+437)`
 
-------

We will now add hydrogen atoms to sulbactam using the h_add function in PyMOL. 

`h_add (1btl_0rn and resname 0RN)`

![](h_Add_0RN.png)

Note that sulbactam has a charge of -1*e* and you will need to check visually to make sure that they have been placed reasonably.
 
For ease of identification during simulations we will change the chain id for the ligand 0RN.

`alter 0RN, chain="L"`

-------

Class A beta-lactamase residue numbering is somewhat of a special case: all residue numbers amongst different beta-lactamases are given corresponding numbers, e.g. the Serine residue is always Ser70. To account for insertions/deletions between different sequences, the PDB files contain 'insertion codes' and non-consecutive residue numbers. The second causes PyMOL to insert TER records (indicating a break in the polypepdtide chain). When using *Enlighten* through the PyMOL plugin for beta-lactamses, we therefore have to change this behaviour:

`set pdb_use_ter_records, off`

We have now done everything needed to create a model of the wild-type TEM-1 with sulbactam that can be used as input for *Enlighten*.

## Part 2: Running the *Enlighten* protocols through the plugin 
Go to the Plugin drop-down menu and choose "enlighten".
We are now ready to use Enlighten to perform some simulations. 
From the plugin menu choose enlighten:

![](plugin_menu.png)

A new enlighten control panel will appear. Some settings will be given as a default, but they can be changed if necessary. Click on the choose from PyMol object box and select 1btl_0rn, our wild-type model. You will need to change Ligand name to 0RN. Check that the other output settings are suitable and then click RUN PREP.

![](enlighten_menu.png)

RUN PREP may take a couple of minutes to complete. Please check if you see the following printed in the PyMOL control panel:

*Finished PREP protocol.*

This means the protocol has finished successfully. If not, please note the message printed for more information.

When PREP has finished successfully, a new object "1btl_0rn.sp20" will have been loaded into PyMOL. You will see that hydrogens have been added to the system and a solvent cap of radius 20 Å has been added to the model.

![](prep_finished.png)

We now need to let the model system 'relax' to remove any bad contacts present in the crystal structure. Click RUN STRUCT to perform the next stage of simulation.


![](run_struct.png)

The STRUCT protocol will take a few minutes to run and when it has finished a new structure will be loaded into the "1btl_0rn.sp20" object and the RUN DYNAM button will become active. Click RUN DYNAM to start the dynamics simulation.

![](run_dynam.png)


This will take some time to run (you will see estimated timings printed in the control panel), so we will now start to prepare our mutant model.

## Part 3: Creating a mutant and running *Enlighten*

We will now create a mutant structure for to simulate for comparison. We will make the R244T mutation, which causes a 300-fold increase in *Ki* for sulbactam (*i.e.* a decrease in binding affinity). See <http:www.jbc.org/content/267/29/20600.full.pdf> for the experimental details.

We will start by copying our object 1btl\_0rn to the new object 1btl\_0rn_r244t.

`create 1btl_0rn_r244t, 1btl_0rn`

We want to mutate Arg244 to Thr, so we will zoom in on this residue.

`select r244, (1btl_0rn_r244t and resi 244)`

From the Wizard drop-down menu, select mutagenesis:

![](wizard_menu.png)

Click on Arg244 and then  In the right hand panel choose Thr from the mutate to menu in the right-hand panel. 

![](Mut_sele_thr.png)

The lowest energy rotamer will then be displayed. 

![](mutation.png)

Click apply to accept the mutation and then done to exit the wizard.

![](r244t.png)


From the plugin menu choose enlighten:

![](plugin_menu.png)

A new enlighten control panel will appear. To run simulations on the mutant model you will need to select the new 1btl\_0rn_r244t object from the list and then click RUN PREP. Follow the same procedure to RUN STRUCT and DYNAM for the mutant model. 

## Part 4: Analysis

The MD trajectory will automatically be loaded into the 1btl\_0rn.sp20 object when DYNAM is finished. *If this is not the case, you can load it yourself into the 1btl_0rn.sp20 object:*

`load 1btl_0rn/dynam/md_1btl_0rn.sp20.trj, 1btl_0rn.sp20, 3, trj`
`load 1btl_0rn/dynam/min_1btl_0rn.sp20.rst, 1btl_0rn.sp20`


Press the play button to move between the frames. You can adjust the number of frames per second in the Movie drop-down menu. You can use the measurement function in the Wizard menu to monitor distances during the MD simulation. 

![](measurement_wizard.png)

Zoom in on sulbalactam and see which residues are in the binding site. Click on two atoms to measure the distance and then press play to see how the distance changes over the simulation. In the example shown, one of the carboyxlate oxygens of sulbalactam forms a hydrogen bond with Ser210. 

![](dist_ser.png)


We can use some of the analysis tools available as part of AmberTools to get some more meaningful information from the simulations. 

Here, we will calculate the root-mean square fluctuations (RMSF) of the protein, a measure of the 'flexibiltiy' of the protein, and also perform a binding energy calculation using the MM-GBSA method. 
*These are examples of analysis that could be added to the Enlighten plugin in the near future.*

Open a new terminal and move into the dynam subdirectory of the main output directory for the wild type model, by typing:

`cd $WORKDIR/1btl_0rn/dynam`

Copy the analysis script to the dynam directory:

`cp $ENLIGHTEN/analysis/run_analysis.sh .`

The analyis script needs to be given the pdb name for the system and the ligand name. To perform the analysis type:

`bash run_analysis.sh 1btl_0rn.pdb 0RN`

These calculations will take a few minutes to run.
The RMSF calculation will produce a file called rmsf\_all_1btl\_0rn.pdb with the RMSF data included in the b-factor column of the pdb. Open this pdb file in PyMOL. Display as cartoon and then choose colour by b-factor to view the RMSF analysis.
![](colour_by_bfact.png)

Highlight the position of the sulbalactam by showing it in stick representation. The dark blue regions are the protein that was fixed during the simulations, the more flexible regions are green and orange with a small part that is coloured red.


![](rmsf_output.png)

You can also plot the RMSF data against residue number. To do this open the file "rmsf_ca.dat" with LibreOffice or EXCEL.

![](rmsf_plot.png)


Now, you can repeat the analysis for the mutant model that you generated and ran the *Enlighten* protocols for.
Do this by repeating the steps of the analysis above, but now in the directory for the mutant. So you may start with:

`cd $WORKDIR/1btl_0rn_r244t/dynam`

`cp $ENLIGHTEN/analysis/run_analysis.sh .`

Run the analysis of this simulation by typing:

`bash run_analysis.sh 1btl_0rn_r244t.pdb 0RN`

You can now compare your results obtained for WT TEM-1 and the mutant.
Does the mutation alter the predicted binding energy? Is it more or less favourable than the wild-type? Does the mutation alter the flexibility (RMSF) of the residues?

If you have time:

- Run the MD simulations for the wild-type or mutant models again (in a different directory). Do you get the same values for the binding energy?
- Look at the residues close to the sulbalactam and choose a different residue to mutate. Does the mutation alter the predicted binding energy?


-----------


__When you have come to the end of the tutorial and explored *Enlighten* in some detail, please fill out the *[feedback survey](https://docs.google.com/forms/d/e/1FAIpQLScO0iCWLSjeSMaVAU60GcSgXWF1GuWlvEb2JKTizRgjO_6IzQ/viewform)* !__

Results from the survey will influence future priorities for further development, so your views are important.

If you have in-depth feedback or thoughts about Enlighten you would like to share, please get in touch.

Bugs in the Enlighten plugin or scripts can be reported as an "Issue" through the [github site](https://github.com/marcvanderkamp/enlighten/issues).

### Thank you!







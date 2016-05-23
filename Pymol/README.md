Enlighten PyMOL plugin
============

PyMOL plugin to run the (automated) [protocols](https://github.com/marcvanderkamp/enlighten/blob/master/README.md) for atomistic simulations of enzyme-ligand systems.

Aimed at: 
- Experimental biochemists/enzymologists interested in gaining detailed insight into protein-ligand / enzyme-substrate complexes.

Required:
- PyMOL version 1.5.0.5 or later (for Plugin Manager)

First, follow the instructions to download the complete Enlighten repository [here](https://github.com/marcvanderkamp/enlighten/blob/master/README.md)


###Install the Plugin:   

First ensure that the Enlighten git repository is installed, and also the required programmes (AmberTools14 or later, propka).

Then, open PyMOL and use Plugin --> Plugin Manager.

 _Further instructions to follow..._


In bash:

export ENLIGHTEN=/my/path/to/enlighten/

In tcsh/csh:

setenv ENLIGHTEN /my/path/to/enlighten/


## Available protocols
### PREP
PREP takes enzyme-ligand pdb file and generates ligand parameters, adds hydrogens, adds solvent (sphere), generates Amber topology/coordinate files.

- Uses the following AmberTools14 programs: antechamber (& sqm), prmchk2, pdb4amber, reduce, tleap 
- Ideally requires installation of propka31 (and put in $PATH)
- Extensive comments in prep.sh provide more in-depth explanation of the steps in the protocol, etc.

### STRUCT
STRUCT takes the topology/coordinate files generated by prep.sh and performs brief simulated-annealing and minimisation protocol (to optimize structure).


### DYNAM
DYNAM runs a simple MD protocol. This protocol typically takes >30 min (on a single CPU), although this depends strongly on the size of the system (number of atoms).


## Test cases
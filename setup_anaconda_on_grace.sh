#!/bin/bash
#
# Set up an Anaconda environment on Grace
# 
# By default, the script
# * Creates a .yml file from a template below, which includes
#   several scientific python packages
# * Creates an environment from the .yml file
# * Makes the new environment to auto-load on every login
# * unsets PYTHONHOME and PYTHONPATH
#############################################################

# Defaults

ANACONDA=python/anaconda/2.3.0 # Anaconda module on Grace
PYVERSION_DEFAULT=3.5
UNSET_OLD_PYTHON=true # If true, removes PYTHONHOME and PYTHONPATH
LOAD_SCRIPT=load_anaconda_env # Name of the auto-loading script (created automatically)

CONDA_ENVS=$HOME/.conda/envs # Default location of the new Anaconda environment

ADD_GCC_MODULE=gcc/4.9.3 # gcc library to load to avoid errors in libstdc++
LIBEXPAT_SOURCE=/lib64/libexpat.so.0.5.0 # necessary for cf_units

PCKGS="
- basemap
- cartopy
- geos
- gdal
- h5py
- ipython
- ipykernel
- ipywidgets
- iris
- matplotlib
- numpy
- pandas
- scipy
- xray
"
CHANNELS="
- conda-forge"

#############################################################

echo -n "This script will install Anaconda environment in your home directory

Please, press ENTER to continue
>>> "
    read dummy

    if [[ ($PYTHONPATH != "") || ($PYTHONHOME != "") && ("$UNSET_OLD_PYTHON" == true) ]]; then
    echo "WARNING:
    You currently have PYTHONPATH or PYTHONHOME environment variables set. 
    This may cause unexpected behavior when running the Python interpreter in Anaconda.

    This script will unset those variables."
fi

echo -n "Enter the version of Python for your new environment (2.7 or 3.5 recommended)
[$PYVERSION_DEFAULT] >>> "
read ans
if [[ $ans == "" ]]; then
    PYVERSION=$PYVERSION_DEFAULT
else
    PYVERSION=$ans 
fi

PYENVNAME_DEFAULT="py"${PYVERSION//./}
echo -n "Name your new Anaconda environment:
[$PYENVNAME_DEFAULT] >>> "
read ans
if [[ $ans == "" ]]; then
    PYENVNAME=$PYENVNAME_DEFAULT
else
    PYENVNAME=$ans 
fi

#############################################################
echo "Creating environment.yml file..."
echo -n "name: $PYENVNAME
channels:$CHANNELS
dependencies:
- python=$PYVERSION $PCKGS
" > environment_$PYENVNAME.yml

echo "Loading Anaconda..."
module load $ANACONDA

echo "Creating $PYENVNAME..."
conda env create -f environment_$PYENVNAME.yml

#############################################################
echo "Creating additional library links..."
if [[ $LIBEXPAT_SOURCE != "" ]]; then
    # Required for cf_units (iris dependancy)
    ln -s $LIBEXPAT_SOURCE $CONDA_ENVS/$PYENVNAME/lib/libexpat.so.1
fi

#############################################################
echo "#!/bin/bash
module load $ADD_GCC_MODULE
. $CONDA_ENVS/$PYENVNAME/bin/activate $PYENVNAME" > $LOAD_SCRIPT
if [[ "$UNSET_OLD_PYTHON" == true ]]; then
	echo "
unset PYTHONHOME
unset PYTHONPATH
" >> $LOAD_SCRIPT
fi

#############################################################
BASH_RC=$HOME/.bashrc
DEFAULT=yes
echo -n "Do you wish the $PYENVNAME environment to be loaded automatically? 
(by adding a line in your $BASH_RC)? [yes|no]
[$DEFAULT] >>> "
read ans
if [[ $ans == "" ]]; then
    ans=$DEFAULT
fi
if [[ ($ans != "yes") && ($ans != "Yes") && ($ans != "YES") &&
            ($ans != "y") && ($ans != "Y") ]]
then
    echo "
You may wish to edit your .bashrc or load $PYENVNAME environment manually:

source $LOAD_SCRIPT
"
else
    # Check if the line is already in .bashrc
    if grep -Fxq "source $LOAD_SCRIPT" $BASH_RC; then
        echo "
The line 'source $LOAD_SCRIPT' is already in $BASH_RC
"
    else

        if [ -f $BASH_RC ]; then
            echo "
Prepending source $LOAD_SCRIPT in $BASH_RC
A backup will be made to: ${BASH_RC}-backup
"
            cp $BASH_RC ${BASH_RC}-backup
        else
            echo "
Prepending source $LOAD_SCRIPT in
newly created $BASH_RC"
        fi
        echo "
WARNING:
For this change to become active, you have to open a new terminal.
"
        LAST_LINE=$(tail -1 .bashrc)
        if [[ "$LAST_LINE" == *"LOGIN_INVOKE=0"* ]]; then
            head -n -1 $BASH_RC > temp_bashrc.txt ; mv temp_bashrc.txt $BASH_RC 
            echo -n "
# loads $PYENVNAME Anaconda environment automatically
source $LOAD_SCRIPT" >> $BASH_RC
            echo "" >> $BASH_RC
            echo $LAST_LINE >> $BASH_RC
        else
            echo -n "
# loads $PYENVNAME Anaconda environment automatically
source $LOAD_SCRIPT" >> $BASH_RC
        fi
    fi
fi
module unload $ANACONDA

echo 'Done.'

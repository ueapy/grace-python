#!/bin/bash
#
# Create a configuration file for Jupyter Notebook using remote_ikernel tool
# and place it to kernels directory (usually ~/.local/share/jupyter/kernels/)
#
# more info: https://bitbucket.org/tdaff/remote_ikernel
#############################################################################

# Kernel name
RIK_NAME='Python on Grace'
# Your login on Grace
GRACE_LOGIN=$USER
# Grace address
GRACE_HOST=grace.uea.ac.uk

#############################################################################
python check_rik.py
if [ $? -eq 0 ]; then
    remote_ikernel manage --add \
                          --name="$RIK_NAME" \
                          --kernel_cmd='ipython kernel -f {connection_file}' \
                          --interface=lsf \
                          --verbose \
		          --remote-launch-args='-q interactive' \
                          --tunnel-hosts $GRACE_LOGIN@$GRACE_HOST \
                          --workdir='$HOME'

    if [ $? -eq 0 ]; then
        echo "Success."
    fi
fi

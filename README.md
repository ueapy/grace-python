# Tools for running Python on Grace

## Quickstart
### Option A: Anaconda Python environment on Grace
#### Copy the setup script to Grace
```
# Linux
scp setup_anaconda_on_grace.sh abc12xyz@grace.uea.ac.uk:~
```
#### (Grace) Install new Anaconda environment
```
source ./setup_anaconda_on_grace.sh
```
Re-login and enjoy Python



### Option B: Jupyter in PC's browser connected to a remote kernel on Grace
#### (Grace) install ipython, ipykernel
The easiest way is to follow the instructions above and use Anaconda

#### (local PC) Enable passwordless ssh login to Grace
```
# Linux
ssh-keygen
ssh-copy-id -i ~/.ssh/id_rsa.pub abc12xyz@grace.uea.ac.uk
```
Windows: follow putty instructions

#### Try logging to Grace (login mode)
Should be without password by now

#### (local PC) Create a Jupyter kernel config file to connect to Grace
If you use Anaconda on your PC, the following commands need to be run in Anaconda prompt
##### (local PC) Install `remote_ikernel` utility
WARNING: Not yet compatible with Windows. Hopefully will be soon.
```
pip install remote_ikernel
```
##### (local PC) Run the script
```
# Linux
bash add_rik_grace_lsf.sh
```
```
# Windows
remote_ikernel manage --add \
                      --name='Python on Grace' \
                      --kernel_cmd='ipython kernel -f {connection_file}' \
                      --interface=lsf \
                      --verbose \
                      --remote-launch-args='-q interactive' \
                      --tunnel-hosts abc12xyz@grace.uea.ac.uk \
                      --workdir='$HOME'
```
#### (local PC) Jupyter Notebook
```
jupyter notebook
```
In the drop-down menu select the new kernel

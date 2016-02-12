from distutils.version import StrictVersion
import sys

try:
    import remote_ikernel as rik
    if StrictVersion(rik.__version__) < StrictVersion('0.4.4'):
        sys.exit('Platform LSF is not supported in {curver}. Please install remote_ikernel>={reqver}'.format(
                 curver=rik.__version__,
                 reqver='0.4.4')
                )
 
except ImportError:
    sys.exit("Package remote_ikernel>=0.4.4 is required!\nIntall it using pip:\npip install remote_ikernel")

# ======================================================================================
# == Fix any missing Module, that need to be installed with PIP.exe. [Windows System] ==
# ======================================================================================
import importlib, os, sys, logging
#=============================================================================
#=== Set logging config
#=============================================================================
logging.basicConfig(
    level=logging.INFO, 
    format='[%(asctime)s] [%(levelname)s] [%(name)s] - %(message)s')

logger = logging.getLogger(__name__)
#=============================================================================
#=== Function: import_neccessary_modules(modname:str)
#=============================================================================
def import_neccessary_modules(modname:str)->None:
    '''
        Import a Module,
        and if that fails, try to use the Command Window PIP.exe to install it,
        if that fails, because PIP in not in the Path,
        try find the location of PIP.exe and again attempt to install from the Command Window.
    '''
    try:
        # If Module it is already installed, try to Import it
        importlib.import_module(modname)
        logger.debug(f"Importing {modname}")
    except ImportError:
        # Error if Module is not installed Yet,  the '\033[93m' is just code to print in certain colors
        logger.debug(f"\033[93mSince you don't have the Python Module [{modname}] installed!")
        logger.debug("I will need to install it using Python's PIP.exe command.\033[0m")
        if os.system('PIP --version') == 0:
            # No error from running PIP in the Command Window, therefor PIP.exe is in the %PATH%
            os.system(f'PIP install {modname}')
        else:
            # Error, PIP.exe is NOT in the Path!! So I'll try to find it.
            pip_location_attempt_1 = sys.executable.replace("Python.exe", "") + "pip.exe"
            #print(pip_location_attempt_1)
            pip_location_attempt_2 = sys.executable.replace("Python.exe", "") + "Scripts\pip.exe"
            #print(pip_location_attempt_2)
            if os.path.exists(pip_location_attempt_1):
                # The Attempt #1 File exists!!!
                os.system(pip_location_attempt_1 + " install " + modname)
            elif os.path.exists(pip_location_attempt_2):
                # The Attempt #2 File exists!!!
                os.system(pip_location_attempt_2 + " install " + modname)
            else:
                # Neither Attempts found the PIP.exe file, So i Fail...
                logger.warning(f"\033[91mAbort!!!  I can't find PIP.exe program!")
                logger.warning(f"You'll need to manually install the Module: {modname} in order for this program to work.")
                logger.warning(f"Find the PIP.exe file on your computer and in the CMD Command window...")
                logger.warning(f"   in that directory, type    PIP.exe install {modname}\033[0m")
                exit()
#For test                
#import_neccessary_modules('os')
#import_neccessary_modules('pandas')
#import_neccessary_modules('pyodbc')

# for module in ('os', 'pandas', 'pyodbc'):
#     import_neccessary_modules(module)

# import pandas as pd
                
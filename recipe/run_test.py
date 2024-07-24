# This simple test checks that the version of the conda package is the same as the version of the pip package
# The side effect is that it also checks the `.dist-info/` folder has been correctly created for the rdkit package
# and will fails otherwise.

import rdkit

from importlib.metadata import metadata
from packaging.version import Version

metadata = dict(metadata('rdkit'))

# Get the version from pip.
pip_version = metadata['Version']  # example: 2023.9.3

# Get the version from the conda package.
conda_version = rdkit.__version__  # example: 2023.09.3

# Normalize the version from the conda package.
# NOTE: this is mandatory because conda versions are not PEP440 compliant while pip enforces PEP440 compliance.
conda_version_normalized = str(Version(conda_version))

# Check those are the same.
assert pip_version == conda_version_normalized, (pip_version, conda_version, conda_version_normalized)

# This is run (sourced) before the TC's auto-build!

echo "-------- PER-TC SETUP SCIPT! ---------"
# GCC:
export CPATH="subdir"
# MSVC:
export INCLUDE="subdir;$INCLUDE"

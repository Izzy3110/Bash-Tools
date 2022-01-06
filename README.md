# Bash-Tools
Some useful bash-scripts for automation and other stuff

- ### install_missing_pkg_apt.sh - see [commit message](https://github.com/Izzy3110/Bash-Tools/commit/622fd97f2ee2b9643e19350f1de15865f381f35f) for example

  - Default Log-File: /var/log/missing_apt.log - install_missing_pkg_apt.sh(4)
  - usage
  ```
  Usage: install_missing_pkg_apt.sh [-h] [-a] package_name [package_name...]

  Check for missing apt-packages and install them if missing

  Available options:

  -h, --help      Print this help and exit
  -a              Print created last lines of log-file after
  ```

===============================
oldmefpy
===============================

.. image:: https://img.shields.io/travis/lneisenman/oldmefpy.svg
        :target: https://travis-ci.org/lneisenman/oldmefpy

.. image:: https://coveralls.io/repos/lneisenman/oldmefpy/badge.svg?branch=master
   :target: https://coveralls.io/r/lneisenman/oldmefpy?branch=master 

.. image:: https://ci.appveyor.com/api/projects/status/fuu825yp9ep83tgq/branch/master?svg=true
   :target: https://ci.appveyor.com/api/projects/status/fuu825yp9ep83tgq


Code to read `MEF2.0/2.1 <https://github.com/benbrinkmann/mef_lib_2_1>`_ files into Python. This package requires Python 3.7 and `numpy <https://numpy.org/>`_.

Install using `pip` to install the `wheel provided under releases <https://github.com/lneisenman/oldmefpy/releases/download/0.1.0/oldmefpy-0.1.0-cp37-cp37m-win_amd64.whl>`_ in this Github repo.

Building this package requires Cython and GCC. MSVC does not work. Installing Cython and PYMC3 using Conda will provide what is needed.

This reads the older version of MEF files. As of this writing, the current version is `3.0 <https://github.com/msel-source/meflib>`_ and those files are read using `pymef <https://github.com/msel-source/pymef>`_.

* If you have a directory called `*.mefd` then you want `pymef <https://github.com/msel-source/pymef>`_.

* If you have a bunch of `.mef` files then this might work for you.


This package provides two functions

* `read_metadata(file_name)`: reads metadata from the file header and returns it in a Dict. Useful keys include

   * 'number_of_samples'

   * 'sampling_frequency'

   * 'voltage_conversion_factor'


* `read_mef(file_name, start_idx=None, end_idx=None)`: reads the data and returns a numpy array. If start and end are not specified, it reads the whole file. The indices refer to sample numbers, not times.


There are no writing functions. If you want to save to MEF files, use `pymef <https://github.com/msel-source/pymef>`_.

To get this to work with Windows, I had to

* Change `long int` and `unsigned long int` in `mef_lib_2_1/mef.h` to `long long` and `unsigned long long`.

   `Long int` is 8 bytes in Linux but only 4 in Windows. `Long long` is 8 bytes in both.

* Define `random` as `rand` and `srandom` as `srand` in `mef_lib_2_1/mef_lib.c`.

#!/usr/bin/env python
# -*- coding: utf-8 -*-


try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

from distutils.extension import Extension
from Cython.Build import cythonize

import numpy


source_files = ["oldmefpy/oldmefpy.pyx", "oldmefpy/mef_lib_2_1/mef_lib.c"]
include_dirs = [numpy.get_include()]
extensions = [Extension("oldmefpy.oldmefpy",
                        sources=source_files,
                        include_dirs=include_dirs)]
                        
with open('README.rst') as readme_file:
    readme = readme_file.read()

with open('HISTORY.rst') as history_file:
    history = history_file.read().replace('.. :changelog:', '')

requirements = ['numpy']


setup(
    name='oldmefpy',
    version='0.1.0',
    description="Code to read MEF2.0/2.1 files",
    long_description=readme + '\n\n' + history,
    author="Larry Eisenman",
    author_email='leisenman@wustl.edu',
    url='https://github.com/lneisenman/oldmefpy',
    packages=[
        'oldmefpy',
    ],
    package_dir={'oldmefpy':
                 'oldmefpy'},
    package_data={'': ['*.pyx', '*.pxd', '*.h', '*.txt', '*.dat', '*.csv']},
    install_requires=requirements,
    license="BSD",
    zip_safe=False,
    keywords='oldmefpy',
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'License :: OSI Approved :: BSD License',
        'Natural Language :: English',
        'Programming Language :: Cython',
        'Programming Language :: Python :: 3.7',
    ],
    test_suite='tests',
    ext_modules=cythonize(extensions),
)

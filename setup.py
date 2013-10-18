"""Hybrid setuptools/distutils script for installing ``oseq''

Setuptools has preference over distutils (mainly for its advantages for 
installing development versions and running tests with nose). If setuptools is
not found, the installation will fall back on distutils.
"""

import sys
import os.path

try:
    # Cython *.pyx will not compile to C automatically with setuptools
    # This `monkey patch' does fix this (before importing setuptools)
    # For this to work: make sure that the ``fake_pyrex'' file hierarchy exists
    sys.path.insert(0, os.path.join(os.path.dirname(__file__), "fake_pyrex"))
    # Is setuptools available?
    from setuptools import setup, Extension, find_packages
    # setuptools has some extra options, not in distutils
    extra_options = {
        "install_requires": [],
        "test_suite": "nose.collector",
        "tests_require": ["nose",],
        "zip_safe": False,
        "extras_require": {},
    }
    packages = find_packages('src')
    USE_SETUPTOOLS = True
except ImportError:
    # no setuptools installed, fall back on distutils
    from distutils.core import setup, Extension
    extra_options = {}
    USE_SETUPTOOLS = False
    packages = [""]

# override setuptools (then distutils is used)
# USE_SETUPTOOLS = False

try:
    from Cython.Distutils import build_ext
    USE_CYTHON = True
except ImportError:
    if USE_SETUPTOOLS:
        from distutils.command import build_ext
    else:
        from distutils.command import build_ext
    USE_CYTHON = False


def get_install_requirements():
    """
    Returns a list of dependencies for Package to function correctly on the
    target platform
    
    """
    install_requires = []
    #if sys.version_info < (2, 5):
    #    install_requires.extend(["package >= version",])
    #if USE_CYTHON:
    #    install_requires.extend( ["Cython == 0.12"] )
    return install_requires


def emit_warning(warn):
    """Emits a warning to stderr"""
    print >> sys.stderr, 80 * '*'
    print >> sys.stderr, ""
    print >> sys.stderr, 'WARNING:'
    print >> sys.stderr, warn
    print >> sys.stderr, ""
    print >> sys.stderr, 80 * '*'


def get_extensions():
    """
    Returns a list of all extensions

    """
    ext_modules = []
    if sys.platform.startswith('java'):
        emit_warning(
            '\tAn optional optimization (C extension) could not be compiled.\n'
            '\tOptimizations for this package will not be available!\n'
            '\tCompiling C extensions is not supported for Jython\n')
        return ext_modules
    if USE_CYTHON:
        ext_modules.extend([
            Extension('oseq._oseq', ['src/oseq/_oseq.pyx']),
        ])
    else:
        emit_warning(
            "\tCython compiler not found,"
            "\tI will continue compiling the supplied .c files")
        ext_modules.extend([
            Extension('oseq._oseq', ['src/oseq/_oseq.c']),
        ])
    return ext_modules


def get_version():
    """
    Gets the version number. Pulls it from the source files rather than
    duplicating it.
    
    """
    # we read the file instead of importing it as root sometimes does not
    # have the cwd as part of the PYTHONPATH
    fn = os.path.join(os.path.dirname(__file__), 'src', 'oseq', '__init__.py')
    
    try:
        lines = open(fn, 'r').readlines()
    except IOError:
        raise RuntimeError("Could not determine version number"
                           "(%s not there)" % (fn))
    version = None
    for l in lines:
        # include the ' =' as __version__ might be a part of __all__
        if l.startswith('__version__ =', ):
            version = eval(l[13:])
            break
    if version is None:
        raise RuntimeError("Could not determine version number: "
                           "'__version__ =' string not found")
    return version

if USE_SETUPTOOLS and USE_CYTHON:
    extra_options["install_requires"].extend(get_install_requirements())

setup(name = "oseq",
    version = get_version(),
    description = "An Ordered Sequence of objects where duplicates are allowed.",
    long_description = open('README', 'r').read(),
    #url = "http://url/",
    author = "Martijn Meijers",
    author_email = "b dot m dot meijers at tudelft dot nl",
    keywords = "ordered sequence, red black tree, priority queue",
    package_dir = {"": "src"},
    packages = ["oseq", ],
    ext_modules = get_extensions(),
    license = "MIT License",
    platforms = ["any"],
    cmdclass = {"build_ext": build_ext, },
    classifiers = [
        "Development Status :: 5 - Production/Stable",
        "Intended Audience :: Developers",
        "Intended Audience :: Information Technology",
        "License :: OSI Approved :: MIT License",
        "Operating System :: OS Independent",
        "Programming Language :: Python",
        "Programming Language :: Python :: 2.7",
        "Programming Language :: Cython",
        "Topic :: Software Development :: Libraries",
        "Topic :: Software Development :: Libraries :: Python Modules",
    ],
    **extra_options)

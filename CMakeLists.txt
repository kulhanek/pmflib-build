# ==============================================================================
# PMEMD-PMF Composite CMake File
# ==============================================================================

CMAKE_MINIMUM_REQUIRED(VERSION 3.10 FATAL_ERROR)
#SET(CMAKE_VERBOSE_MAKEFILE ON)

# ==============================================================================
# project setup ----------------------------------------------------------------
# ==============================================================================

PROJECT(PMFLib)

# what languages we use ---------------------------
ENABLE_LANGUAGE(C)
ENABLE_LANGUAGE(CXX)
ENABLE_LANGUAGE(Fortran)

# this is composite project ----------------------
SET(COMPOSITE_PROJECT TRUE)
SET(DEVELOPMENT_ROOT "${CMAKE_BINARY_DIR}/src")

# extra options ----------------------------------
SET(LIBS_COMPLEX        OFF  CACHE BOOL "Support for complex numbers?" FORCE)
SET(PMFLIB_HAVE_XBPLIB  OFF  CACHE BOOL "Is XBPLib available?" FORCE)
SET(TRY_QT_LIB          OFF  CACHE BOOL "QT is not neccessary" FORCE)
SET(PMFLIB_SANDER_DRV   OFF  CACHE BOOL "Should the driver for sander be built?" FORCE)
SET(PMFLIB_PMEMD_DRV    OFF   CACHE BOOL "Should the driver for pmemd be built?" FORCE)
SET(PMFLIB_CPMD_DRV     OFF  CACHE BOOL "Should the driver for cpmd be built?" FORCE)
SET(PMFLIB_CP2K_DRV     OFF  CACHE BOOL "Should the driver for cp2k be built?" FORCE)
SET(PMFLIB_XDYNBP_DRV   OFF  CACHE BOOL "Should the driver for xdynbp be built?")
SET(PMFLIB_LIBATOMS_DRV OFF  CACHE BOOL "Should the driver for libatoms be built?" FORCE)
SET(PMFLIB_CATS_DRV     OFF  CACHE BOOL "Should the driver for cats be built?" FORCE)
SET(PMFLIB_OPENMP       OFF CACHE BOOL "Should OpenMP be enabled for some PMFLib utilities?")

# ==============================================================================
# libraries --------------------------------------------------------------------
# ==============================================================================

SET(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH} "${DEVELOPMENT_ROOT}/projects/cmake-modules/1.0/share/modules")

# boost package
FIND_PACKAGE(MyBoost)

# setup BLAS/LAPACK either from MKL or from fallback netlib blas and lapack
FIND_PACKAGE(BlasLapack)

LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/lib)
LINK_DIRECTORIES(${CMAKE_BINARY_DIR}/lib/drivers)

# ==============================================================================
# rpaths -----------------------------------------------------------------------
# ==============================================================================

# use, i.e. don't skip the full RPATH for the build tree
SET(CMAKE_SKIP_BUILD_RPATH  FALSE)

# when building, don't use the install RPATH already
# (but later on when installing)
SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 

# the RPATH to be used when installing
SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib/drivers:${CMAKE_INSTALL_PREFIX}/lib")

# add the automatically determined parts of the RPATH
# which point to directories outside the build tree to the install RPATH
SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH FALSE)

# ==============================================================================
# compiler setups --------------------------------------------------------------
# ==============================================================================

# setup IntelCDK if available
INCLUDE(IntelCDK)

# setup compilers
INCLUDE(SetupCompilers)

# if parallel environment is available
IF( NOT MPI_ENABLED )  # do not mix MPI and OpenMP
    IF( PMFLIB_OPENMP OR (MKL_MODE STREQUAL "parallel") OR (MKL_MODE STREQUAL "parallel/ilp64"))
        # setup OpenMP for cpmf if available
        FIND_PACKAGE(OpenMP)
        MESSAGE("-- OpenMP MODE: enabled")
    ELSE()
        MESSAGE("-- OpenMP MODE: disabled")
    ENDIF()
ELSE()
    MESSAGE("-- OpenMP MODE: disabled")
ENDIF()

SET(CMAKE_BUILD_TYPE Release)
#SET(CMAKE_BUILD_TYPE Debug)

# ==============================================================================
# project subdirectories  ------------------------------------------------------
# ==============================================================================

# third party ------------------------------------
IF(NOT MKL_FOUND)
    ADD_SUBDIRECTORY(src/thirdparty/blas/netlib)
    ADD_SUBDIRECTORY(src/thirdparty/lapack/3.1.1)
ENDIF(NOT MKL_FOUND)
ADD_SUBDIRECTORY(src/thirdparty/ranlux/1.0)
ADD_SUBDIRECTORY(src/thirdparty/csparse/2.2.1)
ADD_SUBDIRECTORY(src/thirdparty/lbfgs/1.0)

# projects ---------------------------------------
ADD_SUBDIRECTORY(src/projects/hipoly/1.0)
ADD_SUBDIRECTORY(src/projects/scimafic/1.0)
ADD_SUBDIRECTORY(src/projects/prmfile/1.0)
ADD_SUBDIRECTORY(src/projects/netlib/1.0)
ADD_SUBDIRECTORY(src/projects/pmflib/6.0)

# ==============================================================================
# inter-project dependencies  -------------------------------------------------
# ==============================================================================
ADD_DEPENDENCIES(cscimafic_shared hipoly_shared)

ADD_DEPENDENCIES(cscimafic_shared hipoly_shared)
ADD_DEPENDENCIES(cprmfile_shared hipoly_shared)
ADD_DEPENDENCIES(netlib_shared hipoly_shared cprmfile_shared)
ADD_DEPENDENCIES(fpmf_shared fprmfile_shared fscimafic_shared franlux_shared)
ADD_DEPENDENCIES(cpmf_shared hipoly_shared cscimafic_shared netlib_shared)

# local blas and lapack
IF(NOT MKL_FOUND)
    ADD_DEPENDENCIES(cscimafic_shared fblasd_shared flapackd_shared)
    ADD_DEPENDENCIES(fscimafic_shared fblasd_shared flapackd_shared)    
    ADD_DEPENDENCIES(flapackd_shared fblasd_shared)
    ADD_DEPENDENCIES(fpmf_shared fblasd_shared flapackd_shared)
ENDIF(NOT MKL_FOUND)

IF(OpenMP_FOUND)
    ADD_DEPENDENCIES(_gpr-opthyprms flbfgs_shared cpmf_shared)
ELSE()
    ADD_DEPENDENCIES(gpr-opthyprms flbfgs_shared cpmf_shared)
ENDIF()


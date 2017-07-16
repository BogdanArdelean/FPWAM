cmake_minimum_required(VERSION 3.6)
project(software)

set(CMAKE_CXX_STANDARD 11)

set(SOURCE_FILES Wam2FPWAM/wam2FPWAM.c Wam2FPWAM/wam2FPWAM.h Wam2FPWAM/wam_parser.c FPWAM/Instruction.cpp FPWAM/Instruction.h FPWAM/FPWAMDefs.h main.cpp FPWAM/Predicate.cpp FPWAM/Predicate.h FPWAM/CodeContext.cpp FPWAM/CodeContext.h Wam2FPWAM/wam2FPWAM.h FPWAM/GPLCBridge.h FPWAM/GPLCBridge.cpp FPWAM/SerialWrapper.cpp FPWAM/SerialWrapper.h FPWAM/FPWAMReader.cpp FPWAM/FPWAMReader.h)
add_executable(software ${SOURCE_FILES})
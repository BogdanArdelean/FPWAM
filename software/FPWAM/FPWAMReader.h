//
// Created by Bogdan  Ardelean on 7/16/17.
//

#ifndef SOFTWARE_FPWAMREADER_H
#define SOFTWARE_FPWAMREADER_H


#include <string>
#include <vector>
#include "SerialWrapper.h"

namespace FPWAM
{
    class FPWAMReader
    {
    public:
        FPWAMReader(const std::string &portName);

        bool open();

        bool read(int32_t variables, std::vector<std::vector<int32_t>> &vars);


    private:
        SerialWrapper m_serialWrapper;

        void read(int32_t variables, std::vector<int32_t> &var);
    };
}


#endif //SOFTWARE_FPWAMREADER_H

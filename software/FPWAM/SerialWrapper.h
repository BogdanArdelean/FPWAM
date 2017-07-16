//
// Created by Bogdan  Ardelean on 7/16/17.
//

#ifndef SOFTWARE_SERIALWRAPPER_H
#define SOFTWARE_SERIALWRAPPER_H


#include <string>

class SerialWrapper
{
public:
    SerialWrapper(const std::string&);
    bool open();
    int8_t read8();
    int16_t read16();
    int32_t read24();
    int32_t read32();

private:
    int m_fd;
    const std::string m_portName;
};


#endif //SOFTWARE_SERIALWRAPPER_H

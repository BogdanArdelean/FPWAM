//
// Created by Bogdan  Ardelean on 7/16/17.
//

#include <fcntl.h>
#include <zconf.h>
#include <termios.h>
#include <unistd.h>
#include <string.h>
#include "SerialWrapper.h"


bool set_interface_attribs (int fd, int speed, int parity)
{
    struct termios tty;
    memset (&tty, 0, sizeof tty);
    if (tcgetattr (fd, &tty) != 0)
    {
        return -1;
    }

    cfsetospeed (&tty, speed);
    cfsetispeed (&tty, speed);

    tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;     // 8-bit chars
    // disable IGNBRK for mismatched speed tests; otherwise receive break
    // as \000 chars
    tty.c_iflag &= ~IGNBRK;         // disable break processing
    tty.c_lflag = 0;                // no signaling chars, no echo,
    // no canonical processing
    tty.c_oflag = 0;                // no remapping, no delays
    tty.c_cc[VMIN]  = 0;            // read doesn't block
    tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

    tty.c_iflag &= ~(IXON | IXOFF | IXANY); // shut off xon/xoff ctrl

    tty.c_cflag |= (CLOCAL | CREAD);// ignore modem controls,
    // enable reading
    tty.c_cflag &= ~(PARENB | PARODD);      // shut off parity
    tty.c_cflag |= parity;
    tty.c_cflag &= ~CSTOPB;
    tty.c_cflag &= ~CRTSCTS;

    if (tcsetattr (fd, TCSANOW, &tty) != 0)
    {
        return false;
    }
    return true;
}

bool set_blocking (int fd, int should_block)
{
    struct termios tty;
    memset (&tty, 0, sizeof tty);
    if (tcgetattr (fd, &tty) != 0)
    {
        return false;
    }

    tty.c_cc[VMIN]  = should_block ? 1 : 0;
    tty.c_cc[VTIME] = 5;            // 0.5 seconds read timeout

    if (tcsetattr (fd, TCSANOW, &tty) != 0)
        return false;

    return true;
}

SerialWrapper::SerialWrapper(const std::string &portName)
:m_portName(portName)
{

}

bool SerialWrapper::open()
{
    m_fd = ::open(m_portName.c_str(), O_RDWR | O_NOCTTY | O_SYNC);
    if (m_fd < 0)
    {
        return false;
    }

    if(!set_interface_attribs (m_fd, B115200, 0))
    {
        return false;
    }

    if(!set_blocking (m_fd, 1))
    {
        return false;
    }
    return false;
}

int8_t SerialWrapper::read8()
{
    int8_t buf = 0;
    ::read(m_fd, &buf, sizeof (buf));
    return buf;
}

int16_t SerialWrapper::read16()
{
    int16_t buf = 0;
    ::read(m_fd, &buf, sizeof (buf));
    return buf;
}

int32_t SerialWrapper::read32()
{
    uint32_t buf = 0;
    ::read(m_fd, &buf, sizeof (buf));
    return buf;
}

int32_t SerialWrapper::read24()
{
    uint32_t buf = 0;
    ::read(m_fd, &buf, 3);
    return buf >> 8;
}

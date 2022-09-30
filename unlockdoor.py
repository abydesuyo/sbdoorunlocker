import switchbot
import os
import sys
import logging
import ast
import datetime

logging.basicConfig(filename='log/unlocker.log',level=logging.DEBUG,format='%(asctime)s %(message)s', datefmt='%d/%m/%Y %I:%M:%S %p')

def getDeviceId(name):
    #print("Getting DeviceId for %s" %name)
    logging.info("Getting DeviceId for %s" %name)
    f = open(os.environ['SB_DEVICE_MAP'])
    data = ast.literal_eval(f.read())
    deviceId = data[name]
    f.close()
    return deviceId


def main():
    if len(sys.argv) < 2 :
        logging.info("Usage %s <DeviceName>", sys.argv[0])
        print("Usage %s <DeviceName>" %(sys.argv[0]))
    else:
        sb = switchbot.SwitchBot()
        deviceId = getDeviceId(sys.argv[1])
        status = sb.getDeviceStatus(deviceId)
        if status == 'locked':
            logging.info("Attempting Unlock")
            sb.unlockDevice(deviceId)
        else:
            logging.info("Device is already Unlocked")
        #sb.unlockDevice(deviceId)
        #print('Lets skip this for now')
        #logging.info("Mock Unlock")
    logging.info("Leaving Unlocker")

main()

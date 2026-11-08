// glowlessd: keeps the MagSafe LED in the mode chosen in MODE_FILE.
// Runs as root (writing SMC keys requires it). Build: clang -framework IOKit
#include <IOKit/IOKitLib.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

#define MODE_FILE "/Users/Shared/Glowless/mode"
#define KERNEL_INDEX_SMC 2
#define SMC_CMD_READ_KEYINFO 9
#define SMC_CMD_WRITE_BYTES 6

typedef struct {
    char major, minor, build, reserved;
    UInt16 release;
} SMCVers;

typedef struct {
    UInt16 version, length;
    UInt32 cpuPLimit, gpuPLimit, memPLimit;
} SMCPLimit;

typedef struct {
    UInt32 dataSize, dataType;
    char dataAttributes;
} SMCKeyInfo;

typedef struct {
    UInt32 key;
    SMCVers vers;
    SMCPLimit pLimitData;
    SMCKeyInfo keyInfo;
    char result, status, data8;
    UInt32 data32;
    unsigned char bytes[32];
} SMCKeyData;

static io_connect_t conn;

static UInt32 fourcc(const char *s) {
    return (UInt32)s[0] << 24 | (UInt32)s[1] << 16 | (UInt32)s[2] << 8 | (UInt32)s[3];
}

static kern_return_t smc_call(SMCKeyData *in, SMCKeyData *out) {
    size_t outSize = sizeof(SMCKeyData);
    return IOConnectCallStructMethod(conn, KERNEL_INDEX_SMC, in, sizeof(SMCKeyData), out, &outSize);
}

static int smc_write_u8(const char *key, unsigned char value) {
    SMCKeyData in = {0}, out = {0};
    in.key = fourcc(key);
    in.data8 = SMC_CMD_READ_KEYINFO;
    if (smc_call(&in, &out) != kIOReturnSuccess) return -1;

    in.keyInfo.dataSize = out.keyInfo.dataSize;
    in.data8 = SMC_CMD_WRITE_BYTES;
    in.bytes[0] = value;
    memset(&out, 0, sizeof out);
    if (smc_call(&in, &out) != kIOReturnSuccess || out.result != 0) return -1;
    return 0;
}

// ACLC: 0 = system, 1 = off, 3 = green, 4 = orange
static int read_mode(void) {
    char buf[16] = {0};
    FILE *f = fopen(MODE_FILE, "r");
    if (!f) return 0;
    fgets(buf, sizeof buf, f);
    fclose(f);
    if (!strncmp(buf, "off", 3)) return 1;
    if (!strncmp(buf, "green", 5)) return 3;
    if (!strncmp(buf, "orange", 6)) return 4;
    return 0;
}

int main(void) {
    io_service_t svc = IOServiceGetMatchingService(kIOMainPortDefault, IOServiceMatching("AppleSMC"));
    if (!svc || IOServiceOpen(svc, mach_task_self(), 0, &conn) != kIOReturnSuccess) {
        fprintf(stderr, "glowlessd: cannot open AppleSMC\n");
        return 1;
    }
    IOObjectRelease(svc);

    int last = -1;
    for (;;) {
        int mode = read_mode();
        // macOS re-takes the LED on plug/unplug and charge changes, so forced modes are re-applied
        // every tick. ponytail: 2s polling, swap for IOPS power-source notifications if it ever matters.
        if (mode != 0 || last != 0) {
            if (smc_write_u8("ACLC", (unsigned char)mode) != 0) fprintf(stderr, "glowlessd: write failed\n");
        }
        last = mode;
        sleep(2);
    }
}

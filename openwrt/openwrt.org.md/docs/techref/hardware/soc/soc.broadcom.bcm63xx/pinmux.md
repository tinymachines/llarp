# BCM6348 GPIO pinmux

Memory address: `0xfffe0418`  
Size: 4 bytes

GPIO GROUP0 GROUP1 GROUP2 GROUP3 GROUP4 REG 0x7 0x40 0x60 0x80 0x500 0x7000 0x8000 0x30000 0x80000 0 LEGACY LED 0 UTO TXD4 1 LEGACY LED 1 UTO TXD5 2 LEGACY LED 2 UTO TXD6 3 LEGACY LED 3 UTO TXD7 4 UTO RXD4 5 UTO RXD5 6 UTO RXD6 7 UTO RXD7 8 MII RXD0 UTO RXD0 9 MII RXD1 UTO RXD1 10 MII RXD2 UTO RXD2 11 MII RXD3 UTO RXD3 12 MII TXD0 UTO TXD0 13 MII TXD1 UTO TXD1 14 MII TXD2 UTO TXD2 15 MII TXD3 UTO TXD3 16 PCI INTA# 17 PCI REQ0# 18 PCI REQ1# 19 PCI GNT0# 20 PCI GNT1# 21 PCI IDSEL 22 PCCARD READY UART DCD 23 PCCARD CCD1 UART RI 24 PCCARD CCD2 UART DSR 25 PCCARD VS1 UART CTS 26 PCCARD VS2 UART DTR 27 PCCARD CREQ# UART RTS 28 UTO RXADDR0 29 SPI SS1 UTO RXADDR1 30 SPI SS2 UTO TXADDR0 31 SPI SS3 UTO TXADDR1 32 MII MDC EXT IRQ0 33 EXT IRQ1 34 EXT IRQ2 35 EXT IRQ3 36 EXT IRQ4

**Note**: the EXT IRQs are shared with the GPIO function, they don't need to be enabled by any gpio mode group.

Code from Broadcom GPL (*6348\_map\_part.h* file):

```
  uint32        GPIOMode;  //0xfffe0400 + 0x18
#define         GROUP4_DIAG             0x00090000
#define         GROUP4_UTOPIA           0x00080000
#define         GROUP4_LEGACY_LED       0x00030000
#define         GROUP4_MII_SNOOP        0x00020000
#define         GROUP4_EXT_EPHY         0x00010000
#define         GROUP3_DIAG             0x00009000
#define         GROUP3_UTOPIA           0x00008000
#define         GROUP3_EXT_MII          0x00007000 // presumable use
#define         GROUP2_DIAG             0x00000900
#define         GROUP2_PCI              0x00000500 // presumable use
#define         GROUP1_DIAG             0x00000090
#define         GROUP1_UTOPIA           0x00000080
#define         GROUP1_SPI_UART         0x00000060
#define         GROUP1_SPI_MASTER       0x00000060 // presumable use
#define         GROUP1_MII_PCCARD       0x00000040 // presumable use
#define         GROUP1_MII_SNOOP        0x00000020
#define         GROUP1_EXT_EPHY         0x00000010
#define         GROUP0_DIAG             0x00000009
#define         GROUP0_EXT_MII          0x00000007 // presumable use
```

Code from Broadcom GPL, enabling some GPIO modes. (File `linux/arch/mips/brcm-boards/bcm963xx/setup.c`)

```
static int __init bcm6348_hw_init(void)
{
    unsigned long data;
    unsigned short GPIOOverlays;
 
    /* Set MPI clock to 33MHz and Utopia clock to 25MHz */
    data = PERF->pll_control;
    data &= ~MPI_CLK_MASK;
    data |= MPI_CLK_33MHZ;
    data &= ~MPI_UTOPIA_MASK;
    data |= MPI_UTOPIA_25MHZ; /* 6348 utopia frequency has to be 25MHZ */
    PERF->pll_control = data;
 
    /* Enable SPI interface */
    PERF->blkEnables |= SPI_CLK_EN;
 
    GPIO->GPIOMode = 0;
 
    if( BpGetGPIOverlays(&GPIOOverlays) == BP_SUCCESS ) {
 
        if (GPIOOverlays & BP_UTOPIA) {
            /* Enable UTOPIA interface */
            GPIO->GPIOMode |= GROUP4_UTOPIA | GROUP3_UTOPIA | GROUP1_UTOPIA;
            PERF->blkEnables |= SAR_CLK_EN;
        }
 
        if (GPIOOverlays & BP_MII2) {
            if (GPIOOverlays & BP_UTOPIA) {
                printk ("*************** ERROR ***************\n");
                printk ("Invalid GPIO configuration. External MII cannot be enabled with UTOPIA\n");
            }
            /* Enable external MII interface */
            GPIO->GPIOMode |= (GROUP3_EXT_MII|GROUP0_EXT_MII); /*  */
        }
 
        if (GPIOOverlays & BP_SPI_EXT_CS) {
            if (GPIOOverlays & BP_UTOPIA) {
                printk ("*************** ERROR ***************\n");
                printk ("Invalid GPIO configuration. SPI Extra CS cannot be enabled with UTOPIA\n");
            }
            /* Enable Extra SPI CS */
            GPIO->GPIOMode |= GROUP1_SPI_MASTER;
        }
 
#if defined(CONFIG_PCI)
        if (GPIOOverlays & BP_PCI) {
            /* Enable PCI interface */
            GPIO->GPIOMode |= GROUP2_PCI | GROUP1_MII_PCCARD;
 
            mpi_init();
            if (GPIOOverlays & BP_CB) {
                mpi_DetectPcCard();
            }
            else {
                /*
                 * CardBus support is defaulted to Slot 0 because there is no external
                 * IDSEL for CardBus.  To disable the CardBus and allow a standard PCI
                 * card in Slot 0 set the cbus_idsel field to 0x1f.
                */
                data = MPI->pcmcia_cntl1;
                data |= CARDBUS_IDSEL;
                MPI->pcmcia_cntl1 = data;
            }
        }
#endif
    }
```

## Devices

The list of related devices: [bcm6348](/tag/bcm6348?do=showtag&tag=bcm6348 "tag:bcm6348"), [bcm63xx](/tag/bcm63xx?do=showtag&tag=bcm63xx "tag:bcm63xx"), [gpio](/tag/gpio?do=showtag&tag=gpio "tag:gpio")

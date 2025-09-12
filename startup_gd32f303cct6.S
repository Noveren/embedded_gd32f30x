                .syntax  unified
                .arch    armv7-m
                .fpu     fpv4-sp-d16
                .thumb

                .global  g_pfnVectors
                .global  Default_Handler

                .word    _etext
                .word    __data_start__
                .word    __data_end__
                .word    __bss_start__
                .word    __bss_end__
/* Reset_Handler */
                .section .text.Reset_Handler
                .weak    Reset_Handler
                .type    Reset_Handler, %function
Reset_Handler:
                ldr      r0, =__stack
                msr      psp, r0

                ldr      r0, =__data_start__
                ldr      r1, =__data_end__
                ldr      r2, =_etext
                movs     r3, #0
                b        LoopCopyDataInit
CopyDataInit:
                ldr      r4, [r2, r3]
                str      r4, [r0, r3]
                adds     r3, r3, #4
LoopCopyDataInit:
                adds     r4, r0, r3
                cmp      r4, r1
                bcc      CopyDataInit

                ldr      r2, =__bss_start__
                ldr      r4, =__bss_end__
                movs     r3, #0
                b        LoopFillZerobss
FillZerobss:
                str      r3, [r2]
                adds     r2, r2, #4
LoopFillZerobss:
                cmp      r2, r4
                bcc      FillZerobss

                bl       SystemInit
                bl       __libc_init_array
                bl       main
                bx       lr /* TODO Loop */
                .size    Reset_Handler, .-Reset_Handler

/* Default_Handler */
                .section .text.Default_Handler,"ax",%progbits
Default_Handler:
Infinite_Loop:
                b         Infinite_Loop
                .size     Default_Handler, .-Default_Handler
/* Vector Table */
                .section .isr_vector,"a",%progbits
                .type     g_pfnVectors,%object
                .size     g_pfnVectors, .-g_pfnVectors
g_pfnVectors:
                .word     __stack
                .word     Reset_Handler

                .word     NMI_Handler                        /* -14 NMI Handler */
                .word     HardFault_Handler                  /* -13 Hard Fault Handler */
                .word     MemManage_Handler                  /* -12 MPU Fault Handler */
                .word     BusFault_Handler                   /* -11 Bus Fault Handler */
                .word     UsageFault_Handler                 /* -10 Usage Fault Handler */
                .word     0                                  /*     Reserved */
                .word     0                                  /*     Reserved */
                .word     0                                  /*     Reserved */
                .word     0                                  /*     Reserved */
                .word     SVC_Handler                        /*  -5 SVCall Handler */
                .word     DebugMon_Handler                    /*  -4 Debug Monitor Handler */
                .word     0                                  /*     Reserved */
                .word     PendSV_Handler                     /*  -2 PendSV Handler */
                .word     SysTick_Handler                    /*  -1 SysTick Handler */


                .word     WWDGT_IRQHandler                    /* 16:Window Watchdog Timer */
                .word     LVD_IRQHandler                      /* 17:LVD through EXTI Line detect */
                .word     TAMPER_IRQHandler                   /* 18:Tamper through EXTI Line detect */
                .word     RTC_IRQHandler                      /* 19:RTC through EXTI Line */
                .word     FMC_IRQHandler                      /* 20:FMC */
                .word     RCU_CTC_IRQHandler                  /* 21:RCU and CTC */
                .word     EXTI0_IRQHandler                    /* 22:EXTI Line 0 */
                .word     EXTI1_IRQHandler                    /* 23:EXTI Line 1 */
                .word     EXTI2_IRQHandler                    /* 24:EXTI Line 2 */
                .word     EXTI3_IRQHandler                    /* 25:EXTI Line 3 */
                .word     EXTI4_IRQHandler                    /* 26:EXTI Line 4 */
                .word     DMA0_Channel0_IRQHandler            /* 27:DMA0 Channel0 */
                .word     DMA0_Channel1_IRQHandler            /* 28:DMA0 Channel1 */
                .word     DMA0_Channel2_IRQHandler            /* 29:DMA0 Channel2 */
                .word     DMA0_Channel3_IRQHandler            /* 30:DMA0 Channel3 */
                .word     DMA0_Channel4_IRQHandler            /* 31:DMA0 Channel4 */
                .word     DMA0_Channel5_IRQHandler            /* 32:DMA0 Channel5 */
                .word     DMA0_Channel6_IRQHandler            /* 33:DMA0 Channel6 */
                .word     ADC0_1_IRQHandler                   /* 34:ADC0 and ADC1 */
                .word     USBD_HP_CAN0_TX_IRQHandler          /* 35:USBD HP and CAN0 TX */
                .word     USBD_LP_CAN0_RX0_IRQHandler         /* 36:USBD LP and CAN0 RX0 */
                .word     CAN0_RX1_IRQHandler                 /* 37:CAN0 RX1 */
                .word     CAN0_EWMC_IRQHandler                /* 38:CAN0 EWMC */
                .word     EXTI5_9_IRQHandler                  /* 39:EXTI5 to EXTI9 */
                .word     TIMER0_BRK_TIMER8_IRQHandler        /* 40:TIMER0 Break and TIMER8 */
                .word     TIMER0_UP_TIMER9_IRQHandler         /* 41:TIMER0 Update and TIMER9 */
                .word     TIMER0_TRG_CMT_TIMER10_IRQHandler   /* 42:TIMER0 Trigger and Commucation and TIMER10 */
                .word     TIMER0_Channel_IRQHandler           /* 43:TIMER0 Channel Capture Compare */
                .word     TIMER1_IRQHandler                   /* 44:TIMER1 */
                .word     TIMER2_IRQHandler                   /* 45:TIMER2 */
                .word     TIMER3_IRQHandler                   /* 46:TIMER3 */
                .word     I2C0_EV_IRQHandler                  /* 47:I2C0 Event */
                .word     I2C0_ER_IRQHandler                  /* 48:I2C0 Error */
                .word     I2C1_EV_IRQHandler                  /* 49:I2C1 Event */
                .word     I2C1_ER_IRQHandler                  /* 50:I2C1 Error */
                .word     SPI0_IRQHandler                     /* 51:SPI0 */
                .word     SPI1_IRQHandler                     /* 52:SPI1 */
                .word     USART0_IRQHandler                   /* 53:USART0 */
                .word     USART1_IRQHandler                   /* 54:USART1 */
                .word     USART2_IRQHandler                   /* 55:USART2 */
                .word     EXTI10_15_IRQHandler                /* 56:EXTI10 to EXTI15 */
                .word     RTC_Alarm_IRQHandler                /* 57:RTC Alarm */
                .word     USBFS_WKUP_IRQHandler               /* 58:USBFS Wakeup */
                .word     TIMER7_BRK_TIMER11_IRQHandler       /* 59:TIMER7 Break and TIMER11 */
                .word     TIMER7_UP_TIMER12_IRQHandler        /* 60:TIMER7 Update and TIMER12 */
                .word     TIMER7_TRG_CMT_TIMER13_IRQHandler   /* 61:TIMER7 Trigger and Commucation and TIMER13 */
                .word     TIMER7_Channel_IRQHandler           /* 62:TIMER7 Channel Capture Compare */
                .word     ADC2_IRQHandler                     /* 63:ADC2 */
                .word     EXMC_IRQHandler                     /* 64:EXMC */
                .word     0                                   /* 65:Reserved */
                .word     TIMER4_IRQHandler                   /* 66:TIMER4 */
                .word     SPI2_IRQHandler                     /* 67:SPI2 */
                .word     UART3_IRQHandler                    /* 68:UART3 */
                .word     0                                   /* 69:Reserved */
                .word     TIMER5_IRQHandler                   /* 70:TIMER5 */
                .word     TIMER6_IRQHandler                   /* 71:TIMER6 */
                .word     DMA1_Channel0_IRQHandler            /* 72:DMA1 Channel0 */
                .word     DMA1_Channel1_IRQHandler            /* 73:DMA1 Channel1 */
                .word     DMA1_Channel2_IRQHandler            /* 74:DMA1 Channel2 */
                .word     DMA1_Channel3_IRQHandler            /* 75:DMA1 Channel3 */
                .word     DMA1_Channel4_IRQHandler            /* 76:DMA1 Channel4 */

.macro Set_Default_Handler Handler_Name
.weak \Handler_Name
.set  \Handler_Name, Default_Handler
.endm
/*
                Set_Default_Handler     NMI_Handler
                Set_Default_Handler     HardFault_Handler
                Set_Default_Handler     MemManage_Handler
                Set_Default_Handler     BusFault_Handler
                Set_Default_Handler     UsageFault_Handler
                Set_Default_Handler     SVC_Handler
                Set_Default_Handler     DebugMon_Hanler
                Set_Default_Handler     PendSV_Handler
                Set_Default_Handler     SysTick_Handler
*/

                Set_Default_Handler  WWDGT_IRQHandler                    /* 16:Window Watchdog Timer */
                Set_Default_Handler  LVD_IRQHandler                      /* 17:LVD through EXTI Line detect */
                Set_Default_Handler  TAMPER_IRQHandler                   /* 18:Tamper through EXTI Line detect */
                Set_Default_Handler  RTC_IRQHandler                      /* 19:RTC through EXTI Line */
                Set_Default_Handler  FMC_IRQHandler                      /* 20:FMC */
                Set_Default_Handler  RCU_CTC_IRQHandler                  /* 21:RCU and CTC */
                Set_Default_Handler  EXTI0_IRQHandler                    /* 22:EXTI Line 0 */
                Set_Default_Handler  EXTI1_IRQHandler                    /* 23:EXTI Line 1 */
                Set_Default_Handler  EXTI2_IRQHandler                    /* 24:EXTI Line 2 */
                Set_Default_Handler  EXTI3_IRQHandler                    /* 25:EXTI Line 3 */
                Set_Default_Handler  EXTI4_IRQHandler                    /* 26:EXTI Line 4 */
                Set_Default_Handler  DMA0_Channel0_IRQHandler            /* 27:DMA0 Channel0 */
                Set_Default_Handler  DMA0_Channel1_IRQHandler            /* 28:DMA0 Channel1 */
                Set_Default_Handler  DMA0_Channel2_IRQHandler            /* 29:DMA0 Channel2 */
                Set_Default_Handler  DMA0_Channel3_IRQHandler            /* 30:DMA0 Channel3 */
                Set_Default_Handler  DMA0_Channel4_IRQHandler            /* 31:DMA0 Channel4 */
                Set_Default_Handler  DMA0_Channel5_IRQHandler            /* 32:DMA0 Channel5 */
                Set_Default_Handler  DMA0_Channel6_IRQHandler            /* 33:DMA0 Channel6 */
                Set_Default_Handler  ADC0_1_IRQHandler                   /* 34:ADC0 and ADC1 */
                Set_Default_Handler  USBD_HP_CAN0_TX_IRQHandler          /* 35:USBD HP and CAN0 TX */
                Set_Default_Handler  USBD_LP_CAN0_RX0_IRQHandler         /* 36:USBD LP and CAN0 RX0 */
                Set_Default_Handler  CAN0_RX1_IRQHandler                 /* 37:CAN0 RX1 */
                Set_Default_Handler  CAN0_EWMC_IRQHandler                /* 38:CAN0 EWMC */
                Set_Default_Handler  EXTI5_9_IRQHandler                  /* 39:EXTI5 to EXTI9 */
                Set_Default_Handler  TIMER0_BRK_TIMER8_IRQHandler        /* 40:TIMER0 Break and TIMER8 */
                Set_Default_Handler  TIMER0_UP_TIMER9_IRQHandler         /* 41:TIMER0 Update and TIMER9 */
                Set_Default_Handler  TIMER0_TRG_CMT_TIMER10_IRQHandler   /* 42:TIMER0 Trigger and Commucation and TIMER10 */
                Set_Default_Handler  TIMER0_Channel_IRQHandler           /* 43:TIMER0 Channel Capture Compare */
                Set_Default_Handler  TIMER1_IRQHandler                   /* 44:TIMER1 */
                Set_Default_Handler  TIMER2_IRQHandler                   /* 45:TIMER2 */
                Set_Default_Handler  TIMER3_IRQHandler                   /* 46:TIMER3 */
                Set_Default_Handler  I2C0_EV_IRQHandler                  /* 47:I2C0 Event */
                Set_Default_Handler  I2C0_ER_IRQHandler                  /* 48:I2C0 Error */
                Set_Default_Handler  I2C1_EV_IRQHandler                  /* 49:I2C1 Event */
                Set_Default_Handler  I2C1_ER_IRQHandler                  /* 50:I2C1 Error */
                Set_Default_Handler  SPI0_IRQHandler                     /* 51:SPI0 */
                Set_Default_Handler  SPI1_IRQHandler                     /* 52:SPI1 */
                Set_Default_Handler  USART0_IRQHandler                   /* 53:USART0 */
                Set_Default_Handler  USART1_IRQHandler                   /* 54:USART1 */
                Set_Default_Handler  USART2_IRQHandler                   /* 55:USART2 */
                Set_Default_Handler  EXTI10_15_IRQHandler                /* 56:EXTI10 to EXTI15 */
                Set_Default_Handler  RTC_Alarm_IRQHandler                /* 57:RTC Alarm */
                Set_Default_Handler  USBFS_WKUP_IRQHandler               /* 58:USBFS Wakeup */
                Set_Default_Handler  TIMER7_BRK_TIMER11_IRQHandler       /* 59:TIMER7 Break and TIMER11 */
                Set_Default_Handler  TIMER7_UP_TIMER12_IRQHandler        /* 60:TIMER7 Update and TIMER12 */
                Set_Default_Handler  TIMER7_TRG_CMT_TIMER13_IRQHandler   /* 61:TIMER7 Trigger and Commucation and TIMER13 */
                Set_Default_Handler  TIMER7_Channel_IRQHandler           /* 62:TIMER7 Channel Capture Compare */
                Set_Default_Handler  ADC2_IRQHandler                     /* 63:ADC2 */
                Set_Default_Handler  EXMC_IRQHandler                     /* 64:EXMC */
                /* Set_Default_Handler  0                                   65:Reserved */
                Set_Default_Handler  TIMER4_IRQHandler                   /* 66:TIMER4 */
                Set_Default_Handler  SPI2_IRQHandler                     /* 67:SPI2 */
                Set_Default_Handler  UART3_IRQHandler                    /* 68:UART3 */
                /* Set_Default_Handler  0                                   69:Reserved */
                Set_Default_Handler  TIMER5_IRQHandler                   /* 70:TIMER5 */
                Set_Default_Handler  TIMER6_IRQHandler                   /* 71:TIMER6 */
                Set_Default_Handler  DMA1_Channel0_IRQHandler            /* 72:DMA1 Channel0 */
                Set_Default_Handler  DMA1_Channel1_IRQHandler            /* 73:DMA1 Channel1 */
                Set_Default_Handler  DMA1_Channel2_IRQHandler            /* 74:DMA1 Channel2 */
                Set_Default_Handler  DMA1_Channel3_IRQHandler            /* 75:DMA1 Channel3 */
                Set_Default_Handler  DMA1_Channel4_IRQHandler            /* 76:DMA1 Channel4 */
.end

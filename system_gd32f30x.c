
#include <stdint.h>
#include <unistd.h>

#include "gd32f30x.h"

static void rcu_modify_4(int __delay);
void reset_rcu(void);
void __soft_delay__(uint32_t);
static void system_clock_120m_irc8m(void);
static void system_clock_hxtal(void);
static void system_clock_120m_hxtal(void);

void SystemInit(void) {
#if (__FPU_PRESENT == 1) && (__FPU_USED == 1)
  /* set CP10 and CP11 Full Access */
  SCB->CPACR |= ((3UL << 10 * 2) | (3UL << 11 * 2));
#endif
  reset_rcu();
  // system_clock_hxtal();
  // system_clock_120m_irc8m();
  system_clock_120m_hxtal();
  // TODO set AHB, APB1 APB2
  SystemCoreClockUpdate();
  nvic_vector_table_set(NVIC_VECTTAB_FLASH, 0);
}

static void rcu_modify_4(int __delay) {
  volatile uint32_t i, reg;
  if (0 != __delay) {
    /* Insert a software delay */
    for (i = 0; i < __delay; i++) {
    }
    reg = RCU_CFG0;
    reg &= ~(RCU_CFG0_AHBPSC);
    reg |= RCU_AHB_CKSYS_DIV2;
    /* AHB = SYSCLK/2 */
    RCU_CFG0 = reg;
    /* Insert a software delay */
    for (i = 0; i < __delay; i++) {
    }
    reg = RCU_CFG0;
    reg &= ~(RCU_CFG0_AHBPSC);
    reg |= RCU_AHB_CKSYS_DIV4;
    /* AHB = SYSCLK/4 */
    RCU_CFG0 = reg;
    /* Insert a software delay */
    for (i = 0; i < __delay; i++) {
    }
    reg = RCU_CFG0;
    reg &= ~(RCU_CFG0_AHBPSC);
    reg |= RCU_AHB_CKSYS_DIV8;
    /* AHB = SYSCLK/8 */
    RCU_CFG0 = reg;
    /* Insert a software delay */
    for (i = 0; i < __delay; i++) {
    }
    reg = RCU_CFG0;
    reg &= ~(RCU_CFG0_AHBPSC);
    reg |= RCU_AHB_CKSYS_DIV16;
    /* AHB = SYSCLK/16 */
    RCU_CFG0 = reg;
    /* Insert a software delay */
    for (i = 0; i < __delay; i++) {
    }
  }
}

void reset_rcu(void) {
  RCU_CTL |= RCU_CTL_IRC8MEN;
  while (0U == (RCU_CTL & RCU_CTL_IRC8MSTB)) {
  }
  if (((RCU_CFG0 & RCU_CFG0_SCSS) == RCU_SCSS_PLL)) {
    // The following is to prevent Vcore fluctuations caused by frequency
    // switching. It is strongly recommended to include it to avoid issues
    // caused by self-removal.
    rcu_modify_4(0x50);
  }
  RCU_CFG0 &= ~RCU_CFG0_SCS; // Select CK_IRC8M as the CK_SYS Source
  __soft_delay__(200);

#if (defined(GD32F30X_HD) || defined(GD32F30X_XD))
  // Reset HXTALEN, CKMEN and PLLEN bits
  RCU_CTL &= ~(RCU_CTL_PLLEN | RCU_CTL_CKMEN | RCU_CTL_HXTALEN);
  // Reset all interrrupt flags
  RCU_INT = 0x009f0000U;
#elif defined(GD32F30X_CL)
  // Reset HXTALEN, CKMEN, PLLEN, PLL1EN and PLL2EN bits
  RCU_CTL &= ~(RCU_CTL_PLLEN | RCU_CTL_PLL1EN | RCU_CTL_PLL2EN | RCU_CTL_CKMEN |
               RCU_CTL_HXTALEN);
  // Reset all interrrupt flags
  RCU_INT = 0x00ff0000U;
#endif
  RCU_CTL &= ~(RCU_CTL_HXTALBPS);
  RCU_CFG0 = 0x00000000U;
  RCU_CFG1 = 0x00000000U;
}

void __soft_delay__(uint32_t time) {
  volatile uint32_t i;
  for (i = 0; i < time * 10; i++) {
  }
}

static void system_clock_hxtal(void) {
  uint32_t timeout = 0U;
  uint32_t stab_flag = 0U;
  __IO uint32_t reg_temp;

  /* enable HXTAL */
  RCU_CTL |= RCU_CTL_HXTALEN;

  /* wait until HXTAL is stable or the startup time is longer than
   * HXTAL_STARTUP_TIMEOUT */
  do {
    timeout++;
    stab_flag = (RCU_CTL & RCU_CTL_HXTALSTB);
  } while ((0U == stab_flag) && (HXTAL_STARTUP_TIMEOUT != timeout));

  /* if fail */
  if (0U == (RCU_CTL & RCU_CTL_HXTALSTB)) {
    while (1) {
    }
  }

  /* AHB = SYSCLK */
  RCU_CFG0 |= RCU_AHB_CKSYS_DIV1;
  /* APB2 = AHB/1 */
  RCU_CFG0 |= RCU_APB2_CKAHB_DIV1;
  /* APB1 = AHB/2 */
  RCU_CFG0 |= RCU_APB1_CKAHB_DIV2;

  reg_temp = RCU_CFG0;
  /* select HXTAL as system clock */
  reg_temp &= ~RCU_CFG0_SCS;
  reg_temp |= RCU_CKSYSSRC_HXTAL;
  RCU_CFG0 = reg_temp;

  /* wait until HXTAL is selected as system clock */
  while (0 == (RCU_CFG0 & RCU_SCSS_HXTAL)) {
  }
}

static void system_clock_120m_irc8m(void) {
  uint32_t timeout = 0U;
  uint32_t stab_flag = 0U;
  __IO uint32_t reg_temp;

  /* enable IRC8M */
  RCU_CTL |= RCU_CTL_IRC8MEN;

  /* wait until IRC8M is stable or the startup time is longer than
   * IRC8M_STARTUP_TIMEOUT */
  do {
    timeout++;
    stab_flag = (RCU_CTL & RCU_CTL_IRC8MSTB);
  } while ((0U == stab_flag) && (IRC8M_STARTUP_TIMEOUT != timeout));

  /* if fail */
  if (0U == (RCU_CTL & RCU_CTL_IRC8MSTB)) {
    while (1) {
    }
  }

  /* LDO output voltage high mode */
  RCU_APB1EN |= RCU_APB1EN_PMUEN;
  PMU_CTL |= PMU_CTL_LDOVS;

  /* IRC8M is stable */
  /* AHB = SYSCLK */
  RCU_CFG0 |= RCU_AHB_CKSYS_DIV1;
  /* APB2 = AHB/1 */
  RCU_CFG0 |= RCU_APB2_CKAHB_DIV1;
  /* APB1 = AHB/2 */
  RCU_CFG0 |= RCU_APB1_CKAHB_DIV2;

  /* CK_PLL = (CK_IRC8M/2) * 30 = 120 MHz */
  RCU_CFG0 &= ~(RCU_CFG0_PLLMF | RCU_CFG0_PLLMF_4 | RCU_CFG0_PLLMF_5);
  RCU_CFG0 |= RCU_PLL_MUL30;

  /* enable PLL */
  RCU_CTL |= RCU_CTL_PLLEN;

  /* wait until PLL is stable */
  while (0U == (RCU_CTL & RCU_CTL_PLLSTB)) {
  }

  /* enable the high-drive to extend the clock frequency to 120 MHz */
  PMU_CTL |= PMU_CTL_HDEN;
  while (0U == (PMU_CS & PMU_CS_HDRF)) {
  }

  /* select the high-drive mode */
  PMU_CTL |= PMU_CTL_HDS;
  while (0U == (PMU_CS & PMU_CS_HDSRF)) {
  }

  reg_temp = RCU_CFG0;
  /* select PLL as system clock */
  reg_temp &= ~RCU_CFG0_SCS;
  reg_temp |= RCU_CKSYSSRC_PLL;
  RCU_CFG0 = reg_temp;

  /* wait until PLL is selected as system clock */
  while (0U == (RCU_CFG0 & RCU_SCSS_PLL)) {
  }
}

static void system_clock_120m_hxtal(void) {
  uint32_t timeout = 0U;
  uint32_t stab_flag = 0U;
  __IO uint32_t reg_temp;

  /* enable HXTAL */
  RCU_CTL |= RCU_CTL_HXTALEN;

  /* wait until HXTAL is stable or the startup time is longer than
   * HXTAL_STARTUP_TIMEOUT */
  do {
    timeout++;
    stab_flag = (RCU_CTL & RCU_CTL_HXTALSTB);
  } while ((0U == stab_flag) && (HXTAL_STARTUP_TIMEOUT != timeout));

  /* if fail */
  if (0U == (RCU_CTL & RCU_CTL_HXTALSTB)) {
    while (1) {
    }
  }

  RCU_APB1EN |= RCU_APB1EN_PMUEN;
  PMU_CTL |= PMU_CTL_LDOVS;

  /* HXTAL is stable */
  /* AHB = SYSCLK */
  RCU_CFG0 |= RCU_AHB_CKSYS_DIV1;
  /* APB2 = AHB/1 */
  RCU_CFG0 |= RCU_APB2_CKAHB_DIV1;
  /* APB1 = AHB/2 */
  RCU_CFG0 |= RCU_APB1_CKAHB_DIV2;

#if (defined(GD32F30X_HD) || defined(GD32F30X_XD))
  /* select HXTAL/2 as clock source */
  RCU_CFG0 &= ~(RCU_CFG0_PLLSEL | RCU_CFG0_PREDV0);
  RCU_CFG0 |= (RCU_PLLSRC_HXTAL_IRC48M | RCU_CFG0_PREDV0);

  /* CK_PLL = (CK_HXTAL/2) * 30 = 120 MHz */
  RCU_CFG0 &= ~(RCU_CFG0_PLLMF | RCU_CFG0_PLLMF_4 | RCU_CFG0_PLLMF_5);
  RCU_CFG0 |= RCU_PLL_MUL30;

#elif defined(GD32F30X_CL)
  /* CK_PLL = (CK_PREDIV0) * 30 = 120 MHz */
  RCU_CFG0 &= ~(RCU_CFG0_PLLMF | RCU_CFG0_PLLMF_4 | RCU_CFG0_PLLMF_5);
  RCU_CFG0 |= (RCU_PLLSRC_HXTAL_IRC48M | RCU_PLL_MUL30);

  /* CK_PREDIV0 = (CK_HXTAL)/5 *8 /10 = 4 MHz */
  RCU_CFG1 &= ~(RCU_CFG1_PLLPRESEL | RCU_CFG1_PREDV0SEL | RCU_CFG1_PLL1MF |
                RCU_CFG1_PREDV1 | RCU_CFG1_PREDV0);
  RCU_CFG1 |= (RCU_PLLPRESRC_HXTAL | RCU_PREDV0SRC_CKPLL1 | RCU_PLL1_MUL8 |
               RCU_PREDV1_DIV5 | RCU_PREDV0_DIV10);

  /* enable PLL1 */
  RCU_CTL |= RCU_CTL_PLL1EN;
  /* wait till PLL1 is ready */
  while ((RCU_CTL & RCU_CTL_PLL1STB) == 0U) {
  }
#endif /* GD32F30X_HD and GD32F30X_XD */

  /* enable PLL */
  RCU_CTL |= RCU_CTL_PLLEN;

  /* wait until PLL is stable */
  while (0U == (RCU_CTL & RCU_CTL_PLLSTB)) {
  }

  /* enable the high-drive to extend the clock frequency to 120 MHz */
  PMU_CTL |= PMU_CTL_HDEN;
  while (0U == (PMU_CS & PMU_CS_HDRF)) {
  }

  /* select the high-drive mode */
  PMU_CTL |= PMU_CTL_HDS;
  while (0U == (PMU_CS & PMU_CS_HDSRF)) {
  }

  reg_temp = RCU_CFG0;
  /* select PLL as system clock */
  reg_temp &= ~RCU_CFG0_SCS;
  reg_temp |= RCU_CKSYSSRC_PLL;
  RCU_CFG0 = reg_temp;

  /* wait until PLL is selected as system clock */
  while (0U == (RCU_CFG0 & RCU_SCSS_PLL)) {
  }
}

uint32_t SystemCoreClock;

#define SEL_IRC8M 0x00
#define SEL_HXTAL 0x01
#define SEL_PLL 0x02

void SystemCoreClockUpdate(void) {
  uint32_t sws;
  uint32_t pllsel, pllpresel, predv0sel, pllmf, ck_src, idx, clk_exp;
  /* exponent of AHB, APB1 and APB2 clock divider */
  const uint8_t ahb_exp[16] = {0, 0, 0, 0, 0, 0, 0, 0, 1, 2, 3, 4, 6, 7, 8, 9};
#ifdef GD32F30X_CL
  uint32_t predv0, predv1, pll1mf;
#endif /* GD32F30X_CL */

  sws = GET_BITS(RCU_CFG0, 2, 3);
  switch (sws) {
  /* IRC8M is selected as CK_SYS */
  case SEL_IRC8M:
    SystemCoreClock = IRC8M_VALUE;
    break;
  /* HXTAL is selected as CK_SYS */
  case SEL_HXTAL:
    SystemCoreClock = HXTAL_VALUE;
    break;
  /* PLL is selected as CK_SYS */
  case SEL_PLL:
    /* PLL clock source selection, HXTAL, IRC48M or IRC8M/2 */
    pllsel = (RCU_CFG0 & RCU_CFG0_PLLSEL);

    if (RCU_PLLSRC_HXTAL_IRC48M == pllsel) {
      /* PLL clock source is HXTAL or IRC48M */
      pllpresel = (RCU_CFG1 & RCU_CFG1_PLLPRESEL);

      if (RCU_PLLPRESRC_HXTAL == pllpresel) {
        /* PLL clock source is HXTAL */
        ck_src = HXTAL_VALUE;
      } else {
        /* PLL clock source is IRC48 */
        ck_src = IRC48M_VALUE;
      }

#if (defined(GD32F30X_HD) || defined(GD32F30X_XD))
      predv0sel = (RCU_CFG0 & RCU_CFG0_PREDV0);
      /* PREDV0 input source clock divided by 2 */
      if (RCU_CFG0_PREDV0 == predv0sel) {
        ck_src /= 2U;
      }
#elif defined(GD32F30X_CL)
      predv0sel = (RCU_CFG1 & RCU_CFG1_PREDV0SEL);
      /* source clock use PLL1 */
      if (RCU_PREDV0SRC_CKPLL1 == predv0sel) {
        predv1 = ((RCU_CFG1 & RCU_CFG1_PREDV1) >> 4) + 1U;
        pll1mf = ((RCU_CFG1 & RCU_CFG1_PLL1MF) >> 8) + 2U;
        if (17U == pll1mf) {
          pll1mf = 20U;
        }
        ck_src = (ck_src / predv1) * pll1mf;
      }
      predv0 = (RCU_CFG1 & RCU_CFG1_PREDV0) + 1U;
      ck_src /= predv0;
#endif /* GD32F30X_HD and GD32F30X_XD */
    } else {
      /* PLL clock source is IRC8M/2 */
      ck_src = IRC8M_VALUE / 2U;
    }

    /* PLL multiplication factor */
    pllmf = GET_BITS(RCU_CFG0, 18, 21);

    if ((RCU_CFG0 & RCU_CFG0_PLLMF_4)) {
      pllmf |= 0x10U;
    }
    if ((RCU_CFG0 & RCU_CFG0_PLLMF_5)) {
      pllmf |= 0x20U;
    }

    if (pllmf >= 15U) {
      pllmf += 1U;
    } else {
      pllmf += 2U;
    }
    if (pllmf > 61U) {
      pllmf = 63U;
    }
    SystemCoreClock = ck_src * pllmf;
#ifdef GD32F30X_CL
    if (15U == pllmf) {
      SystemCoreClock = (ck_src * 6U) + (ck_src / 2U);
    }
#endif /* GD32F30X_CL */
    break;
  /* IRC8M is selected as CK_SYS */
  default:
    SystemCoreClock = IRC8M_VALUE;
    break;
  }

  /* calculate AHB clock frequency */
  idx = GET_BITS(RCU_CFG0, 4, 7);
  clk_exp = ahb_exp[idx];
  SystemCoreClock = SystemCoreClock >> clk_exp;
}
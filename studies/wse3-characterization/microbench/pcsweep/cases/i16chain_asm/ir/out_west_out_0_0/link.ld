
.entry = 0;
ENTRY(.entry)
PHDRS {
  note PT_NOTE;
  pe_debug_info PT_NOTE;
  dummy PT_LOAD AT((10<<40)|(1<<20)|1);
  data_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  text_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  data_hi_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  blocked_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  active_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  blocked_ut_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  entry_cfg_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  fp_cfg_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  dds_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  s0ds_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  s1ds_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  xds_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  sr_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  ce_in_q_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  ce_out_q_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  prng_state_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  filters_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  routing.fab_map_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  routing.fab_switch_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  user_cfg_0_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  user_cfg_1_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  user_cfg_2_0 PT_LOAD AT((10<<40)|(1<<20)|1);
  user_cfg_3_0 PT_LOAD AT((10<<40)|(1<<20)|1);
}
SECTIONS {
.note : {
  QUAD(0x0000000800000009);
  QUAD(0x6572654300000001);
  QUAD(0x0000000073617262);
  LONG(8);
  LONG(3);
} : note
 .pe_debug_info : {
QUAD(0x616e656c6966227b);
QUAD(0x62632f223a22656d);
QUAD(0x6168636c6f6f742f);
QUAD(0x616c73632f736e69);
QUAD(0x732d6c65722f676e);
QUAD(0x2e30312e322d6b64);
QUAD(0x3430363230322f30);
QUAD(0x312d353133323130);
QUAD(0x343933312d333138);
QUAD(0x6c73632f61653661);
QUAD(0x75722f7362696c2d);
QUAD(0x65642f656d69746e);
QUAD(0x632e314e5f78756d);
QUAD(0x6c6f63222c226c73);
QUAD(0x226f666e695f726f);
QUAD(0x3a226469227b5b3a);
QUAD(0x5b3a227872222c31);
QUAD(0x2c5d227473657722);
QUAD(0x72225b3a22787422);
QUAD(0x6b222c5d22706d61);
QUAD(0x6d616e5f6e776f6e);
QUAD(0x5852225b3a227365);
QUAD(0x7b2c7d5d22544341);
QUAD(0x222c323a22646922);
QUAD(0x6172225b3a227872);
QUAD(0x7874222c5d22706d);
QUAD(0x74736165225b3a22);
QUAD(0x776f6e6b222c5d22);
QUAD(0x2273656d616e5f6e);
QUAD(0x5443415854225b3a);
LONG(0x5d7d5d22);
BYTE(0x7d);
} : pe_debug_info
. = 0x0;
.dummy : {} :dummy
/DISCARD/ : { *(.data.rel.ro); }
.data.lo : {
  *(.data.scratch);
  *(.data.lo*);
} :data_0
ASSERT(. <= 0x400, "data.lo doesn't fit in 1024 bytes")
.text ALIGN(8) : {
  *(.text);
  ASSERT(ABSOLUTE(.) <= 0xC000,
         "ran out of PE memory for code (section .text) ");
} :text_0
.data : {
  *(.data);
  *(.rodata*);
  ASSERT(ABSOLUTE(.) <= 0xC000,
         "ran out of PE memory for data (section .data) ");
} :data_0
.bss : {
  *(.bss*);
  ASSERT(ABSOLUTE(.) <= 0xC000,
         "ran out of PE memory for data (section .bss) ");
} :data_0
/DISCARD/ : { *(.cs.cfg.*); }

  .task_table ALIGN(16) : {
    __task_table = .;
    /*color: 0*/ *(.section.task_table.nops.0);
    /*color: 1*/ *(.section.task_table.nops.1);
    /*color: 2*/ *(.section.task_table.nops.2);
    /*color: 3*/ *(.section.task_table.nops.3);
    /*color: 4*/ *(.section.task_table.nops.4);
    /*color: 5*/ *(.section.task_table.nops.5);
    /*color: 6*/ *(.section.task_table.nops.6);
    /*color: 7*/ *(.section.task_table.nops.7);
    /*color: 8*/ *(.section.task_table.nops.8);
    /*color: 9*/ *(.section.task_table.nops.9);
    /*color: 10*/ *(.section.task_table.nops.10);
    /*color: 11*/ *(.section.task_table.nops.11);
    /*color: 12*/ *(.section.task_table.nops.12);
    /*color: 13*/ *(.section.task_table.nops.13);
    /*color: 14*/ *(.section.task_table.nops.14);
    /*color: 15*/ *(.section.task_table.nops.15);
    /*color: 16*/ *(.section.task_table.nops.16);
    /*color: 17*/ *(.section.task_table.nops.17);
    /*color: 18*/ *(.section.task_table.nops.18);
    /*color: 19*/ *(.section.task_table.nops.19);
    /*color: 20*/ *(.section.task_table.nops.20);
    /*color: 21*/ *(.section.task_table.nops.21);
    /*color: 22*/ *(.section.task_table.nops.22);
    /*color: 23*/ *(.section.task_table.nops.23);
    /*color: 24*/ *(.section.task_table.nops.24);
    /*color: 25*/ *(.section.trampoline.f_startup);
    /*color: 26*/ *(.section.trampoline.f_config);
    /*color: 27*/ *(.section.trampoline.f_txact_next_tensor);
    /*color: 28*/ *(.section.trampoline.f_txact_next_chunk);
    /*color: 29*/ *(.section.task_table.nops.29);
    /*color: 30*/ *(.section.task_table.nops.30);
    /*color: 31*/ *(.section.task_table.nops.31);
    /*color: 32*/ *(.section.task_table.nops.32);
    /*color: 33*/ *(.section.task_table.nops.33);
    /*color: 34*/ *(.section.task_table.nops.34);
    /*color: 35*/ *(.section.task_table.nops.35);
    /*color: 36*/ *(.section.task_table.nops.36);
    /*color: 37*/ *(.section.task_table.nops.37);
    /*color: 38*/ *(.section.task_table.nops.38);
    /*color: 39*/ *(.section.task_table.nops.39);
    /*color: 40*/ *(.section.task_table.nops.40);
    /*color: 41*/ *(.section.task_table.nops.41);
    /*color: 42*/ *(.section.task_table.nops.42);
    /*color: 43*/ *(.section.task_table.nops.43);
    /*color: 44*/ *(.section.task_table.nops.44);
    /*color: 45*/ *(.section.task_table.nops.45);
    /*color: 46*/ *(.section.task_table.nops.46);
    /*color: 47*/ *(.section.task_table.nops.47);
    /*color: 48*/ *(.section.task_table.nops.48);
    /*color: 49*/ *(.section.task_table.nops.49);
    /*color: 50*/ *(.section.task_table.nops.50);
    /*color: 51*/ *(.section.task_table.nops.51);
    /*color: 52*/ *(.section.task_table.nops.52);
    /*color: 53*/ *(.section.task_table.nops.53);
    /*color: 54*/ *(.section.task_table.nops.54);
    /*color: 55*/ *(.section.task_table.nops.55);
    /*color: 56*/ *(.section.task_table.nops.56);
    /*color: 57*/ *(.section.task_table.nops.57);
    /*color: 58*/ *(.section.task_table.nops.58);
    /*color: 59*/ *(.section.task_table.nops.59);
    /*color: 60*/ *(.section.task_table.nops.60);
    /*color: 61*/ *(.section.task_table.nops.61);
    /*color: 62*/ *(.section.task_table.nops.62);
    /*color: 63*/ *(.section.task_table.nops.63);

    ASSERT(ABSOLUTE(.) <= 0xC000, "ran out of PE memory for task table");
  }
  .data.hi : {
    *(.data.hi*)
    ASSERT(ABSOLUTE(.) <= 0xC000,
           "ran out of PE memory for data (section .data.hi) ");
  } :data_hi_0
  /* configuration space addresses, byte addressed */

  /* Task Table */
  .entry_ival 0xfc3c : {
    SHORT(__task_table >> 1);
  } :entry_cfg_0
  /* Floating point control word */
  .fpcw 0xfc18 : {
    SHORT(0x3c0);
  } :fp_cfg_0
  /* Fscale configuration */
  .fscale 0xfc1a : {
    SHORT(0x0);
  } :fp_cfg_0
  /* Blocked ids */
  .blocked_ival 0xfc08 : {
    LONG(0xff);
  } :blocked_0
  /* Active ids */
  .active_ival 0xfc0c : {
    LONG(0x2000000);
  } :active_0
  /* Blocked microthread ids */
  .blocked_ut_ival 0xfc04 : {
    LONG(0x0);
  } :blocked_ut_0

  .fabric_routes (0xf800) : {
QUAD(0xa00082001000a0);
QUAD(0xa000a000a000a0);
QUAD(0xa000a000a000a0);
QUAD(0xa000a000a000a0);
QUAD(0xa000a000a000a0);
QUAD(0xa000a000a000a0);
  } :routing.fab_map_0
  .fabric_switches (0xf900) : {
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
QUAD(0xa0a000a0);
  } :routing.fab_switch_0

  .ce_in_q 0xf780 : {
    . = ADDR(.ce_in_q) + 0x0; LONG(0x100041);
  } :ce_in_q_0

  .ce_out_q 0xf700 : {
    . = ADDR(.ce_out_q) + 0x0; SHORT(0x20);
  } :ce_out_q_0

 .prng_state 0xfba0 : {
QUAD(0xdeadbeefdeadbeef);
QUAD(0xdeadbeefdeadbeef);
  } :prng_state_0

 .filters (0xf680) : {
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
QUAD(0x0);
  } :filters_0

 .user_cfg_0 (0xfc10) : {
SHORT(0x0);
  } :user_cfg_0_0

 .user_cfg_1 (0xfc12) : {
SHORT(0x0);
  } :user_cfg_1_0

 .user_cfg_2 (0xfc24) : {
SHORT(0xf81c);
  } :user_cfg_2_0

 .user_cfg_3 (0xfc3e) : {
SHORT(0x184);
  } :user_cfg_3_0
}

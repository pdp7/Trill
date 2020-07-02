;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: Timer16_1.asm
;;   Version: 1.1, Updated on 2015/3/4 at 22:18:32
;;  Generated by PSoC Designer 5.4.3191
;;
;;  DESCRIPTION: Timer16 User Module software implementation file
;;
;;  NOTE: User Module APIs conform to the fastcall16 convention for marshalling
;;        arguments and observe the associated "Registers are volatile" policy.
;;        This means it is the caller's responsibility to preserve any values
;;        in the X and A registers that are still needed after the API functions
;;        returns. For Large Memory Model devices it is also the caller's 
;;        responsibility to perserve any value in the CUR_PP, IDX_PP, MVR_PP and 
;;        MVW_PP registers. Even though some of these registers may not be modified
;;        now, there is no guarantee that will remain the case in future releases.
;;-----------------------------------------------------------------------------
;;  Copyright (c) Cypress Semiconductor 2015. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "memory.inc"
include "Timer16_1.inc"

;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
export  Timer16_1_EnableInt
export _Timer16_1_EnableInt
export  Timer16_1_DisableInt
export _Timer16_1_DisableInt
export  Timer16_1_Start
export _Timer16_1_Start
export  Timer16_1_Stop
export _Timer16_1_Stop
export  Timer16_1_SetMode
export _Timer16_1_SetMode
export  Timer16_1_SetPeriod
export _Timer16_1_SetPeriod


AREA trill_craft_RAM (RAM,REL)

;-----------------------------------------------
;  Constant Definitions
;-----------------------------------------------


;-----------------------------------------------
; Variable Allocation
;-----------------------------------------------


AREA UserModules (ROM, REL)

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: Timer16_1_EnableInt
;
;  DESCRIPTION:
;     Enables this timer's interrupt by setting the interrupt enable mask bit
;     associated with this User Module. This function has no effect until and
;     unless the global interrupts are enabled (for example by using the
;     macro M8C_EnableGInt).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None.
;  RETURNS:      Nothing.
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 Timer16_1_EnableInt:
_Timer16_1_EnableInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   M8C_EnableIntMask    Timer16_1_INT_REG, Timer16_1_INT_MASK ; Enable the interrupt
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: Timer16_1_DisableInt
;
;  DESCRIPTION:
;     Disables this timer's interrupt by clearing the interrupt enable
;     mask bit associated with this User Module.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 Timer16_1_DisableInt:
_Timer16_1_DisableInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   M8C_DisableIntMask    Timer16_1_INT_REG, Timer16_1_INT_MASK ; Disable the interrupt
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: Timer16_1_Start
;
;  DESCRIPTION:
;     Sets the start bit in the Control register of this user module.  The
;     timer will begin counting on the next input clock.
;
;     The timer will begin to run with default Mode and Period values set in
;    Parameters section of the Device Editor, or programmatically with SetMode,
;    or SetPeriod.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: A   The Mode Value
;
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 Timer16_1_Start:
_Timer16_1_Start:
   RAM_PROLOGUE RAM_USE_CLASS_1
   or reg[Timer16_1_CONFIG_REG], PT_CFG_START  ; Set the Start bit
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: Timer16_1_Stop
;
;  DESCRIPTION:
;     Disables timer operation by clearing the start bit in the Control
;     register.
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None
;  RETURNS:      Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 Timer16_1_Stop:
_Timer16_1_Stop:
   RAM_PROLOGUE RAM_USE_CLASS_1
   and reg[Timer16_1_CONFIG_REG], ~PT_CFG_START ; Clear the Start bit
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: Timer16_1_SetMode
;
;  DESCRIPTION:
;     Set the 16-bit period value into the Programmable Timer Configuration 
;     register.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:  Pass PT_CFG_One_Shot, or 0x00 as defined in M8C.h
;
;  RETURNS:   Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 Timer16_1_SetMode:
_Timer16_1_SetMode:
   RAM_PROLOGUE RAM_USE_CLASS_4
   cmp A, 0x00                         ; Check if 0x00 then mode is continuous
   jz .Continuous
   or reg[Timer16_1_CONFIG_REG], PT_CFG_One_Shot ; Set the Mode bit in the PT_CFG register
   jmp .exit  
.Continuous:
   and reg[Timer16_1_CONFIG_REG], ~PT_CFG_One_Shot  ; Set the Mode bit in the PT_CFG register
.exit:
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret

.ENDSECTION


                
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: Timer16_1_SetPeriod
;
;  DESCRIPTION:
;     Set the 16-bit period value into the Period register (DR1). If the
;     Timer user module is stopped, then this value will also be latched
;     into the Count register (DR0).
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: fastcall16 WORD bPeriodValue (passed in A)
;  RETURNS:   Nothing
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;
 Timer16_1_SetPeriod:
_Timer16_1_SetPeriod:
   RAM_PROLOGUE RAM_USE_CLASS_1
    mov     REG[Timer16_1_DATA0_REG], A; Set the reload LSB first
    swap    A, X                       ; Get the MSB
    mov     REG[Timer16_1_DATA1_REG], A; Set the reload MSB
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION


; End of File Timer16_1.asm

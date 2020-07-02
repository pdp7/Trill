;;*****************************************************************************
;;*****************************************************************************
;;  FILENAME: EzI2Cs.asm
;;   Version: 1.40, Updated on 2012/9/21 at 11:56:12
;;  Generated by PSoC Designer 5.3.2710
;;
;;  DESCRIPTION: EzI2Cs User Module software implementation file
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
;;  Copyright (c) Cypress Semiconductor 2012. All Rights Reserved.
;;*****************************************************************************
;;*****************************************************************************

include "m8c.inc"
include "memory.inc"
include "EzI2Cs.inc"
include "PSoCGPIOINT.inc"

;-----------------------------------------------
; include instance specific register definitions
;-----------------------------------------------

;-----------------------------------------------
;  Global Symbols
;-----------------------------------------------
;-------------------------------------------------------------------
;  Declare the functions global for both assembler and C compiler.
;
;  Note that there are two names for each API. First name is
;  assembler reference. Name with underscore is name refence for
;  C compiler.  Calling function in C source code does not require
;  the underscore.
;-------------------------------------------------------------------

export    EzI2Cs_EnableInt
export   _EzI2Cs_EnableInt
export    EzI2Cs_ResumeInt
export   _EzI2Cs_ResumeInt
export    EzI2Cs_Start
export   _EzI2Cs_Start

export    EzI2Cs_DisableInt
export   _EzI2Cs_DisableInt
export    EzI2Cs_Stop
export   _EzI2Cs_Stop
export    EzI2Cs_DisableSlave
export   _EzI2Cs_DisableSlave
export    EzI2Cs_SetRamBuffer
export   _EzI2Cs_SetRamBuffer
export    EzI2Cs_GetAddr
export   _EzI2Cs_GetAddr
export    EzI2Cs_GetActivity
export   _EzI2Cs_GetActivity


IF (EzI2Cs_DYNAMIC_ADDR) ;; Enable this function only if Address is Dynamic
export    EzI2Cs_SetAddr
export   _EzI2Cs_SetAddr
ENDIF

IF (EzI2Cs_ROM_ENABLE)  ;; Enable only if alternate ROM Address is Enabled
export    EzI2Cs_SetRomBuffer
export   _EzI2Cs_SetRomBuffer
ENDIF

IF (EzI2Cs_CY8C20xx7)
export   EzI2Cs_SetAutoNACK
export  _EzI2Cs_SetAutoNACK
export   EzI2Cs_ClearAutoNACK
export  _EzI2Cs_ClearAutoNACK
export   EzI2Cs_bCheckStatus
export  _EzI2Cs_bCheckStatus
ENDIF

AREA UserModules (ROM, REL, CON)

.SECTION

;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_Start
;
;  DESCRIPTION:
;   Initialize the EzI2Cs I2C bus interface.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:
;
;  RETURNS: none
;
;  SIDE EFFECTS:
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;    IN THE LARGE MEMORY MODEL CURRENTLY ONLY THE PAGE POINTER 
;    REGISTERS LISTED BELOW ARE MODIFIED.  THIS DOES NOT GUARANTEE 
;    THAT IN FUTURE IMPLEMENTATIONS OF THIS FUNCTION OTHER PAGE POINTER 
;    REGISTERS WILL NOT BE MODIFIED.
;          
;    Page Pointer Registers Modified: 
;          CUR_PP
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_Start:
_EzI2Cs_Start:   
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_SETPAGE_CUR >EzI2Cs_varPage
   
IF (EzI2Cs_DYNAMIC_ADDR) ;; DYNAMIC ADDRESS
 IF (EzI2Cs_HW_ADDR_REC ^ 1) ; IF _NO_ HW ADDRESS RECOGNITION
   mov [EzI2Cs_bAddr], EzI2Cs_SLAVE_ADDR
 ENDIF  
ENDIF

   M8C_SetBank1 ;The SDA and SCL pins are setting to Hi-z drive mode
   and reg[EzI2CsSDA_DriveMode_0_ADDR],~(EzI2CsSDA_MASK|EzI2CsSCL_MASK)
   or  reg[EzI2CsSDA_DriveMode_1_ADDR], (EzI2CsSDA_MASK|EzI2CsSCL_MASK)
   M8C_SetBank0
   
   and   [Port_1_Data_SHADE], ~(EzI2CsSDA_MASK|EzI2CsSCL_MASK)
   mov   A, [Port_1_Data_SHADE]
   mov   reg[EzI2CsSDA_Data_ADDR], A

   mov   [EzI2Cs_bBusy_Flag],EzI2Cs_I2C_FREE ;; Clear Busy flag

IF (EzI2Cs_CY8C20xx7)
   or   reg[EzI2Cs_XCFG_REG], EzI2Cs_CSR_CLK_EN ; enable clock to I2C block
ENDIF
   
   call  EzI2Cs_EnableInt
   call  EzI2Cs_EnableSlave
   
   nop
   nop
   nop
   nop
   nop
   
   mov   A, 0
   mov   [EzI2Cs_bRAM_RWoffset], A
IF (EzI2Cs_ROM_ENABLE)
   mov   [EzI2Cs_bROM_RWoffset], A
ENDIF
   
   M8C_SetBank1 ;The SDA and SCL pins are restored to Open Drain Low drive mode
   or   reg[EzI2CsSDA_DriveMode_0_ADDR], (EzI2CsSDA_MASK|EzI2CsSCL_MASK)
   or   reg[EzI2CsSDA_DriveMode_1_ADDR], (EzI2CsSDA_MASK|EzI2CsSCL_MASK)
   M8C_SetBank0
   
   or   [Port_1_Data_SHADE] , (EzI2CsSDA_MASK|EzI2CsSCL_MASK)
   mov  A, [Port_1_Data_SHADE]
   mov  reg[EzI2CsSDA_Data_ADDR], A
   
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret

.ENDSECTION

IF (EzI2Cs_DYNAMIC_ADDR)  ;; DYNAMIC ADDRESS
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_SetAddr(BYTE bAddr)
;
;  DESCRIPTION:
;   Set the I2C slave address for the EzI2Cs I2C bus interface.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:
;      A =>  Slave address
;
;  RETURNS: none
;
;  SIDE EFFECTS;    
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;    IN THE LARGE MEMORY MODEL CURRENTLY ONLY THE PAGE POINTER 
;    REGISTERS LISTED BELOW ARE MODIFIED.  THIS DOES NOT GUARANTEE 
;    THAT IN FUTURE IMPLEMENTATIONS OF THIS FUNCTION OTHER PAGE POINTER 
;    REGISTERS WILL NOT BE MODIFIED.
;          
;    Page Pointer Registers Modified: 
;          CUR_PP
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_SetAddr:
_EzI2Cs_SetAddr:
IF (EzI2Cs_HW_ADDR_REC) ; HW ADDRESS RECOGNITION
   mov   reg[EzI2Cs_ADDR_REG], A
ELSE 
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_SETPAGE_CUR >EzI2Cs_bAddr
   asl   A
   mov   [EzI2Cs_bAddr],A
   RAM_EPILOGUE RAM_USE_CLASS_4
ENDIF
   ret

.ENDSECTION
ENDIF

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME:BYTE EzI2Cs_GetActivity(void)
;
;  DESCRIPTION:
;    Return a non-zero value if the I2C hardware has seen activity on the bus.
;    The activity flag will be cleared if set when calling this function.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:  none
;
;  RETURNS: 
;    BYTE  non-zero = Activity
;          zero     = No Activity
;
;  SIDE EFFECTS;    
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;    IN THE LARGE MEMORY MODEL CURRENTLY ONLY THE PAGE POINTER 
;    REGISTERS LISTED BELOW ARE MODIFIED.  THIS DOES NOT GUARANTEE 
;    THAT IN FUTURE IMPLEMENTATIONS OF THIS FUNCTION OTHER PAGE POINTER 
;    REGISTERS WILL NOT BE MODIFIED.
;          
;    Page Pointer Registers Modified: 
;          CUR_PP
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_GetActivity:
_EzI2Cs_GetActivity:
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_SETPAGE_CUR >EzI2Cs_bState
   mov   A,[EzI2Cs_bState]
   and   A,EzI2Cs_ACTIVITY_MASK         ; Mask off activity bits
   and   [EzI2Cs_bState],~EzI2Cs_ACTIVITY_MASK ; Clear system activity bits

EzI2Cs_GetActivity_End:
   RAM_EPILOGUE RAM_USE_CLASS_4
   ret

.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: BYTE EzI2Cs_GetAddr(Void)
;
;  DESCRIPTION:
;   Get the I2C slave address for the EzI2Cs I2C bus interface.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS;    
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;    IN THE LARGE MEMORY MODEL CURRENTLY ONLY THE PAGE POINTER 
;    REGISTERS LISTED BELOW ARE MODIFIED.  THIS DOES NOT GUARANTEE 
;    THAT IN FUTURE IMPLEMENTATIONS OF THIS FUNCTION OTHER PAGE POINTER 
;    REGISTERS WILL NOT BE MODIFIED.
;          
;    Page Pointer Registers Modified: 
;          CUR_PP
;
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_GetAddr:
_EzI2Cs_GetAddr:

IF (EzI2Cs_DYNAMIC_ADDR)  ;; DYNAMIC ADDRESS
 IF (EzI2Cs_HW_ADDR_REC) ; HW ADDRESS RECOGNITION
   mov   A, reg[EzI2Cs_ADDR_REG]
 ELSE 
   RAM_PROLOGUE RAM_USE_CLASS_4
   RAM_SETPAGE_CUR >EzI2Cs_bAddr
   mov   A,[EzI2Cs_bAddr]
   asr   A                          ; Shift Addr to right to drop RW bit.
   and   A,0x7F                     ; Mask off bogus MSb
   RAM_EPILOGUE RAM_USE_CLASS_4
 ENDIF
ELSE
   mov   A, 0x0            
ENDIF
   ret

.ENDSECTION



.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_EnableInt
;  FUNCTION NAME: EzI2Cs_ResumeInt
;
;  DESCRIPTION:
;     Enables SDA interrupt allowing start condition detection. Remember to call the
;     global interrupt enable function by using the macro: M8C_EnableGInt.
;	  EzI2Cs_ResumeInt performs the enable int function without fist clearing
;     pending interrupts.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS: REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;  THEORY of OPERATION or PROCEDURE:
;
 EzI2Cs_ResumeInt:
_EzI2Cs_ResumeInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   jmp ResumeEntry

 EzI2Cs_EnableInt:
_EzI2Cs_EnableInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   ;first clear any pending interrupts
   and   reg[EzI2Cs_INT_REG], ~EzI2Cs_INT_MASK 
ResumeEntry:
   M8C_EnableIntMask EzI2Cs_INT_REG, EzI2Cs_INT_MASK
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_EnableSlave
;
;  DESCRIPTION:
;     Enables SDA interrupt allowing start condition detection. Remember to call the
;     global interrupt enable function by using the macro: M8C_EnableGInt.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS: REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_EnableSlave:
_EzI2Cs_EnableSlave:

    RAM_PROLOGUE RAM_USE_CLASS_1
    ; Enable I2C Slave
    or   reg[EzI2Cs_CFG_REG],(EzI2Cs_CFG_Slave_EN | EzI2Cs_CFG_BUS_ERROR_IE | EzI2Cs_CFG_STOP_IE)
    RAM_EPILOGUE RAM_USE_CLASS_1
    ret

.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_DisableInt
;  FUNCTION NAME: EzI2Cs_Stop
;
;  DESCRIPTION:
;     Disables EzI2Cs slave by disabling SDA interrupt
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS: REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_Stop:
_EzI2Cs_Stop:
   RAM_PROLOGUE RAM_USE_CLASS_1

   M8C_DisableIntMask EzI2Cs_INT_REG, EzI2Cs_INT_MASK
   and  reg[EzI2Cs_CFG_REG],~EzI2Cs_CFG_Slave_EN
IF (EzI2Cs_CY8C20xx7)
   and   reg[EzI2Cs_XCFG_REG], ~EzI2Cs_CSR_CLK_EN ; Disable clock to I2C block
ENDIF
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION



.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_DisableInt
;  FUNCTION NAME: EzI2Cs_Stop
;
;  DESCRIPTION:
;     Disables EzI2Cs slave by disabling SDA interrupt
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS: REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_DisableInt:
_EzI2Cs_DisableInt:
   RAM_PROLOGUE RAM_USE_CLASS_1
   M8C_DisableIntMask EzI2Cs_INT_REG, EzI2Cs_INT_MASK
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: EzI2Cs_DisableSlave
;
;  DESCRIPTION:
;     Disables EzI2Cs slave by disabling SDA interrupt
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS: REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;
;  THEORY of OPERATION or PROCEDURE:
;

 EzI2Cs_DisableSlave:
_EzI2Cs_DisableSlave:
   RAM_PROLOGUE RAM_USE_CLASS_1
   and  reg[EzI2Cs_CFG_REG],~EzI2Cs_CFG_Slave_EN
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret

.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: 
;          void EzI2Cs_SetRamBuffer(BYTE bSize, BYTE bRWboundry, BYTE * pAddr)
;
;  DESCRIPTION:
;     Sets the location and size of the I2C RAM buffer.          
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: 
;     [SP-3] =>  Size of data structure
;     [SP-4] =>  R/W boundary of (Must be less than or equal to size.)
;     [SP-5] =>  LSB of data pointer
;     [SP-6] =>  MSB of data pointer (Only used for large memory model)
;
;  RETURNS: none
;
;  SIDE EFFECTS;    
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;    IN THE LARGE MEMORY MODEL CURRENTLY ONLY THE PAGE POINTER 
;    REGISTERS LISTED BELOW ARE MODIFIED.  THIS DOES NOT GUARANTEE 
;    THAT IN FUTURE IMPLEMENTATIONS OF THIS FUNCTION OTHER PAGE POINTER 
;    REGISTERS WILL NOT BE MODIFIED.
;          
;    Page Pointer Registers Modified: 
;          CUR_PP
;
;  THEORY of OPERATION or PROCEDURE:
;

; Stack offset constants
RAMBUF_SIZE:   equ  -3   ; Stack position for data structure size.
RW_SIZE:       equ  -4   ; Stack position for R/W area size.       
RAMPTR_LSB:    equ  -5   ; Stack position for RAM pointer LSB.   
RAMPTR_MSB:    equ  -6   ; Stack position for RAM pointer MSB.   

 EzI2Cs_SetRamBuffer:
_EzI2Cs_SetRamBuffer:

    RAM_PROLOGUE RAM_USE_CLASS_4
    RAM_PROLOGUE RAM_USE_CLASS_2
    RAM_SETPAGE_CUR >EzI2Cs_bRAM_Buf_Size    ; Set page to global var page.
                                                        ; All these globals should be
                                                        ; on the same page.          
    mov   X,SP
    mov   A,[X+RAMBUF_SIZE]
    mov   [EzI2Cs_bRAM_Buf_Size],A           ; Store the buffer size

    mov   A,[X+RW_SIZE]                            ; Store R/W boundary             
    mov   [EzI2Cs_bRAM_Buf_WSize],A          ; 
    
    mov   A,[X+RAMPTR_LSB]                         ; Store only LSB of data pointer
    mov   [EzI2Cs_pRAM_Buf_Addr_LSB],A       ; 

IF (SYSTEM_LARGE_MEMORY_MODEL)                             ; Only worry about the address MSB
                                                           ; if in the large memory Model
    mov   A,[X+RAMPTR_MSB]                         ; Store only MSB of data pointer
    mov   [EzI2Cs_pRAM_Buf_Addr_MSB],A       ; 
ENDIF

    RAM_EPILOGUE RAM_USE_CLASS_2
    RAM_EPILOGUE RAM_USE_CLASS_4
    ret

.ENDSECTION

IF (EzI2Cs_ROM_ENABLE)  ;; Enable only if alternate ROM Address is Enabled
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: 
;          void EzI2Cs_SetRomBuffer(BYTE bSize, BYTE * pAddr)
;
;  DESCRIPTION:
;     Sets the location and size of the I2C ROM buffer.          
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: 
;     [SP-3] =>  Size of data const data structure
;     [SP-4] =>  LSB of data pointer
;     [SP-5] =>  MSB of data pointer (Only used for large memory model)
;
;  RETURNS: none
;
;  SIDE EFFECTS;    
;    REGISTERS ARE VOLATILE: THE A AND X REGISTERS MAY BE MODIFIED!
;    IN THE LARGE MEMORY MODEL CURRENTLY ONLY THE PAGE POINTER 
;    REGISTERS LISTED BELOW ARE MODIFIED.  THIS DOES NOT GUARANTEE 
;    THAT IN FUTURE IMPLEMENTATIONS OF THIS FUNCTION OTHER PAGE POINTER 
;    REGISTERS WILL NOT BE MODIFIED.
;          
;    Page Pointer Registers Modified: 
;          CUR_PP
;
;  THEORY of OPERATION or PROCEDURE:
;

; Stack offset constants
ROMBUF_SIZE:   equ  -3   ; Stack position for data structure size.
ROMPTR_LSB:    equ  -4   ; Stack position for ROM pointer LSB.   
ROMPTR_MSB:    equ  -5   ; Stack position for ROM pointer MSB.   

 EzI2Cs_SetRomBuffer:
_EzI2Cs_SetRomBuffer:

    RAM_PROLOGUE RAM_USE_CLASS_4
    RAM_PROLOGUE RAM_USE_CLASS_2
    RAM_SETPAGE_CUR >EzI2Cs_bROM_Buf_Size    ; Set page to global var page.
                                                        ; All these globals should be
                                                        ; on the same page.          
    mov   X,SP
    mov   A,[X+ROMBUF_SIZE]
    mov   [EzI2Cs_bROM_Buf_Size],A           ; Store the buffer size

    mov   A,[X+ROMPTR_LSB]                         ; Store LSB of data pointer
    mov   [EzI2Cs_pROM_Buf_Addr_LSB],A       ; 
    mov   A,[X+ROMPTR_MSB]                         ; Store MSB of data pointer
    mov   [EzI2Cs_pROM_Buf_Addr_MSB],A       ; 
    RAM_EPILOGUE RAM_USE_CLASS_2
    RAM_EPILOGUE RAM_USE_CLASS_4
    ret

.ENDSECTION
ENDIF

IF (EzI2Cs_CY8C20xx7)
.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: void  EzI2Cs_SetAutoNACK(void)
;
;  DESCRIPTION:
;   Set respective bit to engage the auto NACK (also referred as force NACK) 
;   feature in I2C slave block. Auto NACK may not be activated immediately 
;   and will be active only upon the next byte boundary.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
 EzI2Cs_SetAutoNACK:
_EzI2Cs_SetAutoNACK:
   RAM_PROLOGUE RAM_USE_CLASS_1
   or    reg[EzI2Cs_XCFG_REG], EzI2Cs_FORCE_NACK  ; Set the FORCE_NACK bit
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret
.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: void  EzI2Cs_ClearAutoNACK(void)
;
;  DESCRIPTION:
;   Clear respective bit to disable auto NACK feature in I2C slave block.
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS: none
;
;  RETURNS: none
;
;  SIDE EFFECTS:
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to perserve their values across calls to fastcall16 
;    functions.
;          
 EzI2Cs_ClearAutoNACK:
_EzI2Cs_ClearAutoNACK:
   RAM_PROLOGUE RAM_USE_CLASS_1
   and    reg[EzI2Cs_XCFG_REG], ~EzI2Cs_FORCE_NACK   ; Clear the FORCE_NACK bit
   RAM_EPILOGUE RAM_USE_CLASS_1
   ret
.ENDSECTION

.SECTION
;-----------------------------------------------------------------------------
;  FUNCTION NAME: BYTE  EzI2Cs_bCheckStatus(void)
;
;  DESCRIPTION:
;  Returns a value that indicates status of I2C data transaction. 
;
;-----------------------------------------------------------------------------
;
;  ARGUMENTS:    None.
;
;  RETURNS:      A - Contains the status
;                    
;  SIDE EFFECTS: 
;    The A and X registers may be modified by this or future implementations
;    of this function.  The same is true for all RAM page pointer registers in
;    the Large Memory Model.  When necessary, it is the calling function's
;    responsibility to preserve their values across calls to fastcall16 
;    functions.
;-----------------------------------------------------------------------------
 EzI2Cs_bCheckStatus:
_EzI2Cs_bCheckStatus:
    RAM_PROLOGUE RAM_USE_CLASS_1
    mov   A, reg[EzI2Cs_XSTAT_REG]                ; Get the EzI2Cs_XSTAT value
    and   A, (EzI2Cs_AUTO_NACK_ON | EzI2Cs_BUS_BUSY | EzI2Cs_LAST_TX_RD | EzI2Cs_LAST_TX_WR)   ; Mask only desired bits
    RAM_EPILOGUE RAM_USE_CLASS_1
   ret
.ENDSECTION
ENDIF

; End of File EzI2Cs.asm

; BEGIN CONSTANT DEFINITIONS
MBR_PT_OFFSET EQU 446      ; MBR partition table offset
MBR_PTE_SIZE EQU 16        ; MBR partition table entry size
MBR_SIZE EQU 512           ; Size of the MBR
VBR_ADDRESS EQU 0x7C00     ; VBR also expects to be at 0x7c00
LBA_SECTOR_SIZE EQU 512    ; Is this standard?
; KERNEL_LDR DEFINITIONS
KERNEL_LDR_IMG_OFFSET EQU 0x1000
KERNEL_LDR_IMG_LEN_OFF EQU (KERNEL_LDR_IMG_OFFSET-2)
KERNEL_LDR_LOAD_FLAT_ADDR EQU 0x1000 ; 4th KiB, should have 27KiB free until the VBR
KERNEL_LDR_LOAD_SEG EQU (KERNEL_LDR_LOAD_FLAT_ADDR / 16)
KERNEL_LDR_LOAD_OFF EQU (KERNEL_LDR_LOAD_FLAT_ADDR % 16)
%if KERNEL_LDR_IMG_OFFSET % LBA_SECTOR_SIZE != 0
%error "KERNEL_LDR_IMG_OFFSET must be a multiple of LBA_SECTOR_SIZE"
%endif
; END CONSTANT DEFINITIONS

; BEGIN MACRO DEFINITIONS
; NASM floors divisions but it's not documented
%define LEN_TO_LBA_SECTOR(len) (len % LBA_SECTOR_SIZE == 0 ? len/LBA_SECTOR_SIZE : len/LBA_SECTOR_SIZE + 1)
%define ADDR_TO_LBA_SECTOR(addr) (addr/LBA_SECTOR_SIZE)
%define ADDR_TO_LBA_SECTOR_OFFSET(addr) (addr % LBA_SECTOR_SIZE)
%macro cstring_def 2
    %1 db %2, 0x00
%endmacro
; END MACRO DEFINITIONS

; BEGIN STRUCT DEFINITIONS
struc lba_transfer_packet_t
    ltp_size: resb 1
    ltp_reserved: resb 1
    ltp_num_sector: resw 1
    ltp_mem_offset: resw 1
    ltp_mem_segment: resw 1
    ltp_lba_addr_lower32_l: resw 1
    ltp_lba_addr_lower32_h: resw 1
    ltp_lba_addr_higher32_l: resw 1
    ltp_lba_addr_higher32_h: resw 1
endstruc
struc mbr_pte_t
    mp_status: resb 1
    mp_CHSFirst: resb 3
    mp_type: resb 1
    mp_CHSLast: resb 3
    mp_lba_first_l: resw 1
    mp_lba_first_h: resw 1
    mp_sector_count_l: resw 1
    mp_sector_count_h: resw 1
endstruc
struc gdt_entry_t
    gdte_limit: resw 1
    gdte_base: resb 3
    gdte_access: resb 1
    gdte_flags_and_limit17_20: resb 1
    gdte_base_25_32: resb 1
endstruc
; END STRUCT DEFINITIONS

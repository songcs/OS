; haribote-ipl
; TAB=4

CYLS	EQU		10				; �ǂ��܂œǂݍ��ނ�

		ORG		0x7c00			; �w�������I��?�n��

; ?�yFAT12�i��??�I?�q

		JMP		entry
		DB		0x90
		DB		"HARIBOTE"		; ??��I�����Ȑ��C�ӓI�������i8��?�j
		DW		512				; ?�����(sector)�I�召(�K??512��?)
		DB		1				; �Ɓicluster�j�I�召�i�K??1�����j
		DW		1				; FAT�I�N�n�ʒu�i��ʘ���꘢���?�n�j
		DB		2				; FAT�I�����i�K??2�j
		DW		224				; ����?�I�召�i���??224?�j
		DW		2880			; ?��?�I�召�i�K?��2880���j
		DB		0xf0			; ��?�I??�i�K?��0xf0�j
		DW		9				; FAT�I?�x�i�K?��9���j
		DW		18				; 1������(track)�L�{�����i�K?��18�j
		DW		2				; ��?���i�K?��2�j
		DD		0				; �s�g�p����C�K?��0
		DD		2880			; �d�ʈꎟ��?�召
		DB		0,0,0x29		; ��?�s���C�Œ�
		DD		0xffffffff		; (�\��)��?��?
		DB		"HARIBOTEOS "	; ��?�I���́i11��?�j
		DB		"FAT12   "		; ��?�i�����́i8��?�j
		RESB	18				; ���o18��?

; �����j�S

entry:
		MOV		AX,0			; ���n���񑶊�
		MOV		SS,AX
		MOV		SP,0x7c00
		MOV		DS,AX

; �f�B�X�N��ǂ�

		MOV		AX,0x0820
		MOV		ES,AX
		MOV		CH,0			; ����0
		MOV		DH,0			; ��?0
		MOV		CL,2			; ���2
readloop:
		MOV		SI,0			; ??��?�����I�񑶊�
retry:
		MOV		AH,0x02			; AH=0x02:?����?
		MOV		AL,1			; 1�����
		MOV		BX,0
		MOV		DL,0x00			; A??��
		INT		0x13			; ?�p��?BIOS
		JNC		next			; �v�o?�A��?��next
		ADD		SI,1			; ��SI����
		CMP		SI,5			; ��?SI�^5
		JAE		error			; SI>=5��?��error
		MOV		AH,0x00
		MOV		DL,0x00			; A??��
		INT		0x13			; �d�u??��
		JMP		retry
next:
		MOV		AX,ES			; �c�����n���@��0x200
		ADD		AX,0x0020
		MOV		ES,AX			; ��?�v�LADD ES,0x0020�w��
		ADD		CL,1			; ��CL����
		CMP		CL,18			; ��?CL�a18
		JBE		readloop		; �@��CL <= 18 ��?��readloop�H�H�H
		MOV		CL,1
		ADD		DH,1
		CMP		DH,2
		JB		readloop		; �@��DH < 2,?��?��readlloop
		MOV		DH,0
		ADD		CH,1
		CMP		CH,CYLS
		JB		readloop		; CH < CYLS ?��?��readloop

; �ǂݏI������̂�haribote.sys�����s���I

		MOV		[0x0ff0],CH		; ��CYLS�I?�ʓ������n����0x0ff0���C?����?haribote.sys��?��?���e
		JMP		0xc200			; ��?��haribote.sys 

error:
		MOV		SI,msg
putloop:
		MOV		AL,[SI]
		ADD		SI,1			; SI��1�𑫂�
		CMP		AL,0
		JE		fin
		MOV		AH,0x0e			; ?���꘢����
		MOV		BX,15			; �w�莚��?�F
		INT		0x10			; ?�p??BIOS
		JMP		putloop
fin:
		HLT						; ?cpu��~�C���Ҏw��
		JMP		fin				; �ٌ��z?
msg:
		DB		0x0a, 0x0a		; ?�s2��
		DB		"load error"
		DB		0x0a			; ���s
		DB		0

		RESB	0x7dfe-$		; �U��0x00,���� 0x7dfe

		DB		0x55, 0xaa

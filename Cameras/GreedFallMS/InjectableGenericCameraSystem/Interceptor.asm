;////////////////////////////////////////////////////////////////////////////////////////////////////////
;// Part of Injectable Generic Camera System
;// Copyright(c) 2019, Frans Bouma
;// Copyright(c) 2021, magni1200s
;// All rights reserved.
;// https://github.com/FransBouma/InjectableGenericCameraSystem
;//
;// Redistribution and use in source and binary forms, with or without
;// modification, are permitted provided that the following conditions are met :
;//
;//  * Redistributions of source code must retain the above copyright notice, this
;//	  list of conditions and the following disclaimer.
;//
;//  * Redistributions in binary form must reproduce the above copyright notice,
;//    this list of conditions and the following disclaimer in the documentation
;//    and / or other materials provided with the distribution.
;//
;// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
;// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
;// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
;// DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
;// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
;// DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
;// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
;// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
;// OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
;// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
;////////////////////////////////////////////////////////////////////////////////////////////////////////
;---------------------------------------------------------------
; Game specific asm file to intercept execution flow to obtain addresses, prevent writes etc.
;---------------------------------------------------------------

;---------------------------------------------------------------
; Public definitions so the linker knows which names are present in this file
PUBLIC cameraStructInterceptor
PUBLIC cameraWrite1Interceptor
PUBLIC cameraWrite2Interceptor
PUBLIC cameraWrite3Interceptor
PUBLIC fogWriteInterceptor
PUBLIC todWriteInterceptor
PUBLIC gamespeedReadInterceptor

;---------------------------------------------------------------

;---------------------------------------------------------------
; Externs which are used and set by the system. Read / write these
; values in asm to communicate with the system
EXTERN g_cameraEnabled: byte
EXTERN g_noHeadBob: byte
EXTERN g_cameraStructAddress: qword
EXTERN g_todStructAddress: qword
EXTERN g_gamespeedStructAddress: qword
EXTERN g_fogStructAddress: qword

;---------------------------------------------------------------

;---------------------------------------------------------------
; Own externs, defined in InterceptorHelper.cpp
EXTERN _cameraStructInterceptionContinue: qword
EXTERN _cameraWrite1InterceptionContinue: qword
EXTERN _cameraWrite2InterceptionContinue: qword
EXTERN _cameraWrite3InterceptionContinue: qword
EXTERN _todWriteInterceptionContinue: qword
EXTERN _gamespeedReadInterceptionContinue: qword
EXTERN _fogWriteInterceptionContinue: qword

.data

.code
cameraStructInterceptor PROC
;EngineMS.dll+3D2DD3 - 74 2D                 - je EngineMS.dll+3D2E02
;EngineMS.dll+3D2DD5 - 48 8B CF              - mov rcx,rdi
;EngineMS.dll+3D2DD8 - E8 785FC3FF           - call EngineMS.CommonCore::spTagReference::getCRC+14
;EngineMS.dll+3D2DDD - 4C 8D 87 F0000000     - lea r8,[rdi+000000F0]
;EngineMS.dll+3D2DE4 - 48 8B CB              - mov rcx,rbx
;EngineMS.dll+3D2DE7 - 48 8D 54 24 60        - lea rdx,[rsp+60]
;EngineMS.dll+3D2DEC - E8 E907C3FF           - call EngineMS.Spider::aedBatchedDelete::operator=+4B
;EngineMS.dll+3D2DF1 - 48 8B 9C 24 B0000000  - mov rbx,[rsp+000000B0]
;EngineMS.dll+3D2DF9 - 48 81 C4 A0000000     - add rsp,000000A0 { 160 }
;EngineMS.dll+3D2E00 - 5F                    - pop rdi
;EngineMS.dll+3D2E01 - C3                    - ret 
;EngineMS.dll+3D2E02 - 0F11 83 B0000000      - movups [rbx+000000B0],xmm0			<< row 1 << INTERCEPT HERE
;EngineMS.dll+3D2E09 - 0F11 8B C0000000      - movups [rbx+000000C0],xmm1			<< row 2
;EngineMS.dll+3D2E10 - 0F11 93 D0000000      - movups [rbx+000000D0],xmm2			<< row 3
;EngineMS.dll+3D2E17 - 0F11 9B E0000000      - movups [rbx+000000E0],xmm3			<< row 4
;EngineMS.dll+3D2E1E - 48 8B 9C 24 B0000000  - mov rbx,[rsp+000000B0]						 << CONTINUE HERE
;EngineMS.dll+3D2E26 - 48 81 C4 A0000000     - add rsp,000000A0 { 160 }
;EngineMS.dll+3D2E2D - 5F                    - pop rdi
;EngineMS.dll+3D2E2E - C3                    - ret
	mov [g_cameraStructAddress], rbx
	cmp byte ptr [g_cameraEnabled], 1
	je exit
originalCode:
	movups xmmword ptr [rbx+000000B0h],xmm0
	movups xmmword ptr [rbx+000000C0h],xmm1
	movups xmmword ptr [rbx+000000D0h],xmm2
	movups xmmword ptr [rbx+000000E0h],xmm3
exit:
	jmp qword ptr [_cameraStructInterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
cameraStructInterceptor ENDP


cameraWrite1Interceptor PROC
;EngineMS.dll+32D2EE - EB 2B                 - jmp EngineMS.dll+32D31B
;EngineMS.dll+32D2F0 - 0F10 02               - movups xmm0,[rdx]
;EngineMS.dll+32D2F3 - 0F10 4A 10            - movups xmm1,[rdx+10]
;EngineMS.dll+32D2F7 - 0F10 52 20            - movups xmm2,[rdx+20]
;EngineMS.dll+32D2FB - 0F10 5A 30            - movups xmm3,[rdx+30]
;EngineMS.dll+32D2FF - 0F11 81 B0000000      - movups [rcx+000000B0],xmm0			<< row 1 << INTERCEPT HERE
;EngineMS.dll+32D306 - 0F11 89 C0000000      - movups [rcx+000000C0],xmm1			<< row 2
;EngineMS.dll+32D30D - 0F11 91 D0000000      - movups [rcx+000000D0],xmm2			<< row 3
;EngineMS.dll+32D314 - 0F11 99 E0000000      - movups [rcx+000000E0],xmm3			<< row 4
;EngineMS.dll+32D31B - 0F10 02               - movups xmm0,[rdx]							 << CONTINUE HERE
;EngineMS.dll+32D31E - 0F10 4A 10            - movups xmm1,[rdx+10]
;EngineMS.dll+32D322 - 0F10 52 20            - movups xmm2,[rdx+20]
;EngineMS.dll+32D326 - 0F10 5A 30            - movups xmm3,[rdx+30]
;EngineMS.dll+32D32A - 0F11 81 F0000000      - movups [rcx+000000F0],xmm0
;EngineMS.dll+32D331 - 0F11 89 00010000      - movups [rcx+00000100],xmm1
;EngineMS.dll+32D338 - 0F11 91 10010000      - movups [rcx+00000110],xmm2
;EngineMS.dll+32D33F - 0F11 99 20010000      - movups [rcx+00000120],xmm3
;EngineMS.dll+32D346 - 48 81 C4 88000000     - add rsp,00000088
;EngineMS.dll+32D34D - C3                    - ret
	cmp byte ptr [g_cameraEnabled], 1
	je exit
originalCode:
	movups xmmword ptr [rcx+000000B0h],xmm0
	movups xmmword ptr [rcx+000000C0h],xmm1
	movups xmmword ptr [rcx+000000D0h],xmm2
	movups xmmword ptr [rcx+000000E0h],xmm3
exit:
	jmp qword ptr [_cameraWrite1InterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
cameraWrite1Interceptor ENDP


cameraWrite2Interceptor PROC
;EngineMS.dll+7ABAB0 - 0FC6 D0 C4            - shufps xmm2,xmm0,-3C { 196 }
;EngineMS.dll+7ABAB4 - 0F28 C4               - movaps xmm0,xmm4
;EngineMS.dll+7ABAB7 - 0F11 97 B0000000      - movups [rdi+000000B0],xmm2		<< WRITE row 1		<< INTERCEPT HERE
;EngineMS.dll+7ABABE - 0FC6 87 C0000000 FA   - shufps xmm0,[rdi+000000C0],-06 { 250 }
;EngineMS.dll+7ABAC6 - 0FC6 E0 C4            - shufps xmm4,xmm0,-3C { 196 }
;EngineMS.dll+7ABACA - 0F28 C5               - movaps xmm0,xmm5
;EngineMS.dll+7ABACD - 0F11 A7 C0000000      - movups [rdi+000000C0],xmm4		<< WRITE row 2
;EngineMS.dll+7ABAD4 - 0FC6 87 D0000000 FA   - shufps xmm0,[rdi+000000D0],-06 { 250 }
;EngineMS.dll+7ABADC - 0FC6 E8 C4            - shufps xmm5,xmm0,-3C { 196 }
;EngineMS.dll+7ABAE0 - 0F11 AF D0000000      - movups [rdi+000000D0],xmm5		<< WRITE row 3
;EngineMS.dll+7ABAE7 - 49 8B E3              - mov rsp,r11											<< CONTINUE HERE
;EngineMS.dll+7ABAEA - 5F                    - pop rdi
;EngineMS.dll+7ABAEB - C3                    - ret
	cmp byte ptr [g_cameraEnabled], 1
	je noWrites
	cmp byte ptr [g_noHeadBob], 1
	jne originalCode
noWrites:
	shufps xmm0,xmmword ptr [rdi+000000C0h],-06h 
	shufps xmm4,xmm0,-3Ch
	movaps xmm0,xmm5
	shufps xmm0,xmmword ptr [rdi+000000D0h],-06h 
	shufps xmm5,xmm0,-3Ch
	jmp exit
originalCode:
	movups xmmword ptr [rdi+000000B0h],xmm2
	shufps xmm0,xmmword ptr [rdi+000000C0h],-06h
	shufps xmm4,xmm0,-3Ch
	movaps xmm0,xmm5
	movups xmmword ptr [rdi+000000C0h],xmm4		
	shufps xmm0,xmmword ptr [rdi+000000D0h],-06h 
	shufps xmm5,xmm0,-3Ch
	movups xmmword ptr [rdi+000000D0h],xmm5		
exit:
	jmp qword ptr [_cameraWrite2InterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
cameraWrite2Interceptor ENDP


cameraWrite3Interceptor PROC
;EngineMS.dll+3CCAD0 - 48 8B 41 10           - mov rax,[rcx+10]
;EngineMS.dll+3CCAD4 - 48 85 C0              - test rax,rax
;EngineMS.dll+3CCAD7 - 74 34                 - je EngineMS.dll+3CCB0D
;EngineMS.dll+3CCAD9 - 0F28 02               - movaps xmm0,[rdx]
;EngineMS.dll+3CCADC - 0F28 4A 10            - movaps xmm1,[rdx+10]
;EngineMS.dll+3CCAE0 - 0F28 52 20            - movaps xmm2,[rdx+20]
;EngineMS.dll+3CCAE4 - 0F28 5A 30            - movaps xmm3,[rdx+30]
;EngineMS.dll+3CCAE8 - 0F11 80 B0000000      - movups [rax+000000B0],xmm0			<< row 1 << INTERCEPT HERE
;EngineMS.dll+3CCAEF - 0F11 88 C0000000      - movups [rax+000000C0],xmm1			<< row 2
;EngineMS.dll+3CCAF6 - 0F11 90 D0000000      - movups [rax+000000D0],xmm2			<< row 3
;EngineMS.dll+3CCAFD - 0F11 98 E0000000      - movups [rax+000000E0],xmm3			<< row 4
;EngineMS.dll+3CCB04 - 48 8B 49 10           - mov rcx,[rcx+10]								 << CONTINUE HERE
;EngineMS.dll+3CCB08 - E9 48C2C3FF           - jmp EngineMS.CommonCore::spTagReference::getCRC+14
;EngineMS.dll+3CCB0D - C3                    - ret
	cmp byte ptr [g_cameraEnabled], 1
	je exit
originalCode:
	movups xmmword ptr [rax+000000B0h],xmm0
	movups xmmword ptr [rax+000000C0h],xmm1
	movups xmmword ptr [rax+000000D0h],xmm2
	movups xmmword ptr [rax+000000E0h],xmm3
exit:
	jmp qword ptr [_cameraWrite3InterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
cameraWrite3Interceptor ENDP


fogWriteInterceptor PROC
;EngineMS.dll+3C0A22 - 0F11 83 60010000      - movups [rbx+00000160],xmm0					<< FOG Color		<< INTERCEPT HERE
;EngineMS.dll+3C0A29 - 8B 47 40              - mov eax,[rdi+40]
;EngineMS.dll+3C0A2C - 89 83 70010000        - mov [rbx+00000170],eax
;EngineMS.dll+3C0A32 - 8B 47 44              - mov eax,[rdi+44]
;EngineMS.dll+3C0A35 - 89 83 74010000        - mov [rbx+00000174],eax						<< FOG Factor 2
;EngineMS.dll+3C0A3B - 8B 47 48              - mov eax,[rdi+48]
;EngineMS.dll+3C0A3E - 89 83 80010000        - mov [rbx+00000180],eax                      	<< FOG Factor 1
;EngineMS.dll+3C0A44 - 8B 47 4C              - mov eax,[rdi+4C]
;EngineMS.dll+3C0A47 - 89 83 78010000        - mov [rbx+00000178],eax						<< FOG Factor 3
;EngineMS.dll+3C0A4D - 8B 47 50              - mov eax,[rdi+50]
;EngineMS.dll+3C0A50 - 89 83 7C010000        - mov [rbx+0000017C],eax                      	<< FOG Blend factor
;EngineMS.dll+3C0A56 - 8B 47 54              - mov eax,[rdi+54]								<< CONTINUE HERE
;EngineMS.dll+3C0A59 - 89 83 A8010000        - mov [rbx+000001A8],eax						<< Ring around the sun factor 1
;EngineMS.dll+3C0A5F - 8B 47 58              - mov eax,[rdi+58]
;EngineMS.dll+3C0A62 - 89 83 AC010000        - mov [rbx+000001AC],eax						<< Ring around the sun factor 2
;EngineMS.dll+3C0A68 - 8B 47 5C              - mov eax,[rdi+5C]
	mov [g_fogStructAddress], rbx
	cmp byte ptr [g_cameraEnabled], 1
	jne originalCode
noWrites:
	mov eax,[rdi+40h]
	mov [rbx+00000170h],eax
	mov eax,[rdi+44h]
	mov eax,[rdi+48h]              
	mov eax,[rdi+4Ch]              
	mov eax,[rdi+50h]
	jmp exit
originalCode:
	movups xmmword ptr [rbx+00000160h],xmm0
	mov eax,[rdi+40h]
	mov [rbx+00000170h],eax
	mov eax,[rdi+44h]
	mov [rbx+00000174h],eax
	mov eax,[rdi+48h]
	mov [rbx+00000180h],eax
	mov eax,[rdi+4Ch]              
	mov [rbx+00000178h],eax			
	mov eax,[rdi+50h]
	mov [rbx+0000017Ch],eax
exit:
	jmp qword ptr [_fogWriteInterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
fogWriteInterceptor ENDP


todWriteInterceptor PROC
;GameMS.dll+686D9D - 72 13                 - jb GameMS.dll+686DB2
;GameMS.dll+686D9F - 8B 43 28              - mov eax,[rbx+28]
;GameMS.dll+686DA2 - F3 41 0F58 C2         - addss xmm0,xmm10
;GameMS.dll+686DA7 - FF C0                 - inc eax
;GameMS.dll+686DA9 - 41 0F2F C1            - comiss xmm0,xmm9
;GameMS.dll+686DAD - 73 F3                 - jae GameMS.dll+686DA2
;GameMS.dll+686DAF - 89 43 28              - mov [rbx+28],eax
;GameMS.dll+686DB2 - F3 0F10 4B 34         - movss xmm1,[rbx+34]				<< First address of non-jmp targets.
;GameMS.dll+686DB7 - 41 0F2F C8            - comiss xmm1,xmm8
;GameMS.dll+686DBB - 44 0F28 54 24 50      - movaps xmm10,[rsp+50]				<< INTERCEPT HERE
;GameMS.dll+686DC1 - 44 0F28 4C 24 60      - movaps xmm9,[rsp+60]
;GameMS.dll+686DC7 - F3 0F11 43 2C         - movss [rbx+2C],xmm0				<< WRITE ToD. No need to block it as it is read above.
;GameMS.dll+686DCC - 76 44                 - jna GameMS.dll+686E12				<< CONTINUE
;GameMS.dll+686DCE - F3 0F58 4B 30         - addss xmm1,[rbx+30]
;GameMS.dll+686DD3 - 33 C0                 - xor eax,eax
;GameMS.dll+686DD5 - C7 44 24 20 05000000  - mov [rsp+20],00000005 { 5 }
;GameMS.dll+686DDD - 89 43 34              - mov [rbx+34],eax
;GameMS.dll+686DE0 - C7 44 24 24 15000000  - mov [rsp+24],00000015 { 21 }
	mov [g_todStructAddress], rbx
	movaps xmm10, xmmword ptr [rsp+50h]
	movaps xmm9, xmmword ptr [rsp+60h]
	cmp byte ptr [g_cameraEnabled], 1
	je exit
originalCode:
	movss dword ptr [rbx+2Ch],xmm0
exit:
	jmp qword ptr [_todWriteInterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
todWriteInterceptor ENDP


gamespeedReadInterceptor PROC
;EngineMS.dll+551D8F - EB 03                 - jmp EngineMS.dll+551D94
;EngineMS.dll+551D91 - 0F57 C9               - xorps xmm1,xmm1
;EngineMS.dll+551D94 - F3 0F10 47 24         - movss xmm0,[rdi+24]				<< INTERCEPT HERE << Read gamespeed. 1 is normal, 0 is pause.
;EngineMS.dll+551D99 - F3 0F59 47 20         - mulss xmm0,[rdi+20]
;EngineMS.dll+551D9E - F3 0F59 C1            - mulss xmm0,xmm1
;EngineMS.dll+551DA2 - F3 0F5D 05 46913D00   - minss xmm0,[EngineMS.Spider::danPooledAnimTreeDesc::`vftable'+17C8] << CONTINUE HERE
;EngineMS.dll+551DAA - F3 0F11 83 90000000   - movss [rbx+00000090],xmm0
;EngineMS.dll+551DB2 - 48 8B 5C 24 40        - mov rbx,[rsp+40]
;EngineMS.dll+551DB7 - 0F28 7C 24 20         - movaps xmm7,[rsp+20]
;EngineMS.dll+551DBC - 48 83 C4 30           - add rsp,30 { 48 }
;EngineMS.dll+551DC0 - 5F                    - pop rdi
;EngineMS.dll+551DC1 - C3                    - ret
	mov [g_gamespeedStructAddress], rdi
	movss xmm0,dword ptr [rdi+24h]
	mulss xmm0,dword ptr [rdi+20h]
	mulss xmm0,xmm1
exit:
	jmp qword ptr [_gamespeedReadInterceptionContinue]	; jmp back into the original game code, which is the location after the original statements above.
gamespeedReadInterceptor ENDP

END
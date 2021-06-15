////////////////////////////////////////////////////////////////////////////////////////////////////////
// Part of Injectable Generic Camera System
// Copyright(c) 2019, Frans Bouma
// All rights reserved.
// https://github.com/FransBouma/InjectableGenericCameraSystem
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met :
//
//  * Redistributions of source code must retain the above copyright notice, this
//	  list of conditions and the following disclaimer.
//
//  * Redistributions in binary form must reproduce the above copyright notice,
//    this list of conditions and the following disclaimer in the documentation
//    and / or other materials provided with the distribution.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
// DISCLAIMED.IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
// FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
// DAMAGES(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
// SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
// CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
// OR TORT(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
////////////////////////////////////////////////////////////////////////////////////////////////////////
#include "stdafx.h"
#include "InterceptorHelper.h"
#include "GameConstants.h"
#include "GameImageHooker.h"
#include <map>
#include "OverlayConsole.h"
#include "CameraManipulator.h"

using namespace std;

//--------------------------------------------------------------------------------------------------------------------------------
// external asm functions
extern "C" {
	void cameraStructInterceptor();
	void cameraWrite1Interceptor();
	void cameraWrite2Interceptor();
	void cameraWrite3Interceptor();
	void fogWriteInterceptor();
	void todWriteInterceptor();
	void gamespeedReadInterceptor();
}

// external addresses used in asm.
extern "C" {
	LPBYTE _cameraStructInterceptionContinue = nullptr;
	LPBYTE _cameraWrite1InterceptionContinue = nullptr;
	LPBYTE _cameraWrite2InterceptionContinue = nullptr;
	LPBYTE _cameraWrite3InterceptionContinue = nullptr;
	LPBYTE _fogWriteInterceptionContinue = nullptr;
	LPBYTE _todWriteInterceptionContinue = nullptr;
	LPBYTE _gamespeedReadInterceptionContinue = nullptr;
}


namespace IGCS::GameSpecific::InterceptorHelper
{
	void initializeAOBBlocks(map<string, AOBBlock*> &aobBlocks)
	{
		// AOBs are in 2 different DLLs: Engine.dll and Game.dll. We pull both images and sizes here. 
		MODULEINFO engineDllInfo = Utils::getModuleInfoOfDll(L"EngineMS.dll");
		if (nullptr == engineDllInfo.lpBaseOfDll)
		{
			OverlayConsole::instance().logError("Can't obtain the address of 'EngineMS.dll'. Tools aren't compatible with this game's version");
			return;
		}
		MODULEINFO gameDllInfo = Utils::getModuleInfoOfDll(L"GameMS.dll");
		if (nullptr == gameDllInfo.lpBaseOfDll)
		{
			OverlayConsole::instance().logError("Can't obtain the address of 'GameMS.dll'. Tools aren't compatible with this game's version");
			return;
		}
		aobBlocks[CAMERA_ADDRESS_INTERCEPT_KEY] = new AOBBlock(CAMERA_ADDRESS_INTERCEPT_KEY, "C3 | 0F 11 83 B0 00 00 00 0F 11 8B C0 00 00 00 0F 11 93 D0 00 00 00 0F 11 9B E0 00 00 00", 1);	
		aobBlocks[CAMERA_WRITE1_INTERCEPT_KEY] = new AOBBlock(CAMERA_WRITE1_INTERCEPT_KEY, "0F 10 5A 30 | 0F 11 81 B0 00 00 00 0F 11 89 C0 00 00 00 0F 11 91 D0 00 00 00 0F 11 99 E0 00 00 00 0F 10 02", 1);
		aobBlocks[CAMERA_WRITE2_INTERCEPT_KEY] = new AOBBlock(CAMERA_WRITE2_INTERCEPT_KEY, "0F 11 97 B0 00 00 00 0F C6 87 C0 00 00 00 FA 0F C6 E0 C4 0F 28 C5 0F 11 A7 C0 00 00 00 0F C6 87 D0 00 00 00 FA 0F C6 E8 C4 0F 11 AF D0 00 00 00 49 8B E3", 1);
		aobBlocks[CAMERA_WRITE3_INTERCEPT_KEY] = new AOBBlock(CAMERA_WRITE3_INTERCEPT_KEY, "0F 11 80 B0 00 00 00 0F 11 88 C0 00 00 00 0F 11 90 D0 00 00 00 0F 11 98 E0 00 00 00 48 8B 49 10", 1);
		aobBlocks[FOV_WRITE_INTERCEPT_KEY] = new AOBBlock(FOV_WRITE_INTERCEPT_KEY, "48 81 C1 E0 01 00 00 F3 0F 10 41 10 0F 2E C1 7A 02 74 0A | F3 0F 11 49 10", 1);
		aobBlocks[GAMESPEED_READ_INTERCEPT_KEY] = new AOBBlock(GAMESPEED_READ_INTERCEPT_KEY, "F3 0F 10 47 24 F3 0F 59 47 20 F3 0F 59 C1 F3 0F 5D", 1);
		aobBlocks[FOG_WRITE_INTERCEPT_KEY] = new AOBBlock(FOG_WRITE_INTERCEPT_KEY, "0F 11 83 60 01 00 00 8B 47 40", 1);
		aobBlocks[TOD_WRITE_INTERCEPT_KEY] = new AOBBlock(TOD_WRITE_INTERCEPT_KEY, "44 0F 28 54 24 50 44 0F 28 4C 24 60 F3 0F 11 43 2C", 1);

		map<string, AOBBlock*>::iterator it;
		bool result = true;
		// all AOBs are in EngineMS.dll, except ToD, which is in GameMS.dll
		result &= aobBlocks[CAMERA_ADDRESS_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[CAMERA_WRITE1_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[CAMERA_WRITE2_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[CAMERA_WRITE3_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[FOV_WRITE_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[GAMESPEED_READ_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[FOG_WRITE_INTERCEPT_KEY]->scan((LPBYTE)engineDllInfo.lpBaseOfDll, engineDllInfo.SizeOfImage);
		result &= aobBlocks[TOD_WRITE_INTERCEPT_KEY]->scan((LPBYTE)gameDllInfo.lpBaseOfDll, gameDllInfo.SizeOfImage);

		if (result)
		{
			OverlayConsole::instance().logLine("All interception offsets found.");
		}
		else
		{
			OverlayConsole::instance().logError("One or more interception offsets weren't found: tools aren't compatible with this game's version.");
		}
	}


	void setCameraStructInterceptorHook(map<string, AOBBlock*> &aobBlocks)
	{
		GameImageHooker::setHook(aobBlocks[CAMERA_ADDRESS_INTERCEPT_KEY], 0x1C, &_cameraStructInterceptionContinue, &cameraStructInterceptor);
	}


	void setPostCameraStructHooks(map<string, AOBBlock*> &aobBlocks)
	{
		GameImageHooker::setHook(aobBlocks[CAMERA_WRITE1_INTERCEPT_KEY], 0x1C, &_cameraWrite1InterceptionContinue, &cameraWrite1Interceptor);
		GameImageHooker::setHook(aobBlocks[CAMERA_WRITE2_INTERCEPT_KEY], 0x30, &_cameraWrite2InterceptionContinue, &cameraWrite2Interceptor);
		GameImageHooker::setHook(aobBlocks[CAMERA_WRITE3_INTERCEPT_KEY], 0x1C, &_cameraWrite3InterceptionContinue, &cameraWrite3Interceptor);
		GameImageHooker::setHook(aobBlocks[TOD_WRITE_INTERCEPT_KEY], 0x11, &_todWriteInterceptionContinue, &todWriteInterceptor);
		GameImageHooker::setHook(aobBlocks[GAMESPEED_READ_INTERCEPT_KEY], 0x0E, &_gamespeedReadInterceptionContinue, &gamespeedReadInterceptor);
		GameImageHooker::setHook(aobBlocks[FOG_WRITE_INTERCEPT_KEY], 0x34, &_fogWriteInterceptionContinue, &fogWriteInterceptor);
	}


	void toggleFoVEnableWrite(map<string, AOBBlock*> &aobBlocks, bool cameraEnabled)
	{
		// enabled is true: camera
		//EngineMS.dll+5E4910 - 48 81 C1 E0010000	- add rcx,000001E0 { 480 }
		//EngineMS.dll+5E4917 - F3 0F10 41 10		- movss xmm0, [rcx + 10]
		//EngineMS.dll+5E491C - 0F2E C1				- ucomiss xmm0, xmm1
		//EngineMS.dll+5E491F - 7A 02				- jp EngineMS.dll + 5E4923
		//EngineMS.dll+5E4921 - 74 0A				- je EngineMS.dll + 5E492D
		//EngineMS.dll+5E4923 - F3 0F11 49 10		- movss[rcx + 10], xmm1				<< Write FoV. Nop this when camera is enabled. Game checks difference and then triggers update in the jmp below.
		//EngineMS.dll+5E4928 - E9 5943A4FF			- jmp EngineMS.Spider::amaCameraManager::s_getCameraViewProjectionMatrixUnsafeThread + BE
		//EngineMS.dll+5E492D - C3 - ret
		if (cameraEnabled)
		{
			// nop range
			//EngineMS.dll+5E4923 - F3 0F11 49 10 - movss[rcx + 10], xmm1
			GameImageHooker::nopRange(aobBlocks[FOV_WRITE_INTERCEPT_KEY], 5);
		}
		else
		{
			// write original code
			//EngineMS.dll+5E4923 - F3 0F11 49 10 - movss[rcx + 10], xmm1
			BYTE statementBytes[5] = { 0xF3, 0x0F, 0x11, 0x49, 0x10};
			GameImageHooker::writeRange(aobBlocks[FOV_WRITE_INTERCEPT_KEY], statementBytes, 5);
		}
	}
}

//---------------------------------------------------------------------------

#include <vcl.h>
#pragma hdrstop
USERES("CnPack_CB5.res");
USEPACKAGE("vcl50.bpi");
USEPACKAGE("Vclx50.bpi");
USEPACKAGE("Vcldb50.bpi");
USEPACKAGE("Vclmid50.bpi");
USEPACKAGE("VclSmp50.bpi");
USEPACKAGE("vclado50.bpi");
USEUNIT("..\..\Source\Common\CnAntiCheater.pas");
USEUNIT("..\..\Source\Common\CnBigDecimal.pas");
USEUNIT("..\..\Source\Common\CnBigRational.pas");
USEUNIT("..\..\Source\Common\CnBinaryDiffPatch.pas");
USEUNIT("..\..\Source\Common\CnBloomFilter.pas");
USEUNIT("..\..\Source\Common\CnCalClass.pas");
USEUNIT("..\..\Source\Common\CnCalendar.pas");
USEUNIT("..\..\Source\Common\CnCallBack.pas");
USEUNIT("..\..\Source\Common\CnClasses.pas");
USEUNIT("..\..\Source\Common\CnCommon.pas");
USEUNIT("..\..\Source\Common\CnCompUtils.pas");
USEUNIT("..\..\Source\Common\CnConsts.pas");
USEUNIT("..\..\Source\Common\CnContainers.pas");
USEUNIT("..\..\Source\Common\CnDancingLinks.pas");
USEUNIT("..\..\Source\Common\CnDynObjBuilder.pas");
USEUNIT("..\..\Source\Common\CnEventBus.pas");
USEUNIT("..\..\Source\Common\CnEventHook.pas");
USEUNIT("..\..\Source\Common\CnFitCurve.pas");
USEUNIT("..\..\Source\Common\CnFloat.pas");
USEUNIT("..\..\Source\Common\CnGB18030.pas");
USEUNIT("..\..\Source\Common\CnGraphUtils.pas");
USEUNIT("..\..\Source\Common\CnHardWareInfo.pas");
USEUNIT("..\..\Source\Common\CnHashMap.pas");
USEUNIT("..\..\Source\Common\CnIni.pas");
USEUNIT("..\..\Source\Common\CnIniCfg.pas");
USEUNIT("..\..\Source\Common\CnIniStrUtils.pas");
USEUNIT("..\..\Source\Common\CnLinkedList.pas");
USEUNIT("..\..\Source\Common\CnLockFree.pas");
USEUNIT("..\..\Source\Common\CnMatrix.pas");
USEUNIT("..\..\Source\Common\CnMath.pas");
USEUNIT("..\..\Source\Common\CnMethodHook.pas");
USEUNIT("..\..\Source\Common\CnPDF.pas");
USEUNIT("..\..\Source\Common\CnPE.pas");
USEUNIT("..\..\Source\Common\CnRopes.pas");
USEUNIT("..\..\Source\Common\CnShellUtils.pas");
USEUNIT("..\..\Source\Common\CnSingleton.pas");
USEUNIT("..\..\Source\Common\CnSingletonComp.pas");
USEUNIT("..\..\Source\Common\CnSkipList.pas");
USEUNIT("..\..\Source\Common\CnSQLite.pas");
USEUNIT("..\..\Source\Common\CnStrDiff.pas");
USEUNIT("..\..\Source\Common\CnStream.pas");
USEUNIT("..\..\Source\Common\CnStrings.pas");
USEUNIT("..\..\Source\Common\CnThreadTaskMgr.pas");
USEUNIT("..\..\Source\Common\CnTree.pas");
USEUNIT("..\..\Source\Common\CnVarList.pas");
USEUNIT("..\..\Source\Common\CnVCLBase.pas");
USEUNIT("..\..\Source\Common\CnVclFmxMixed.pas");
USEUNIT("..\..\Source\Common\CnWideStrings.pas");
USEUNIT("..\..\Source\Common\CnWinSvc.pas");
USEUNIT("..\..\Source\Crypto\Cn25519.pas");
USEUNIT("..\..\Source\Crypto\CnAES.pas");
USEUNIT("..\..\Source\Crypto\CnBase64.pas");
USEUNIT("..\..\Source\Crypto\CnBerUtils.pas");
USEUNIT("..\..\Source\Crypto\CnBigNumber.pas");
USEUNIT("..\..\Source\Crypto\CnCertificateAuthority.pas");
USEUNIT("..\..\Source\Crypto\CnComplex.pas");
USEUNIT("..\..\Source\Crypto\CnCRC32.pas");
USEUNIT("..\..\Source\Crypto\CnDES.pas");
USEUNIT("..\..\Source\Crypto\CnDFT.pas");
USEUNIT("..\..\Source\Crypto\CnECC.pas");
USEUNIT("..\..\Source\Crypto\CnFEC.pas");
USEUNIT("..\..\Source\Crypto\CnKDF.pas");
USEUNIT("..\..\Source\Crypto\CnMD5.pas");
USEUNIT("..\..\Source\Crypto\CnNative.pas");
USEUNIT("..\..\Source\Crypto\CnPemUtils.pas");
USEUNIT("..\..\Source\Crypto\CnPolynomial.pas");
USEUNIT("..\..\Source\Crypto\CnPrimeNumber.pas");
USEUNIT("..\..\Source\Crypto\CnRandom.pas");
USEUNIT("..\..\Source\Crypto\CnRC4.pas");
USEUNIT("..\..\Source\Crypto\CnRSA.pas");
USEUNIT("..\..\Source\Crypto\CnSHA1.pas");
USEUNIT("..\..\Source\Crypto\CnSHA2.pas");
USEUNIT("..\..\Source\Crypto\CnSHA3.pas");
USEUNIT("..\..\Source\Crypto\CnSM2.pas");
USEUNIT("..\..\Source\Crypto\CnSM3.pas");
USEUNIT("..\..\Source\Crypto\CnSM4.pas");
USEUNIT("..\..\Source\Crypto\CnSM9.pas");
USEUNIT("..\..\Source\Crypto\CnTEA.pas");
USEUNIT("..\..\Source\Crypto\CnZUC.pas");
USEUNIT("..\..\Source\DbReport\CnADOBinding.pas");
USEUNIT("..\..\Source\DbReport\CnADOUpdateSQL.pas");
USEUNIT("..\..\Source\DbReport\CnDataGrid.pas");
USEUNIT("..\..\Source\DbReport\CnDBConsts.pas");
USEUNIT("..\..\Source\DbReport\CnPagedGrid.pas");
USEUNIT("..\..\Source\DbReport\CnXlsWriter.pas");
USEUNIT("..\..\Source\Graphics\CnAACtrls.pas");
USEUNIT("..\..\Source\Graphics\CnAAFont.pas");
USEUNIT("..\..\Source\Graphics\CnAAFontDialog.pas");
USEUNIT("..\..\Source\Graphics\CnAOTreeView.pas");
USEUNIT("..\..\Source\Graphics\CnAutoOption.pas");
USEUNIT("..\..\Source\Graphics\CnButtonEdit.pas");
USEUNIT("..\..\Source\Graphics\CnButtons.pas");
USEUNIT("..\..\Source\Graphics\CnCheckTreeView.pas");
USEUNIT("..\..\Source\Graphics\CnColorGrid.pas");
USEUNIT("..\..\Source\Graphics\CnEdit.pas");
USEUNIT("..\..\Source\Graphics\CnErrorProvider.pas");
USEUNIT("..\..\Source\Graphics\CnGauge.pas");
USEUNIT("..\..\Source\Graphics\CnGraphConsts.pas");
USEUNIT("..\..\Source\Graphics\CnGraphics.pas");
USEUNIT("..\..\Source\Graphics\CnHexEditor.pas");
USEUNIT("..\..\Source\Graphics\CnHint.pas");
USEUNIT("..\..\Source\Graphics\CnIconUtils.pas");
USEUNIT("..\..\Source\Graphics\CnImage.pas");
USEUNIT("..\..\Source\Graphics\CnLED.pas");
USEUNIT("..\..\Source\Graphics\CnListBox.pas");
USEUNIT("..\..\Source\Graphics\CnMemo.pas");
USEUNIT("..\..\Source\Graphics\CnMonthCalendar.pas");
USEUNIT("..\..\Source\Graphics\CnOpenGLPaintBox.pas");
USEUNIT("..\..\Source\Graphics\CnPanel.pas");
USEUNIT("..\..\Source\Graphics\CnShellCtrls.pas");
USEUNIT("..\..\Source\Graphics\CnSkinMagic.pas");
USEUNIT("..\..\Source\Graphics\CnSpin.pas");
USEUNIT("..\..\Source\Graphics\CnSplitter.pas");
USEUNIT("..\..\Source\Graphics\CnTabSet.pas");
USEUNIT("..\..\Source\Graphics\CnTextControl.pas");
USEUNIT("..\..\Source\Graphics\CnValidateImage.pas");
USEUNIT("..\..\Source\Graphics\CnWaterEffect.pas");
USEUNIT("..\..\Source\Graphics\CnWaterImage.pas");
USEUNIT("..\..\Source\Graphics\CnWizardImage.pas");
USEUNIT("..\..\Source\MultiLang\CnHashIniFile.pas");
USEUNIT("..\..\Source\MultiLang\CnHashLangStorage.pas");
USEUNIT("..\..\Source\MultiLang\CnIniLangFileStorage.pas");
USEUNIT("..\..\Source\MultiLang\CnLangCollection.pas");
USEUNIT("..\..\Source\MultiLang\CnLangConsts.pas");
USEUNIT("..\..\Source\MultiLang\CnLangMgr.pas");
USEUNIT("..\..\Source\MultiLang\CnLangStorage.pas");
USEUNIT("..\..\Source\MultiLang\CnLangTranslator.pas");
USEUNIT("..\..\Source\MultiLang\CnLangUtils.pas");
USEUNIT("..\..\Source\NetComm\CnCameraEye.pas");
USEUNIT("..\..\Source\NetComm\CnDialUp.pas");
USEUNIT("..\..\Source\NetComm\CnIISCtrl.pas");
USEUNIT("..\..\Source\NetComm\CnInetUtils.pas");
USEUNIT("..\..\Source\NetComm\CnIocpSimpleMemPool.pas");
USEUNIT("..\..\Source\NetComm\CnIocpSocketAdapter.pas");
USEUNIT("..\..\Source\NetComm\CnIP.pas");
USEUNIT("..\..\Source\NetComm\CnModem.pas");
USEUNIT("..\..\Source\NetComm\CnNetConsts.pas");
USEUNIT("..\..\Source\NetComm\CnNetwork.pas");
USEUNIT("..\..\Source\NetComm\CnPing.pas");
USEUNIT("..\..\Source\NetComm\CnRS232.pas");
USEUNIT("..\..\Source\NetComm\CnRS232Dialog.pas");
USEUNIT("..\..\Source\NetComm\CnTCPClient.pas");
USEUNIT("..\..\Source\NetComm\CnTCPForwarder.pas");
USEUNIT("..\..\Source\NetComm\CnThreadingTCPServer.pas");
USEUNIT("..\..\Source\NetComm\CnTwain.pas");
USEUNIT("..\..\Source\NetComm\CnUDP.pas");
USEUNIT("..\..\Source\NonVisual\CnActionListHook.pas");
USEUNIT("..\..\Source\NonVisual\CnActiveScript.pas");
USEUNIT("..\..\Source\NonVisual\CnADOConPool.pas");
USEUNIT("..\..\Source\NonVisual\CnCompConsts.pas");
USEUNIT("..\..\Source\NonVisual\CnConsole.pas");
USEUNIT("..\..\Source\NonVisual\CnControlHook.pas");
USEUNIT("..\..\Source\NonVisual\CnDelphiDockStyle.pas");
USEUNIT("..\..\Source\NonVisual\CnDockFormControl.pas");
USEUNIT("..\..\Source\NonVisual\CnDockGlobal.pas");
USEUNIT("..\..\Source\NonVisual\CnDockHashTable.pas");
USEUNIT("..\..\Source\NonVisual\CnDockInfo.pas");
USEUNIT("..\..\Source\NonVisual\CnDockSupportClass.pas");
USEUNIT("..\..\Source\NonVisual\CnDockSupportControl.pas");
USEUNIT("..\..\Source\NonVisual\CnDockSupportProc.pas");
USEUNIT("..\..\Source\NonVisual\CnDockTree.pas");
USEUNIT("..\..\Source\NonVisual\CnDragResizer.pas");
USEUNIT("..\..\Source\NonVisual\CnFilePacker.pas");
USEUNIT("..\..\Source\NonVisual\CnFileSystemWatcher.pas");
USEUNIT("..\..\Source\NonVisual\CnFormScaler.pas");
USEUNIT("..\..\Source\NonVisual\CnGlobalKeyHook.pas");
USEUNIT("..\..\Source\NonVisual\CnHardwareBreakpoint.pas");
USEUNIT("..\..\Source\NonVisual\CnInProcessAPIHook.pas");
USEUNIT("..\..\Source\NonVisual\CnKeyBlocker.pas");
USEUNIT("..\..\Source\NonVisual\CnMDIBackGround.pas");
USEUNIT("..\..\Source\NonVisual\CnMemorySearch.pas");
USEUNIT("..\..\Source\NonVisual\CnMenuHook.pas");
USEUNIT("..\..\Source\NonVisual\CnObjectPool.pas");
USEUNIT("..\..\Source\NonVisual\CnOuterControls.pas");
USEUNIT("..\..\Source\NonVisual\CnRawInput.pas");
USEUNIT("..\..\Source\NonVisual\CnRestoreSystemMenu.pas");
USEUNIT("..\..\Source\NonVisual\CnSystemDebugControl.pas");
USEUNIT("..\..\Source\NonVisual\CnTaskBar.pas");
USEUNIT("..\..\Source\NonVisual\CnThreadPool.pas");
USEUNIT("..\..\Source\NonVisual\CnTimer.pas");
USEUNIT("..\..\Source\NonVisual\CnTrayIcon.pas");
USEUNIT("..\..\Source\NonVisual\CnVCDockStyle.pas");
USEUNIT("..\..\Source\NonVisual\CnVIDDockStyle.pas");
USEUNIT("..\..\Source\NonVisual\CnVolumeCtrl.pas");
USEUNIT("..\..\Source\NonVisual\CnVSNETDockStyle.pas");
USEUNIT("..\..\Source\NonVisual\CnWinampCtrl.pas");
USEUNIT("..\..\Source\ObjRep\CnFoxmailMsgFrm.pas");
USEUNIT("..\..\Source\ObjRep\CnProgressFrm.pas");
USEUNIT("..\..\Source\Skin\CnSkinForm.pas");
USEUNIT("..\..\Source\Skin\CnSkinMenu.pas");
USEUNIT("..\..\Source\Skin\CnSkinStdCtrls.pas");
USEUNIT("..\..\Source\Skin\CnSkinStyle.pas");
USEUNIT("..\..\Source\Skin\CnSkinTheme.pas");
USEUNIT("..\..\Source\Skin\CnSkinXPBlueStyle.pas");
USEUNIT("..\..\Source\Skin\CnSkinXPGreenStyle.pas");
USEUNIT("..\..\Source\Skin\CnSkinXPSilverStyle.pas");
//---------------------------------------------------------------------------
#pragma package(smart_init)
#pragma link "msimg32.lib"
//---------------------------------------------------------------------------

//   Package source.
//---------------------------------------------------------------------------

#pragma argsused
int WINAPI DllEntryPoint(HINSTANCE hinst, unsigned long reason, void*)
{
        return 1;
}
//---------------------------------------------------------------------------

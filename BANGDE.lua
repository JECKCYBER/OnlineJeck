local LOG_PATH="/storage/emulated/0/Android/data/com.tencent.ig/files/LogUpdate.txt"
function _G.WriteLog(msg) pcall(function() local f=io.open(LOG_PATH,"a+") if not f then return end f:write(string.format("[%s] %s\n",os.date("%H:%M:%S"),tostring(msg))) f:close() end) end
function _G.TryShowWelcome() pcall(function() _G.WriteLog("TryShowWelcome called") if _G.WelcomeShownOnce then return end _G.WelcomeShownOnce=true local CommonMsgBoxMgr=require("client.slua.logic.common.logic_common_msg_box") if not CommonMsgBoxMgr then _G.WriteLog("CommonMsgBoxMgr not found") return end local activeStatus="NUSANTARA MODDING LAB PROJECT\n\nTHIS PROJECT MADE BY @BANGDE_REALONE.\n\n\nIPAD_VIEW: Active\nRED_AURA: Active\nAIMBOT: Active\nAIM_LOCKHEAD: Active\nLESS_RECOIL: Active\nNO_SHAKE: Active\n\nTHIS PROJECT MADE BY @BANGDE_REALONE.\n\nEnjoy And Keep Safe!" CommonMsgBoxMgr.Show(1,"NML MENU",activeStatus,function() end) _G.WriteLog("Welcome menu shown") end) end
local BRPlayerCharacterBase={ServerRPC={},ClientRPC={},MulticastRPC={}}
BRPlayerCharacterBase.ServerRPC.ServerRPC_NearDeathGiveupRescue={Reliable=true,Params={}}
BRPlayerCharacterBase.ServerRPC.ServerRPC_CarryDeadBox={Reliable=true,Params={UEnums.EPropertyClass.Object}}
BRPlayerCharacterBase.ServerRPC.RPC_Server_GmPlayAction={Reliable=true,Params={UEnums.EPropertyClass.Int}}
BRPlayerCharacterBase.MulticastRPC.MulticastRPC_GmPlayAction={Reliable=true,Params={UEnums.EPropertyClass.Int}}
BRPlayerCharacterBase.ClientRPC.RPC_Client_SetShouldCheckPassWall={Reliable=true,Params={UEnums.EPropertyClass.Bool}}
local ENetRole=import("ENetRole")
local EPawnState=import("EPawnState")
local GameplayData=require("GameLua.GameCore.Data.GameplayData")
local GameplayStatics=import("GameplayStatics")
function BRPlayerCharacterBase:ctor() end
function BRPlayerCharacterBase:_PostConstruct() BRPlayerCharacterBase.__super._PostConstruct(self) self:InitAddSpecialMoveInfo() self.bCanNearDeathGiveup=true _G.WriteLog("PostConstruct executed") end
function BRPlayerCharacterBase:ReceiveBeginPlay() BRPlayerCharacterBase.__super.ReceiveBeginPlay(self) self:RegisterAvatarOutline(true) self:SetActorTickEnabled(true) _G.TryShowWelcome() _G.WriteLog("BeginPlay executed") EventSystem:postEvent(EVENTID_CHARACTER_BEGINPLAY,self.Object) end
function BRPlayerCharacterBase:ReceiveTick(DeltaTime) self:ApplyNoRecoil() self:ApplyAutoAimHead() self:SetFOV110() self:SetCharacterShadowBoost() end
function BRPlayerCharacterBase:ApplyNoRecoil() local weaponManager=self.WeaponManagerComponent if not weaponManager then return end local currentWeapon=weaponManager.CurrentWeaponReplicated if not currentWeapon then return end local shootComp=currentWeapon.ShootWeaponEntityComp if not shootComp then return end shootComp.RecoilKick=0 shootComp.RecoilKickADS=0 shootComp.AnimationKick=0 if shootComp.RecoilInfo then shootComp.RecoilInfo.VerticalRecoilMin=0 shootComp.RecoilInfo.VerticalRecoilMax=0 shootComp.RecoilInfo.RecoilSpeedVertical=0 shootComp.RecoilInfo.RecoilSpeedHorizontal=0 shootComp.RecoilInfo.VerticalRecoveryMax=0 shootComp.RecoilInfo.RecoilModifierStand=0 shootComp.RecoilInfo.RecoilModifierCrouch=0 shootComp.RecoilInfo.RecoilModifierProne=0 end if shootComp.AutoAimingConfig then local aa=shootComp.AutoAimingConfig aa.OuterRange.Speed=10 aa.InnerRange.Speed=10 aa.OuterRange.SpeedRate=10 aa.InnerRange.SpeedRate=10 aa.OuterRange.CenterSpeedRate=10 aa.InnerRange.CenterSpeedRate=10 aa.OuterRange.RangeRate=2 aa.InnerRange.RangeRate=2 aa.OuterRange.RangeRateSight=2 aa.InnerRange.RangeRateSight=2 aa.OuterRange.SpeedRateSight=2 aa.InnerRange.SpeedRateSight=2 aa.OuterRange.CrouchRate=2 aa.InnerRange.CrouchRate=2 aa.OuterRange.ProneRate=2 aa.InnerRange.ProneRate=2 aa.OuterRange.DyingRate=0 aa.InnerRange.DyingRate=0 shootComp.WeaponAimInTime=7 shootComp.GameDeviationFactor=0 shootComp.GameDeviationAccuracy=0 end end
function BRPlayerCharacterBase:ApplyAutoAimHead() local autoComp=self.AutoAimComp if not autoComp then return end autoComp.Bones={"Head","Head","Head"} end
function BRPlayerCharacterBase:ReceiveEndPlay(EndPlayReason) BRPlayerCharacterBase.__super.ReceiveEndPlay(self,EndPlayReason) if Client and GameplayData.RemoveCharacter~=nil then GameplayData.RemoveCharacter(self.Object) end end
function BRPlayerCharacterBase:ReceiveDrawHUD(Canvas) local Esp="BANGDE_REALONE" tslFontUI.LegacyFontSize=15 DrawOutlinedText(Canvas,Esp,{screenWidth/12.3+screenWidth/25.2,640},COLOR_YELLOW,COLOR_BLACK,true) end
function BRPlayerCharacterBase:RegisterAvatarOutline(bForce) if not Client then return end local uAvatarComp2=self:getAvatarComponent2() if not slua.isValid(uAvatarComp2) then return end local APostProcessManager=import("PostProcessManager") local PPM=APostProcessManager.GetInstance() if not slua.isValid(PPM) then return end if not PPM.IsPPEnabled then return end local GameplayData=require("GameLua.GameCore.Data.GameplayData") local uPlayerCharacter=GameplayData.GetPlayerCharacter() if not slua.isValid(uPlayerCharacter) then return end if bForce or (uPlayerCharacter.TeamID~=self.TeamID) then PPM.OutlineThickness=2 PPM:EnableAvatarOutline(uAvatarComp2,true) else PPM:EnableAvatarOutline(uAvatarComp2,false) end end
function BRPlayerCharacterBase:ApplyHighFPSConfig() local USTExtraGameInstance=import("GameInstance") local Instance=USTExtraGameInstance.GetInstance() if not Instance then return end Instance.LobbyRenderSwitch=true Instance.LobbyRenderSwitchHigh=true if Instance.UserDetailSetting then Instance.UserDetailSetting.PUBGDeviceFPSHigh=120 Instance.UserDetailSetting.PUBGDeviceFPSVerySmooth=120 Instance.UserDetailSetting.PUBGDeviceFPSLow=120 Instance.UserDetailSetting.PUBGDeviceFPSMid=120 Instance.UserDetailSetting.PUBGDeviceFPSHDR=120 Instance.UserDetailSetting.PUBGDeviceFPSUltralHigh=120 Instance.UserDetailSetting.PUBGDeviceFPSUltimateHigh=120 Instance.UserDetailSetting.PUBGDeviceFPSUltimateHighTA=120 Instance.UserDetailSetting.DeviceMaxQualityLevel=3 Instance.UserDetailSetting.UserQualitySetting=3 Instance.UserDetailSetting.UserEnergySaving=0 Instance.UserDetailSetting.UserShadowSetting=0 Instance.UserDetailSetting.UserShadowSwitch=0 Instance.UserDetailSetting.IsSupportMSAA=0 Instance.UserDetailSetting.UserMsaaSetting=false Instance.UserDetailSetting.UserVulkanSetting=1 Instance.UserDetailSetting.UserHDRSetting=0 end end
function BRPlayerCharacterBase:SetFOV110() local camera=self.ThirdPersonCameraComponent if not camera then return end camera:SetFieldOfView(110) end
function BRPlayerCharacterBase:SetCharacterShadowBoost()
  local settings = self.RendererSettings
  if not settings then 
    _G.WriteLog("RendererSettings instance nil")  
    return
  end
  settings.CharacterMinShadowFactor = 100
  _G.WriteLog("CharacterMinShadowFactor set successfully")
end
local class=require("class")
local CCharacterBase=require("GameLua.GameCore.Framework.CharacterBase")
local CBRPlayerCharacterBase=class(CCharacterBase,nil,BRPlayerCharacterBase)
return require("combine_class").DeclareFeature(CBRPlayerCharacterBase,{
{SkyTransition="GameLua.Mod.BaseMod.Gameplay.Feature.SkyControl.PlayerCharacterSkyTransitionFeature"},
{CarryDeadBoxFeature="GameLua.Mod.Library.GamePlay.Feature.CarryDeadBoxFeature"},
{SpecialSuitFeature="GameLua.Mod.Library.GamePlay.Feature.SpecialSuitFeature"},
{TeleportPawnFeature="GameLua.Mod.Library.GamePlay.Feature.TeleportPawnFeature"},
{LifterControl="GameLua.Mod.BaseMod.Gameplay.Feature.Player.CharacterLifterControlFeature"},
{FinalKillEffectFeature="GameLua.Mod.BaseMod.Gameplay.Feature.Player.PlayerCharacterFinalKillEffectFeature"},
{CampFeature="GameLua.Mod.BaseMod.GamePlay.Feature.Camp.PlayerCharacterCampFeature"},
{BuildSkateFeature="GameLua.Mod.Library.GamePlay.Feature.PlayerCharacterBuildVehicleFeature"},
{CommonBornlandTransformFeature="GameLua.Mod.BaseMod.GamePlay.Feature.HeroPropFeature.CommonBornlandTransformFeature"}
},"BRPlayerCharacterBase")
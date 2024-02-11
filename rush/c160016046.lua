--蒼救の晦冥 ネルクリタ
--Nelkrita the Skysavior Hadal
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160012023,CARD_SKYSAVIOR_LUA)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetTarget(s.target)
	c:RegisterEffect(e1)
end
function s.target(e,c)
	return c:IsRace(RACE_CELESTIALWARRIOR|RACE_WARRIOR|RACE_FAIRY) and c:GetEquipCount()>0
end
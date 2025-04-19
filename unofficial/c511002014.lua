--覇雷星 ライジン
--Raijin the Breakbolt Star
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,aux.FilterBoolFunctionEx2(Card.IsSky),aux.FilterBoolFunctionEx2(Card.IsEarth))
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
end
s.material_setcode={0x54a,0x51a}
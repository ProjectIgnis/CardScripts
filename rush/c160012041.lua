--蒼救の幻影 ドルクムーア
--Drukmoor the Skysavior Phantom
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon procedure
	Fusion.AddProcMix(c,true,true,160012025,CARD_SKYSAVIOR_LUA)
	--Face-up cards you control cannot be destroyed by your opponent's effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetTargetRange(LOCATION_ONFIELD,0)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(function(e,c) return c:IsFaceup() end)
	e1:SetValue(aux.indoval)
	c:RegisterEffect(e1)
end
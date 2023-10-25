--漆黒波導刀鬼丸クニツナ
--Pitch-Dark Surging-Wave Swordsman Onimaru Kunituna
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160015022,160015017)
	--Piercing battle damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e1)
	--Face-up Fish monsters you control cannot be destroyed by your opponent's effects
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTarget(s.indtg)
	e2:SetValue(aux.indoval)
	c:RegisterEffect(e2)
end
function s.indtg(e,c)
	return c:IsFaceup() and c:IsRace(RACE_FISH)
end
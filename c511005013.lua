--Otonari Thunder
--  By Shad3
--cleaned up and fixed by MLD
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_DECK)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCondition(s.spcon)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFaceup() and c:IsHunder()
end
function s.spcon(e,c)
	if not c then return true end
	local tp=c:GetControler()
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,4,nil)
end

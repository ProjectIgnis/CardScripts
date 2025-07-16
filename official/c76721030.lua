--暴君の暴言
--Tyrant's Tirade
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	e0:SetCost(s.cost)
	c:RegisterEffect(e0)
	--Effects of Effect Monsters that activate in the hand or on the field cannot be activated
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(1,1)
	e1:SetValue(function(e,re,tp) return re:IsMonsterEffect() and re:GetHandler():IsLocation(LOCATION_HAND|LOCATION_MZONE) end)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,nil,2,false,nil,nil) end
	local g=Duel.SelectReleaseGroupCost(tp,nil,2,2,false,nil,nil)
	Duel.Release(g,REASON_COST)
end
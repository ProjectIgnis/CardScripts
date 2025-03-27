--エンド・オブ・アヌビス
--The End of Anubis
local s,id=GetID()
function s.initial_effect(c)
	--negate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EVENT_CHAIN_SOLVING)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.DoubleSnareValidity(c,LOCATION_MZONE)
end
function s.gfilter(c)
	return c:IsLocation(LOCATION_GRAVE)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	if loc==LOCATION_GRAVE then return true end
	if not re:IsHasProperty(EFFECT_FLAG_CARD_TARGET) then return false end
	local g=Duel.GetChainInfo(ev,CHAININFO_TARGET_CARDS)
	return g and g:IsExists(s.gfilter,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.NegateEffect(ev)
end
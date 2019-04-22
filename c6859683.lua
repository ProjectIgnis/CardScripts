--成功確率0%
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return (c:IsFacedown() or c:IsType(TYPE_FUSION)) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if chk==0 then return g:FilterCount(s.filter,nil)>=2 end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsType,1-tp,LOCATION_EXTRA,0,nil,TYPE_FUSION)
	if #g<2 then return end
	local rg=g:RandomSelect(tp,2)
	Duel.SendtoGrave(rg,REASON_EFFECT)
end

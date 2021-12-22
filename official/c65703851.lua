--透破抜き
--Debunk
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_NEGATE+CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local loc=Duel.GetChainInfo(ev,CHAININFO_TRIGGERING_LOCATION)
	return (loc==LOCATION_HAND or loc==LOCATION_GRAVE) and re:IsActiveType(TYPE_MONSTER) and Duel.IsChainNegatable(ev)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local rc=re:GetHandler()
	local spelim=rc:IsLocation(LOCATION_GRAVE) and Duel.IsPlayerAffectedByEffect(rc:GetControler(),CARD_SPIRIT_ELIMINATION)
	if chk==0 then return not spelim and Duel.IsPlayerCanRemove(tp,rc) end
	Duel.SetOperationInfo(0,CATEGORY_NEGATE,eg,1,0,0)
	if not spelim and not rc:IsLocation(LOCATION_REMOVED) then
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,rc,1,0,0)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.NegateActivation(ev) and re:GetHandler():IsRelateToEffect(re) then
		Duel.Remove(eg,POS_FACEUP,REASON_EFFECT)
	end
end

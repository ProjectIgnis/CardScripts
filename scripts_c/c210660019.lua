--Law of the Kuriboh
--designed by Gideon
--scripted by Larry126
function c210660019.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c210660019.condition)
	e1:SetTarget(c210660019.target)
	e1:SetOperation(c210660019.activate)
	c:RegisterEffect(e1)
end
function c210660019.filter(c)
	return c:IsFaceup() and c:IsSetCard(0xa4) and c:IsLevel(1)
end
function c210660019.condition(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c210660019.filter,tp,LOCATION_MZONE,0,nil)
	return g:GetClassCount(Card.GetCode)==5
end
function c210660019.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_HAND,1,nil) end
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_HAND,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,sg,sg:GetCount(),0,0)
end
function c210660019.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Duel.GetMatchingGroup(aux.TRUE,tp,0,LOCATION_ONFIELD+LOCATION_HAND,nil)
	Duel.Remove(sg,POS_FACEUP,REASON_EFFECT)
end
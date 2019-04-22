--Mami's Ribbons
function c210533315.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(c210533315.condition)
	e1:SetTarget(c210533315.target)
	e1:SetOperation(c210533315.operation)
	c:RegisterEffect(e1)
end
c210533315.listed_names={210533304}
function c210533315.conf(c)
	return c:IsFaceup() and c:IsCode(210533304)
end
function c210533315.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210533315.conf,tp,LOCATION_ONFIELD,0,1,nil)
end
function c210533315.filter(c)
	return c:IsDefensePos() and c:IsAbleToRemove()
end
function c210533315.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(c210533315.filter,tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,#g,0,0)
end
function c210533315.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(c210533315.filter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
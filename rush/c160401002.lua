--コズミックストリング・ヌードルイダス
--Cosmic String Noodle-Druidess

local s,id=GetID()
function s.initial_effect(c)
	--Destroy all level 7 or lower monsters on the field
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160202046}

function s.costfilter(c)
	return c:IsType(TYPE_MONSTER) and c:IsRace(RACE_PYRO) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,2,nil) end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsCode,160202046),tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsLevelBelow,7),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,2,2,nil)
	if Duel.SendtoGrave(tg,REASON_COST)==2 then
		local g=Duel.GetMatchingGroup(aux.FilterFaceupFunction(Card.IsLevelBelow,7),tp,LOCATION_MZONE,LOCATION_MZONE,nil)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
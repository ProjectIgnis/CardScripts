--ブラック・ホール・デヴァイス
--Dark Hole Device
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--name change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetValue(53129443)
	c:RegisterEffect(e1)
	--Destroy all monsters on the field
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_DESTROY+CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetCost(s.cost)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={53129443} --Dark Hole
function s.confilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsType(TYPE_FUSION) and c:IsFaceup()
end
function s.cfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil)
		or Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,3,nil) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local sg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,sg,#sg,0,0)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
end
function s.thfilter(c)
	return c:IsRace(RACE_GALAXY) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if not Duel.IsExistingMatchingCard(s.confilter,tp,LOCATION_MZONE,0,1,nil) then
		if Duel.DiscardHand(tp,s.cfilter,3,3,REASON_COST+REASON_DISCARD,nil)<3 then return end
	end
	--Effect
	local sg=Duel.GetMatchingGroup(Card.IsNotMaximumModeSide,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=Duel.Destroy(sg,REASON_EFFECT)
	local g=Duel.GetMatchingGroup(aux.NecroValleyFilter(s.thfilter),tp,LOCATION_GRAVE,0,nil)
	if ct>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg,true)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
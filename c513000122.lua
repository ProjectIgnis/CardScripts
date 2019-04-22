--Virus Cannon (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsType(TYPE_SPELL) and c:IsAbleToGrave()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,1-tp,LOCATION_DECK+LOCATION_HAND,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,10,1-tp,LOCATION_DECK+LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local sg=Group.CreateGroup()
	if Duel.GetMatchingGroupCount(s.filter,1-tp,LOCATION_DECK+LOCATION_HAND,0,nil)<=10 then
		sg=Duel.GetMatchingGroup(s.filter,1-tp,LOCATION_DECK+LOCATION_HAND,0,nil)
	else
		sg=Duel.SelectMatchingCard(1-tp,s.filter,1-tp,LOCATION_DECK+LOCATION_HAND,0,10,10,nil)
	end
	Duel.SendtoGrave(sg,REASON_EFFECT)
end

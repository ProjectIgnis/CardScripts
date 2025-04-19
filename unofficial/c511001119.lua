--完全破壊－ジェノサイド・ウィルス－
--Deck Destruction Virus
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Send 10 random cards from your opponent's Deck to the GY
	local e2=e1:Clone()
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_SZONE)
	c:RegisterEffect(e2)
end
function s.cfilter(c)
	return c:GetPreviousAttributeOnField()&ATTRIBUTE_DARK>0 and c:GetPreviousRaceOnField()&RACE_FIEND>0
		and c:GetPreviousAttackOnField()<=500
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGrave,tp,0,LOCATION_DECK,10,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,1-tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsAbleToGrave,tp,0,LOCATION_DECK,nil)
	if #g<10 then return end
	g=g:RandomSelect(tp,10)
	Duel.DisableShuffleCheck()
	Duel.SendtoGrave(g,REASON_EFFECT)
end
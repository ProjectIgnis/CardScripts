--コーリング・ノヴァ
--Nova Summoner
local s,id=GetID()
function s.initial_effect(c)
	--special summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DESTROYED)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={18036057,CARD_SANCTUARY_SKY}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsLocation(LOCATION_GRAVE) and e:GetHandler():IsReason(REASON_BATTLE)
end
function s.filter1(c,e,tp)
	return c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.filter2(c,e,tp)
	return (c:IsCode(18036057) or (c:IsAttackBelow(1500) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_FAIRY)))
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.envfilter(c)
	return c:IsFaceup() and c:IsCode(CARD_SANCTUARY_SKY)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return false end
		if not (Duel.IsExistingMatchingCard(s.envfilter,0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or Duel.IsEnvironment(CARD_SANCTUARY_SKY)) then
			return Duel.IsExistingMatchingCard(s.filter1,tp,LOCATION_DECK,0,1,nil,e,tp)
		else
			return Duel.IsExistingMatchingCard(s.filter2,tp,LOCATION_DECK,0,1,nil,e,tp)
		end
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=nil
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	if not (Duel.IsExistingMatchingCard(s.envfilter,e:GetHandlerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) or Duel.IsEnvironment(CARD_SANCTUARY_SKY)) then
		g=Duel.SelectMatchingCard(tp,s.filter1,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	else
		g=Duel.SelectMatchingCard(tp,s.filter2,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	end
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

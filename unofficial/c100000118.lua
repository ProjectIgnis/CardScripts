--おジャマ・ゲットライド！
--Ojama Ride
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon up to 3 Level 4 or lower Machine Union monsters from your Deck
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={12482652,42941100,79335209}
function s.costfilter(c)
	return c:IsDiscardable() and c:IsAbleToGraveAsCost() and c:IsCode(12482652,42941100,79335209)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.costfilter,tp,LOCATION_HAND,0,nil)
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,0) end
	local cg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_DISCARD)
	Duel.SendtoGrave(cg,REASON_COST+REASON_DISCARD)
end
function s.filter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsRace(RACE_MACHINE) and c:IsType(TYPE_UNION)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	if ft<=0 then return end
	if ft>3 then ft=3 end
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then ft=1 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_DECK,0,1,ft,nil,e,tp)
	local c=e:GetHandler()
	for tc in g:Iter() do
		if Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE) then
			--Cannot change its battle position
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(3313)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
			e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
	Duel.SpecialSummonComplete()
end
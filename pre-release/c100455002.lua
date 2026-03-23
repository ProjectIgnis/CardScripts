--コミックキャット
--Comic Cat
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--This card is treated as a Toon monster while "Toon World" is on the field
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_ADD_TYPE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function() return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TOON_WORLD),0,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end)
	e1:SetValue(TYPE_TOON)
	c:RegisterEffect(e1)
	--During the Main Phase (Quick Effect): You can Tribute 1 monster (if you control "Toon World", you can Tribute 1 monster your opponent controls, even though you do not control it), and if you do, Special Summon 1 monster that mentions "Toon World" from your hand or Deck, ignoring its Summoning conditions
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_RELEASE+CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function() return Duel.IsMainPhase() end)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_TOON_WORLD}
function s.tribfilter(c,tp)
	return c:IsReleasableByEffect() and Duel.GetMZoneCount(tp,c)>0
end
function s.spfilter(c,e,tp)
	return c:ListsCode(CARD_TOON_WORLD) and c:IsMonster() and c:IsCanBeSpecialSummoned(e,0,tp,true,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		local opp_location=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TOON_WORLD),tp,LOCATION_ONFIELD,0,1,nil) and LOCATION_MZONE or 0
		return Duel.IsExistingMatchingCard(s.tribfilter,tp,LOCATION_MZONE,opp_location,1,nil,tp)
			and Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,nil,e,tp)
	end
	Duel.SetOperationInfo(0,CATEGORY_RELEASE,nil,1,PLAYER_EITHER,LOCATION_MZONE)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_DECK)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local opp_location=Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TOON_WORLD),tp,LOCATION_ONFIELD,0,1,nil) and LOCATION_MZONE or 0
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RELEASE)
	local rg=Duel.SelectMatchingCard(tp,s.tribfilter,tp,LOCATION_MZONE,opp_location,1,1,nil,tp)
	if #rg==0 then return end
	Duel.HintSelection(rg)
	if Duel.Release(rg,REASON_EFFECT)>0 and Duel.GetLocationCount(tp,LOCATION_MZONE)>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND|LOCATION_DECK,0,1,1,nil,e,tp)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,true,false,POS_FACEUP)
		end
	end
end
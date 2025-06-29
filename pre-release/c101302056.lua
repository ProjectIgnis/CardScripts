--剛鬼闘魂
--Gouki Fighting Spirit
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--When this card is activated: You can Special Summon 1 Level 4 or lower EARTH monster (Warrior, Dinosaur, or Cyberse) from your hand in Defense Position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Special Summon 1 "Dinowrestler" or "G Golem" monster from your Deck or Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(s.deckexspcost)
	e2:SetTarget(s.deckexsptg)
	e2:SetOperation(s.deckexspop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_GOUKI,SET_DINOWRESTLER,SET_G_GOLEM}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function s.handspfilter(c,e,tp)
	return c:IsLevelBelow(4) and c:IsAttribute(ATTRIBUTE_EARTH) and c:IsRace(RACE_WARRIOR|RACE_DINOSAUR|RACE_CYBERSE)
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local g=Duel.GetMatchingGroup(s.handspfilter,tp,LOCATION_HAND,0,nil,e,tp)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local sg=g:Select(tp,1,1,nil)
		if #sg>0 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		end
	end
end
function s.deckexcostfilter(c,e,tp)
	return c:IsLinkAbove(3) and c:IsSetCard(SET_GOUKI)
		and Duel.IsExistingMatchingCard(s.deckexspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,nil,e,tp,c)
end
function s.deckexspfilter(c,e,tp,cost_card)
	if not (c:IsSetCard({SET_DINOWRESTLER,SET_G_GOLEM}) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	if c:IsLocation(LOCATION_DECK) then
		return Duel.GetMZoneCount(tp,cost_card)>0
	elseif c:IsLocation(LOCATION_EXTRA) then
		return Duel.GetLocationCountFromEx(tp,tp,cost_card,c)>0
	end
end
function s.deckexspcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckReleaseGroupCost(tp,s.deckexcostfilter,1,false,nil,nil,e,tp) end
	local g=Duel.SelectReleaseGroupCost(tp,s.deckexcostfilter,1,1,false,nil,nil,e,tp)
	Duel.Release(g,REASON_COST)
end
function s.deckexsptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK|LOCATION_EXTRA)
end
function s.deckexspop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.deckexspfilter,tp,LOCATION_DECK|LOCATION_EXTRA,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
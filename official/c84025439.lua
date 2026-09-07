--超量機神王グレート・マグナス
--Super Quantal Mech King Great Magnus
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure: 3 Level 12 monsters
	Xyz.AddProcedure(c,nil,12,3)
	--If this card is sent to the GY: You can Special Summon 3 "Super Quantal Mech Beast" Xyz Monsters with different names from your GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--This card gains these effects, based on the number of materials with different names attached to it
	--● 2+: Once per turn, during the Main Phase (Quick Effect): You can detach 1 material from this card; shuffle 1 card on the field into the Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TODECK)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(aux.AND(
		function()
			return Duel.IsMainPhase()
		end,
		s.effcon(2))
	)
	e2:SetCost(Cost.DetachFromSelf(1))
	e2:SetTarget(s.tdtg)
	e2:SetOperation(s.tdop)
	e2:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	c:RegisterEffect(e2)
	--● 4+: It is unaffected by card effects, except "Super Quant" cards
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetCode(EFFECT_IMMUNE_EFFECT)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCondition(s.effcon(4))
	e3:SetValue(function(e,te)
		return not te:IsCardSetcode(SET_SUPER_QUANT)
	end)
	c:RegisterEffect(e3)
	--● 6+: Your opponent cannot add cards from the Deck to the hand by card effects
	local e4a=Effect.CreateEffect(c)
	e4a:SetType(EFFECT_TYPE_FIELD)
	e4a:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4a:SetCode(EFFECT_CANNOT_TO_HAND)
	e4a:SetRange(LOCATION_MZONE)
	e4a:SetTargetRange(0,1)
	e4a:SetCondition(s.effcon(6))
	e4a:SetTarget(function(e,c,rp,re)
		return c:IsLocation(LOCATION_DECK)
	end)
	c:RegisterEffect(e4a)
	local e4b=e4a:Clone()
	e4b:SetCode(EFFECT_CANNOT_DRAW)
	c:RegisterEffect(e4b)
end
s.listed_series={SET_SUPER_QUANT,SET_SUPER_QUANTAL_MECH_BEAST}
function s.spfilter(c,e,tp)
	return c:IsSetCard(SET_SUPER_QUANTAL_MECH_BEAST) and c:IsXyzMonster() and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return false end
		local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
		return #g>=3 and g:GetClassCount(Card.GetCode)>=3
	end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,3,tp,LOCATION_GRAVE)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<3 or Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then return end
	local g=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_GRAVE,0,nil,e,tp)
	if #g>=3 and g:GetClassCount(Card.GetCode)>=3 then
		local sg=aux.SelectUnselectGroup(g,e,tp,3,3,aux.dncheck,1,tp,HINTMSG_SPSUMMON)
		if #sg==3 then
			Duel.SpecialSummon(sg,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
function s.effcon(material_count)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return e:GetHandler():GetOverlayGroup():GetClassCount(Card.GetCode)>=material_count
	end
end
function s.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,PLAYER_EITHER,LOCATION_ONFIELD)
end
function s.tdop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,1,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
	end
end
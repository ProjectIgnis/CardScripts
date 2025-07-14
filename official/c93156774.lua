--ＶＳ ホーリー・スー
--Vanquish Soul Hollie Sue
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Special Summon this card from your hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_HAND)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetCost(Cost.AND(Cost.HardOncePerChain(id),s.spcost))
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--Activate 1 of these effects by revealing monster(s) in your hand with the listed Attribute(s)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1,{id,1})
	e2:SetCost(Cost.HardOncePerChain(id))
	e2:SetTarget(s.vstg)
	e2:SetOperation(s.vsop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_VANQUISH_SOUL}
function s.spcostfilter(c)
	return c:IsSetCard(SET_VANQUISH_SOUL) and c:IsMonster() and not c:IsPublic()
end
function s.spcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.spcostfilter,tp,LOCATION_HAND,0,1,c) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.spcostfilter,tp,LOCATION_HAND,0,1,1,c)
	Duel.ConfirmCards(1-tp,g)
	Duel.ShuffleHand(tp)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,c,1,tp,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.vscostfilter(c,att)
	return c:IsAttribute(att) and not c:IsPublic()
end
function s.vsrescon(sg)
	return sg:GetBinClassCount(Card.GetAttribute)==2
end
function s.deckspfilter(c,e,tp)
	return c:IsSetCard(SET_VANQUISH_SOUL) and not c:IsRace(RACE_PSYCHIC) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.vstg(e,tp,eg,ep,ev,re,r,rp,chk)
	local cg1=Duel.GetMatchingGroup(s.vscostfilter,tp,LOCATION_HAND,0,nil,ATTRIBUTE_EARTH|ATTRIBUTE_DARK)
	local b1=aux.SelectUnselectGroup(cg1,e,tp,2,2,s.vsrescon,0)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,1,nil)
	local cg2=Duel.GetMatchingGroup(s.vscostfilter,tp,LOCATION_HAND,0,nil,ATTRIBUTE_FIRE|ATTRIBUTE_DARK)
	local b2=aux.SelectUnselectGroup(cg2,e,tp,2,2,s.vsrescon,0)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.deckspfilter,tp,LOCATION_DECK,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,2)},
		{b2,aux.Stringid(id,3)})
	e:SetLabel(op)
	if op==1 then
		--EARTH & DARK
		local g=aux.SelectUnselectGroup(cg1,e,tp,2,2,s.vsrescon,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		e:SetCategory(CATEGORY_CONTROL)
		Duel.SetOperationInfo(0,CATEGORY_CONTROL,nil,1,1-tp,LOCATION_MZONE)
	elseif op==2 then
		--FIRE & DARK
		local g=aux.SelectUnselectGroup(cg2,e,tp,2,2,s.vsrescon,1,tp,HINTMSG_CONFIRM)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	end
end
function s.vsop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Take control of 1 monster your opponent controls with the lowest ATK (your choice, if tied) until the End Phase
		local g=Duel.GetMatchingGroup(aux.FaceupFilter(Card.IsControlerCanBeChanged),tp,0,LOCATION_MZONE,nil)
		if #g==0 then return end
		local ming=g:GetMinGroup(Card.GetAttack)
		local sc=ming:GetFirst()
		if #ming>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
			sc=ming:Select(tp,1,1,nil)
		end
		if sc then
			Duel.HintSelection(sc)
			Duel.GetControl(sc,tp,PHASE_END,1)
		end
	elseif op==2 then
		--Special Summon 1 non-Psychic "Vanquish Soul" monster from your Deck
		if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,s.deckspfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end
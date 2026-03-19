--月輪鏡
--Full Moon Mirror
local s,id=GetID()
local COUNTER_FULL_MOON=0x219
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_FULL_MOON)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Each time a monster(s) is destroyed by battle or card effect, place 1 Full Moon Counter on this card for each
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetRange(LOCATION_SZONE)
	e1:SetOperation(s.ctop)
	c:RegisterEffect(e1)
	--You can remove Full Moon Counters from this card, then activate 1 of these effects;
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,id)
	e2:SetTarget(s.efftg)
	e2:SetOperation(s.effop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_FULL_MOON}
function s.ctfilter(c)
	return ((c:IsMonster() and not c:IsPreviousLocation(LOCATION_ONFIELD)) or c:IsPreviousLocation(LOCATION_MZONE))
		and c:IsReason(REASON_BATTLE|REASON_EFFECT)
end
function s.ctop(e,tp,eg,ep,ev,re,r,rp)
	local des_count=eg:FilterCount(s.ctfilter,nil)
	if des_count==0 then return end
	local c=e:GetHandler()
	if not Duel.IsChainSolving() then
		c:AddCounter(COUNTER_FULL_MOON,des_count)
	else
		--Place 1 Full Moon Counter on this card at the end of the Chain Link
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_CHAIN_SOLVED)
		e1:SetRange(LOCATION_SZONE)
		e1:SetOperation(function() c:AddCounter(COUNTER_FULL_MOON,des_count) end)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
		c:RegisterEffect(e1)
		--Reset "e1" at the end of the Chain Link
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_CHAIN_SOLVED)
		e2:SetOperation(function() e1:Reset() end)
		e2:SetReset(RESET_CHAIN)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.lv6spfilter(c,e,tp)
	return c:IsLevelBelow(6) and c:IsRace(RACE_FIEND|RACE_FAIRY) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.thfilter(c)
	return c:IsLevel(10) and c:IsAttribute(ATTRIBUTE_DARK) and c:IsAbleToHand()
end
function s.lv10spfilter(c,e,tp)
	return c:IsLevel(10) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	--● 1: Special Summon 1 Level 6 or lower monster (Fiend or Fairy) from your hand or GY
	local b1=c:IsCanRemoveCounter(tp,COUNTER_FULL_MOON,1,REASON_COST) and mmz_chk
		and Duel.IsExistingMatchingCard(s.lv6spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	--● 3: Add 1 Level 10 DARK monster from your Deck to your hand
	local b2=c:IsCanRemoveCounter(tp,COUNTER_FULL_MOON,3,REASON_COST)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil)
	--● 5: Special Summon 1 Level 10 monster from your hand or GY
	local b3=c:IsCanRemoveCounter(tp,COUNTER_FULL_MOON,5,REASON_COST) and mmz_chk
		and Duel.IsExistingMatchingCard(s.lv10spfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil,e,tp)
	if chk==0 then return b1 or b2 or b3 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)},
		{b3,aux.Stringid(id,3)})
	e:SetLabel(op)
	c:RemoveCounter(tp,COUNTER_FULL_MOON,2*op-1,REASON_COST)
	if (op==1 or op==3) then
		e:SetCategory(CATEGORY_SPECIAL_SUMMON)
		Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
	elseif op==2 then
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local mmz_chk=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	if op==1 then
		--● 1: Special Summon 1 Level 6 or lower monster (Fiend or Fairy) from your hand or GY
		if not mmz_chk then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lv6spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	elseif op==2 then
		--● 3: Add 1 Level 10 DARK monster from your Deck to your hand
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil)
		if #g>0 then
			Duel.SendtoHand(g,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,g)
		end
	elseif op==3 then
		--● 5: Special Summon 1 Level 10 monster from your hand or GY
		if not mmz_chk then return end
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.lv10spfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil,e,tp)
		if #g>0 then
			Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
		end
	end
end

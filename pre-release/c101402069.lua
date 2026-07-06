--魔力到達
--Spell Power Attainment
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 card from your Deck or GY to your hand that mentions "Spell Counter" in its text, except "Spell Power Attainment", then if you control a Level 7 or higher "Endymion" Monster Card, you can remove any number of Spell Counters from your field, and if you do, negate the effects of that many face-up cards your opponent controls, and if you do that, destroy them
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DISABLE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	c:RegisterEffect(e1)
end
s.listed_names={id}
s.listed_series={SET_ENDYMION}
s.counter_list={COUNTER_SPELL}
function s.thfilter(c)
	return c:ListsCounter(COUNTER_SPELL) and c:IsAbleToHand() and not c:IsCode(id)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DESTROY,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.endymionfilter(c)
	return c:IsLevelAbove(7) and c:IsSetCard(SET_ENDYMION) and c:IsMonsterCard() and c:IsFaceup()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local sc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.thfilter),tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil):GetFirst()
	if not sc then return end
	if sc:IsLocation(LOCATION_GRAVE) then Duel.HintSelection(sc) end
	if Duel.SendtoHand(sc,nil,REASON_EFFECT)==0 or not sc:IsLocation(LOCATION_HAND) then return end
	if sc:IsPreviousLocation(LOCATION_DECK) then Duel.ConfirmCards(1-tp,sc) end
	Duel.ShuffleHand(tp)
	if not Duel.IsExistingMatchingCard(s.endymionfilter,tp,LOCATION_ONFIELD,0,1,nil) then return end
	if not Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,1,REASON_EFFECT) then return end
	local ng=Duel.GetMatchingGroup(Card.IsNegatable,tp,0,LOCATION_ONFIELD,nil)
	if #ng==0 or not Duel.SelectYesNo(tp,aux.Stringid(id,1)) then return end
	--needs to loop because Duel.GetCounter does not include checks for counters that can be removed
	local max_ct=1
	for i=2,#ng do
		if not Duel.IsCanRemoveCounter(tp,1,0,COUNTER_SPELL,i,REASON_EFFECT) then break end
		max_ct=i
	end
	local ct=max_ct==1 and 1 or Duel.AnnounceNumberRange(tp,1,max_ct)
	Duel.BreakEffect()
	if not Duel.RemoveCounter(tp,1,0,COUNTER_SPELL,ct,REASON_EFFECT) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local sng=ng:Select(tp,ct,ct,nil)
	if #sng==ct then
		Duel.HintSelection(sng)
		sng:Match(Card.IsCanBeDisabledByEffect,nil,e)
		--Negate their effects
		sng:ForEach(Card.NegateEffects,e:GetHandler())
		Duel.AdjustInstantly()
		Duel.Destroy(sng,REASON_EFFECT)
	end
end
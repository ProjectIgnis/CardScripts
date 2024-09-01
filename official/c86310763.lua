--粛声なる威光
--Radiance of the Voiceless Voice
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_ACTIVATE)
	e0:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e0)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_SZONE)
	e1:SetHintTiming(0,TIMING_MAIN_END|TIMINGS_CHECK_MONSTER)
	e1:SetCountLimit(1,id)
	e1:SetCondition(function() return Duel.IsMainPhase() end)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VOICELESS_VOICE}
function s.todeckfilter(c)
	return c:IsAbleToDeck() and (c:IsRitualSpell() or
		(c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR|RACE_DRAGON) and c:IsRitualMonster()))
end
function s.silenforcfilter(c,e,tp,ft)
	return c:IsSetCard(SET_VOICELESS_VOICE) and c:IsMonster() and (c:IsAbleToHand() or (ft>0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false)))
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsAttribute(ATTRIBUTE_LIGHT) and c:IsRace(RACE_WARRIOR|RACE_DRAGON) and c:IsRitualMonster() 
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsOnField() and chkc:IsControler(1-tp) end
	local b1=Duel.IsExistingMatchingCard(s.todeckfilter,tp,LOCATION_HAND|LOCATION_GRAVE,0,1,nil)
		and Duel.IsExistingMatchingCard(s.silenforcfilter,tp,LOCATION_DECK,0,1,nil,e,tp,Duel.GetLocationCount(tp,LOCATION_MZONE))
	local c=e:GetHandler()
	local ct=Duel.GetMatchingGroupCount(s.cfilter,tp,LOCATION_MZONE,0,nil)
	local b2=ct>0 and Duel.IsExistingTarget(nil,tp,0,LOCATION_ONFIELD,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		e:SetCategory(CATEGORY_TODECK+CATEGORY_SEARCH+CATEGORY_TOHAND+CATEGORY_SPECIAL_SUMMON)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND|LOCATION_GRAVE)
		Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
		Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
	elseif op==2 then
		e:SetCategory(CATEGORY_DESTROY)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectTarget(tp,nil,tp,0,LOCATION_ONFIELD,1,ct,nil)
		g:AddCard(c)
		Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,tp,0)
	end
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Shuffle 1 LIGHT Warrior or Dragon Ritual Monster or 1 Ritual Spell from your hand or GY into the Deck
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local tdc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.todeckfilter),tp,LOCATION_HAND|LOCATION_GRAVE,0,1,1,nil):GetFirst()
		if not tdc then return end
		if tdc:IsLocation(LOCATION_GRAVE) then Duel.HintSelection(tdc,true)
		else Duel.ConfirmCards(1-tp,tdc) end
		if Duel.SendtoDeck(tdc,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)>0 and tdc:IsLocation(LOCATION_DECK) then
			local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
			Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,3))
			local sc=Duel.SelectMatchingCard(tp,s.silenforcfilter,tp,LOCATION_DECK,0,1,1,nil,e,tp,ft):GetFirst()
			if sc then
				aux.ToHandOrElse(sc,tp,
					function() return ft>0 and sc:IsCanBeSpecialSummoned(e,0,tp,false,false) end,
					function() Duel.SpecialSummon(sc,0,tp,tp,false,false,POS_FACEUP) end,
					aux.Stringid(id,4)
				)
			end
		end
	elseif op==2 then
		--Destroy both the targets and this card
		local c=e:GetHandler()
		if not c:IsRelateToEffect(e) then return end
		local g=Duel.GetTargetCards(e)
		if #g==0 then return end
		g:AddCard(c)
		if #g>0 then
			Duel.Destroy(g,REASON_EFFECT)
		end
	end
end
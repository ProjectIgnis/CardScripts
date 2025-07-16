--アームズ・コール
--Armory Call
--Scripted by AlphaKretin
local s,id=GetID()
function s.initial_effect(c)
	--Add 1 Equip Spell from your Deck to your hand, then you can equip it to 1 appropriate monster you control
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_EQUIP)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
end
function s.thfilter(c)
	return c:IsEquipSpell() and c:IsAbleToHand()
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_EQUIP,nil,1,tp,LOCATION_HAND)
end
function s.eqfilter(c,ec)
	return ec:CheckEquipTarget(c) and c:IsFaceup()
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local ec=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if ec and Duel.SendtoHand(ec,nil,REASON_EFFECT)>0 and ec:IsLocation(LOCATION_HAND) then
		Duel.ConfirmCards(1-tp,ec)
		if not (ec:CheckUniqueOnField(tp) and not ec:IsForbidden() 
			and Duel.GetLocationCount(tp,LOCATION_SZONE)>0) then return end
		Duel.ShuffleHand(tp)
		local g=Duel.GetMatchingGroup(s.eqfilter,tp,LOCATION_MZONE,0,nil,ec)
		if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
			local sc=g:Select(tp,1,1,nil):GetFirst()
			if sc then
				Duel.HintSelection(sc)
				Duel.BreakEffect()
				Duel.Equip(tp,ec,sc)
			end
		end
	end
end
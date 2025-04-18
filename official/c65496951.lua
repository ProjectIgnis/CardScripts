--ヴァルモニカ・ディサルモニア
--Vaalmonica Disarmonia
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_COUNTER+CATEGORY_RECOVER+CATEGORY_DAMAGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VAALMONICA}
s.listed_names={id}
s.counter_place_list={COUNTER_RESONANCE}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCanAddCounter,tp,LOCATION_PZONE,0,1,nil,COUNTER_RESONANCE,1) end
	Duel.SetOperationInfo(0,CATEGORY_COUNTER,nil,1,0,COUNTER_RESONANCE)
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.thfilter(c)
	return c:IsSetCard(SET_VAALMONICA) and not c:IsCode(id) and c:IsFaceup() and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,angello_or_dimonno) --Additional parameter used by "Angello Vaalmonica" and "Dimonno Vaalmonica"
	local op=nil
	if angello_or_dimonno then
		op=angello_or_dimonno
	else
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_COUNTER)
		local tc=Duel.SelectMatchingCard(tp,Card.IsCanAddCounter,tp,LOCATION_PZONE,0,1,1,nil,COUNTER_RESONANCE,1):GetFirst()
		if not (tc and tc:AddCounter(COUNTER_RESONANCE,1)) then return end
		Duel.RaiseEvent(tc,EVENT_CUSTOM+39210885,e,0,tp,tp,1)
		op=Duel.SelectEffect(tp,
			{true,aux.Stringid(id,1)},
			{true,aux.Stringid(id,2)})
		Duel.BreakEffect()
	end
	if op==1 then
		--Gain 500 LP, then you can add 1 of your banished "Vaalmonica" cards to your hand
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_REMOVED,0,nil)
		if Duel.Recover(tp,500,REASON_EFFECT)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	elseif op==2 then
		--Take 500 damage, then you can add 1 "Vaalmonica" card from your GY to your hand
		local g=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
		if Duel.Damage(tp,500,REASON_EFFECT)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,4)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			local sg=g:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
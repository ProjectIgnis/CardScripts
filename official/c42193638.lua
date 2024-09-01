--ヴァルモニカ・ヴェルサーレ
--Vaalmonica Versare
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_RECOVER+CATEGORY_TOHAND+CATEGORY_SEARCH+CATEGORY_DAMAGE+CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_VAALMONICA}
s.listed_names={id}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK)
	Duel.SetPossibleOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,500)
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,1,tp,LOCATION_DECK)
end
function s.tgfilter(c)
	return c:IsSetCard(SET_VAALMONICA) and not c:IsCode(id) and c:IsAbleToGrave()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp,angello_or_dimonno) --Additional parameter used by "Angello Vaalmonica" and "Dimonno Vaalmonica"
	local op=nil
	if angello_or_dimonno then
		op=angello_or_dimonno
	else
		local sel_player=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_PZONE,0,1,nil,SET_VAALMONICA) and tp or 1-tp
		local offset=sel_player==1-tp and 2 or 0
		op=Duel.SelectEffect(sel_player,
			{true,aux.Stringid(id,1+offset)},
			{true,aux.Stringid(id,2+offset)})
	end
	if op==1 then
		--Gain 500 LP and excavate cards from the top of your Deck
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_DECK,0,nil,SET_VAALMONICA)
		if Duel.Recover(tp,500,REASON_EFFECT)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,5)) then
			local spcard,seq=g:GetMaxGroup(Card.GetSequence)
			spcard=spcard:GetFirst()
			if not spcard then return end
			Duel.BreakEffect()
			Duel.ConfirmDecktop(tp,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)-seq)
			if spcard:IsAbleToHand() then
				Duel.SendtoHand(spcard,nil,REASON_EFFECT)
				Duel.ConfirmCards(1-tp,spcard)
			else
				Duel.SendtoGrave(spcard,REASON_RULE)
			end
		end
	elseif op==2 then
		--Take 500 damage and send 1 "Vaalmonica" card from your Deck to the GY
		local g=Duel.GetMatchingGroup(s.tgfilter,tp,LOCATION_DECK,0,nil)
		if Duel.Damage(tp,500,REASON_EFFECT)>0 and #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,6)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
			local sg=g:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoGrave(sg,REASON_EFFECT)
		end
	end
end
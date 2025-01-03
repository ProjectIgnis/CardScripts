--凶導の聖告
--Dogmatikamatrix
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	--Look at either player's Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_TOGRAVE)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1)
	e2:SetCondition(s.gycon)
	e2:SetTarget(s.gytg)
	e2:SetOperation(s.gyop)
	c:RegisterEffect(e2)
end
s.listed_series={SET_DOGMATIKA}
function s.thfilter1(c)
	return c:IsSetCard(SET_DOGMATIKA) and (c:IsRitualMonster() or c:IsRitualSpell()) and c:IsAbleToHand()
end
function s.thfilter2(c)
	return c:IsSetCard(SET_DOGMATIKA) and c:IsAbleToHand()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.thfilter1,tp,LOCATION_DECK,0,nil,true)
	if #g>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:Select(tp,1,1,nil)
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,sg)
		g=Duel.GetMatchingGroup(s.thfilter2,tp,LOCATION_DECK,0,nil)
		if #g>0 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
			sg=g:Select(tp,1,1,nil)
			Duel.BreakEffect()
			Duel.SendtoHand(sg,nil,REASON_EFFECT)
			Duel.ConfirmCards(1-tp,sg)
		end
	end
end
function s.gyfilter(c)
	return c:IsFaceup() and c:IsSetCard(SET_DOGMATIKA) and c:IsType(TYPE_RITUAL)
end
function s.gycon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.gyfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.gytg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_EXTRA,LOCATION_EXTRA)>0 end
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,nil,1,PLAYER_EITHER,LOCATION_EXTRA)
end
function s.gyop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	if #g1==0 and #g2==0 then return end
	local op=Duel.SelectEffect(tp,
		{#g1>0,aux.Stringid(id,3)},
		{#g2>0,aux.Stringid(id,4)})
	local g=(op==1) and g1 or g2
	if op==2 then Duel.ConfirmCards(tp,g) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local tg=g:FilterSelect(tp,aux.AND(Card.IsMonster,Card.IsAbleToGrave),1,1,nil)
	if #tg>0 then
		Duel.BreakEffect()
		Duel.SendtoGrave(tg,REASON_EFFECT)
		if op==2 then Duel.ShuffleExtra(1-tp) end
	end
end
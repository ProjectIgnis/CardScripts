--魔導書再整理
--Spellbook Reorganization
--Scripted by Eerie Code
function c120401042.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(120401042,0))
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_IGNITION)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCountLimit(1,120401042)
	e2:SetCondition(c120401042.thcon)
	e2:SetTarget(c120401042.thtg)
	e2:SetOperation(c120401042.thop)
	c:RegisterEffect(e2)
	--to deck
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(120401042,2))
	e3:SetCategory(CATEGORY_DESTROY)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_CUSTOM+120401042)
	e3:SetTarget(c120401042.tdtg)
	e3:SetOperation(c120401042.tdop)
	c:RegisterEffect(e3)
end
function c120401042.thcfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
end
function c120401042.thcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c120401042.thcfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c120401042.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)>2 end
end
function c120401042.filter(c)
	return c:IsSetCard(0x106e) and c:IsAbleToHand()
end
function c120401042.thop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetFieldGroupCount(tp,LOCATION_DECK,0)<3 then return end
	local g=Duel.GetDecktopGroup(tp,3)
	Duel.ConfirmCards(tp,g)
	if g:IsExists(c120401042.filter,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(120401042,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local sg=g:FilterSelect(tp,c120401042.filter,1,1,nil)
		Duel.DisableShuffleCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
		Duel.RaiseSingleEvent(e:GetHandler(),EVENT_CUSTOM+120401042,re,r,rp,0,0)
		Duel.ConfirmCards(1-tp,sg)
		Duel.ShuffleHand(tp)
		Duel.SortDecktop(tp,tp,2)
	else Duel.SortDecktop(tp,tp,3) end
end
function c120401042.tdtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_HAND)
end
function c120401042.tdop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local tc=Duel.SelectMatchingCard(tp,Card.IsAbleToDeck,tp,LOCATION_HAND,0,1,1,nil):GetFirst()
	if tc then
		local opt=Duel.SelectOption(tp,aux.Stringid(120401042,3),aux.Stringid(120401042,4))
		Duel.SendtoDeck(tc,nil,opt,REASON_EFFECT)
	end
end

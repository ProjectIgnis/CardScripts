--メギストリーの儀術師
--Megistric Maginician
--scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	c:EnableCounterPermit(COUNTER_SPELL)
	--add counter
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e0:SetCode(EVENT_CHAINING)
	e0:SetRange(LOCATION_MZONE)
	e0:SetOperation(aux.chainreg)
	c:RegisterEffect(e0)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e1:SetCode(EVENT_CHAIN_SOLVED)
	e1:SetRange(LOCATION_MZONE)
	e1:SetOperation(s.acop)
	c:RegisterEffect(e1)
	--to hand
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCountLimit(1,id)
	e2:SetCode(EVENT_PHASE+PHASE_END)
	e2:SetCost(s.thcost)
	e2:SetTarget(s.thtg)
	e2:SetOperation(s.thop)
	c:RegisterEffect(e2)
end
s.counter_place_list={COUNTER_SPELL}
function s.acop(e,tp,eg,ep,ev,re,r,rp)
	if re:IsHasType(EFFECT_TYPE_ACTIVATE) and re:IsActiveType(TYPE_SPELL) and e:GetHandler():GetFlagEffect(1)>0 then
		e:GetHandler():AddCounter(COUNTER_SPELL,1)
	end
end
function s.thcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsCanRemoveCounter(tp,COUNTER_SPELL,3,REASON_COST) end
	e:GetHandler():RemoveCounter(tp,COUNTER_SPELL,3,REASON_COST)
end
function s.thfilter(c,code)
	return c:IsCode(code) and c:IsAbleToHand()
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsType(TYPE_SPELL) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,c:GetCode())
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_REMOVED) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local g=Duel.SelectTarget(tp,s.filter,tp,LOCATION_REMOVED,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,0,LOCATION_DECK)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.IsExistingMatchingCard(s.thfilter,tp,LOCATION_DECK,0,1,nil,tc:GetCode()) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
		local h=Duel.SelectMatchingCard(tp,s.thfilter,tp,LOCATION_DECK,0,1,1,nil,tc:GetCode())
		Duel.SendtoHand(h,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,h)
	end
end

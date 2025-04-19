--賢者の石 サバティエル
--Sabatiel - The Philosopher's Stone (VG)
local s,id=GetID()
function s.initial_effect(c)
	--Activate (Add to hand when your "Winged Kuriboh" is destroyed)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetRange(LOCATION_DECK)
	e1:SetCondition(s.thcon)
	e1:SetTarget(s.thtg)
	e1:SetOperation(s.thop)
	c:RegisterEffect(e1)
	--Activate (Add 1 card from your Deck or GY to hand OR increase your monster's ATK)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_ACTIVATE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetLabel(0)
	e2:SetTarget(s.target)
	e2:SetOperation(s.activate)
	c:RegisterEffect(e2)
end
s.listed_names={57116033} --"Winged Kuriboh"
function s.cfilter(c,tp)
	return c:IsCode(57116033) and c:IsPreviousControler(tp)
		and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsPreviousPosition(POS_FACEUP)
end
function s.thcon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(s.cfilter,1,nil,tp)
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToHand() end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,e:GetHandler(),1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if e:GetHandler():IsRelateToEffect(e) then
		Duel.SendtoHand(c,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,c)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.PayLPCost(tp,Duel.GetLP(tp)/2)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and chkc:IsFaceup() end
	local c=e:GetHandler()
	local ct=e:GetLabel()
	if chk==0 then 
		if ct<3 then
			return s.cost(e,tp,eg,ep,ev,re,r,rp,0) 
				and Duel.IsExistingMatchingCard(Card.IsAbleToHand,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,nil)
		else
			return Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
		end
	end
	if ct<3 then
		s.cost(e,tp,eg,ep,ev,re,r,rp,1)
		e:SetCategory(CATEGORY_TOHAND+CATEGORY_SEARCH)
		e:SetProperty(0)
		Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_DECK|LOCATION_GRAVE)
	else
		e:SetCategory(CATEGORY_ATKCHANGE)
		e:SetProperty(EFFECT_FLAG_CARD_TARGET)
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
		Duel.SelectTarget(tp,Card.IsFaceup,tp,LOCATION_MZONE,0,1,1,nil)
	end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()<3 then
		s.activate1(e,tp,eg,ep,ev,re,r,rp)
	else
		s.activate2(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.activate1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local ct=e:GetLabel()
	ct=ct+1
	c:SetTurnCounter(ct)
	e:SetLabel(ct)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToHand,tp,LOCATION_DECK|LOCATION_GRAVE,0,1,1,nil)
	if #g>0 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
		if c:IsRelateToEffect(e) then
			c:CancelToGrave()
			Duel.SendtoDeck(c,nil,2,REASON_EFFECT)
		end
	end
end
function s.activate2(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_SET_ATTACK_FINAL)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		e1:SetValue(tc:GetAttack()*ct)
		tc:RegisterEffect(e1)
	end
end
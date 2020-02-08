--戦華の詭－賈文
--Senka Schemer - Jia Wen
--Scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--to GY + attack decrease
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1,id)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
	--to hand 
	local e2=Effect.CreateEffect(c) 
	e2:SetDescription(aux.Stringid(id,1)) 
	e2:SetCategory(CATEGORY_TOHAND) 
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O) 
	e2:SetCode(EVENT_DESTROYED) 
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_CARD_TARGET) 
	e2:SetRange(LOCATION_MZONE) 
	e2:SetCountLimit(1,id+1) 
	e2:SetCondition(s.thcond) 
	e2:SetTarget(s.thtg) 
	e2:SetOperation(s.thop) 
	c:RegisterEffect(e2) 
end
s.listed_names={id}
s.listed_series={0x137}
function s.tgfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_CONTINUOUS) and c:IsType(TYPE_SPELL+TYPE_TRAP) and c:IsAbleToGrave()
end
function s.atkfilter(c)
	return c:IsFaceup() and c:GetAttack()>0
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chkc then return chkc:IsOnField() and chkc:IsControler(tp) and s.tgfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.tgfilter,tp,LOCATION_ONFIELD,0,1,nil)
		and Duel.IsExistingMatchingCard(s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectTarget(tp,s.tgfilter,tp,LOCATION_ONFIELD,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOGRAVE,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,2,0,0)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) and Duel.SendtoGrave(tc,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_GRAVE) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATTACK)
		local sg=Duel.SelectMatchingCard(tp,s.atkfilter,tp,LOCATION_MZONE,LOCATION_MZONE,2,2,nil)
		if #sg>0 then
			Duel.HintSelection(sg)
			for card in aux.Next(sg) do
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_SET_ATTACK_FINAL)
				e1:SetValue(card:GetAttack()//2)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				card:RegisterEffect(e1)
			end
		end
	end
end
function s.cfilter(c,tp) 
	return c:IsPreviousLocation(LOCATION_ONFIELD) and c:GetPreviousControler()==1-tp and c:IsReason(REASON_BATTLE+REASON_EFFECT) 
end 
function s.thcond(e,tp,eg,ep,ev,re,r,rp) 
	return eg:IsExists(s.cfilter,1,nil,tp) 
end
function s.thfilter(c)
	return c:IsSetCard(0x137) and c:IsAbleToHand() and not c:IsCode(id) 
end
function s.thtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.thfilter(chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.thfilter,tp,LOCATION_GRAVE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectTarget(tp,s.thfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,1,0,0)
end
function s.thop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SendtoHand(tc,nil,REASON_EFFECT)
	end
end


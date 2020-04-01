--神の威光
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,0,aux.FilterFaceupFunction(Card.IsSetCard,0x4b),nil,nil,0x1c0,0x1c1,nil,nil,nil,s.operation)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(aux.PersistentTargetFilter)
	e1:SetValue(1)
	c:RegisterEffect(e1)
end
s.listed_series={0x4b}
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_STANDBY)
		e2:SetRange(LOCATION_SZONE)
		e2:SetCountLimit(1)
		e2:SetLabel(2)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.tgcon)
		e2:SetOperation(s.tgop)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_STANDBY+RESET_SELF_TURN,2)
		c:RegisterEffect(e2)
	end
end
function s.tgcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.tgop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()
	ct=ct-1
	e:SetLabel(ct)
	if ct==0 and e:GetHandler():IsHasCardTarget(e:GetLabelObject()) then
		Duel.SendtoGrave(e:GetHandler(),REASON_EFFECT)
	end
end

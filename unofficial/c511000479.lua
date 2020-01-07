--Relativity Field
local s,id=GetID()
function s.initial_effect(c)
	local lp1=Duel.GetLP(c:GetControler())
	local lp2=Duel.GetLP(1-c:GetControler())
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--lose lp
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ADJUST)
	e2:SetRange(LOCATION_SZONE)
	e2:SetLabel(lp1)
	e2:SetCondition(s.lpcon1)
	e2:SetOperation(s.lpop1)
	c:RegisterEffect(e2)
	--lose lp 2
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_ADJUST)
	e3:SetRange(LOCATION_SZONE)
	e3:SetLabel(lp2)
	e3:SetCondition(s.lpcon2)
	e3:SetOperation(s.lpop2)
	c:RegisterEffect(e3)
	--lose atk
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetLabelObject(e2)
	e4:SetCondition(s.atkcon1)
	e4:SetOperation(s.atkop1)
	c:RegisterEffect(e4)
	--lose atk 2
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_SZONE)
	e5:SetLabelObject(e3)
	e5:SetCondition(s.atkcon2)
	e5:SetOperation(s.atkop2)
	c:RegisterEffect(e5)
end
function s.lpcon1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	return (Duel.GetLP(p)~=e:GetLabel() and not Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)) or Duel.GetLP(p)>e:GetLabel()
end
function s.lpcon2(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	return (Duel.GetLP(1-p)~=e:GetLabel() and not Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)) or Duel.GetLP(1-p)>e:GetLabel()
end
function s.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	e:SetLabel(Duel.GetLP(p))
end
function s.lpop2(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	e:SetLabel(Duel.GetLP(1-p))
end
function s.atkcon1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	return Duel.GetLP(p)<e:GetLabelObject():GetLabel() and Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)
end
function s.atkcon2(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	return Duel.GetLP(1-p)<e:GetLabelObject():GetLabel() and Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)
end
function s.atkop1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	local atk=e:GetLabelObject():GetLabel()-Duel.GetLP(p)
	e:GetLabelObject():SetLabel(Duel.GetLP(p))
	if Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil) then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,nil)
		tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end
function s.atkop2(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	local atk=e:GetLabelObject():GetLabel()-Duel.GetLP(1-p)
	e:GetLabelObject():SetLabel(Duel.GetLP(1-p))
	if Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil) then
		local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,0,LOCATION_MZONE,nil)
		tc=g:GetFirst()
		while tc do
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(-atk)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
			tc=g:GetNext()
		end
	end
end

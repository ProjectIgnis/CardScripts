-- Thousand Crisscross
-- Scripted by: UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	--recover
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,0x20018)
	e1:SetLabel(3)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_RECOVER)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetLabelObject(e1)
	e2:SetHintTiming(0,0x20018)
	e2:SetCondition(s.condition)
	e2:SetOperation(s.operation)
	c:RegisterEffect(e2)	
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	e:SetLabel(3)
	if Duel.GetLP(tp)<2000 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		Duel.SetLP(tp,2000,REASON_EFFECT)
		local ct=e:GetLabel()
		ct=ct-1
		e:SetLabel(ct)
		if ct<=0 then
			Duel.Destroy(e:GetHandler(),REASON_EFFECT)
		end
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetLP(tp)<2000 and not e:GetHandler():IsStatus(STATUS_CHAINING)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.SetLP(tp,2000,REASON_EFFECT)
	local ct=e:GetLabelObject():GetLabel()
	ct=ct-1
	e:GetLabelObject():SetLabel(ct)
	if ct<=0 then
		Duel.Destroy(e:GetHandler(),REASON_EFFECT)
	end
end

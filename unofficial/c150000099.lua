--プロテクト・ウィンド
--Protective Wind
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	if not re:IsActiveType(TYPE_MONSTER) then return false end
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and tg~=nil and tc>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	ge1:SetCode(EFFECT_DESTROY_REPLACE)
	ge1:SetLabelObject(re)
	ge1:SetTarget(s.reptg)
	ge1:SetValue(s.repval)
	ge1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(ge1,tp)
end
function s.repfilter(c,re)
	return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and c:GetReasonEffect()==re
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return eg:IsExists(s.repfilter,1,nil,e:GetLabelObject()) end
	return true
end
function s.repval(e,c)
	return not c:IsReason(REASON_REPLACE) and c:IsReason(REASON_EFFECT)
		and c:GetReasonEffect()==e:GetLabelObject()
end

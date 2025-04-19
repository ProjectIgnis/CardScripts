--ゼロ・プロテクション
--Zero Protection
--Scripted by Larry126
local s,id=GetID()
local LOCATION_DESTROY=LOCATION_ONFIELD|LOCATION_HAND|LOCATION_DECK|LOCATION_EXTRA
function s.initial_effect(c)
	--Activation
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_CHAINING)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local ex,tg,tc=Duel.GetOperationInfo(ev,CATEGORY_DESTROY)
	return ex and (tg~=nil and #tg>0 or tc>0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Cannot be destroyed
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetProperty(EFFECT_FLAG_SET_AVAILABLE)
	e1:SetTargetRange(LOCATION_DESTROY,LOCATION_DESTROY)
	e1:SetValue(s.efilter)
	e1:SetLabelObject(re)
	e1:SetReset(RESET_CHAIN)
	Duel.RegisterEffect(e1,tp)
end
function s.efilter(e,te)
	return te==e:GetLabelObject()
end
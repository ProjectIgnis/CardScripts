--死皇帝の陵墓
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--summon
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(92001300,0))
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SUMMON_PROC)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_HAND,LOCATION_HAND)
	e2:SetCondition(s.sumcon)
	e2:SetOperation(s.sumop)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_PROC)
	c:RegisterEffect(e3)
end
function s.sumcon(e,c,minc)
	if c==nil then return true end
	local mi,ma=c:GetTributeRequirement()
	if mi<minc then mi=minc end
	if ma<mi then return false end
	e:SetLabel(mi)
	return ma>0 and Duel.CheckLPCost(c:GetControler(),mi*500) and Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>0
end
function s.sumop(e,tp,eg,ep,ev,re,r,rp,c)
	Duel.PayLPCost(c:GetControler(),e:GetLabel()*500)
end

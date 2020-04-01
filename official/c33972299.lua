--ジオ・ジェネクス
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterSummonCode(68505803),1,1,Synchro.NonTunerEx(Card.IsAttribute,ATTRIBUTE_EARTH),1,99)
	c:EnableReviveLimit()
	--ad change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_SWAP_BASE_AD)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.valcon)
	c:RegisterEffect(e2)
end
s.listed_series={0x2}
function s.valcon(e)
	return e:GetHandler():GetFlagEffect(id)~=0
		and Duel.IsExistingMatchingCard(s.cfilter,e:GetHandler():GetControler(),LOCATION_MZONE,0,1,nil)
end
function s.cfilter(c)
	return c:IsLevelBelow(4) and c:IsFaceup() and c:IsSetCard(0x2)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
	end
end

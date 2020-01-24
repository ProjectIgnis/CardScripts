--フレッシュマドルチェ・シスタルト
--Madolche Fresh Sistart
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsSetCard,0x71),2,2)
	--destroy replace
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EFFECT_DESTROY_REPLACE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.desreptg)
	e1:SetOperation(s.desrepop)
	c:RegisterEffect(e1)
	--protect
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_ONFIELD,0)
	e2:SetCondition(s.indescon)
	e2:SetTarget(s.indestg)
	e2:SetValue(1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	c:RegisterEffect(e3)
end
s.listed_series={0x71}
function s.desrepfilter(c)
	return c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER) and c:IsAbleToDeck() and aux.nvfilter(c)
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not e:GetHandler():IsReason(REASON_RULE)
		and Duel.IsExistingMatchingCard(s.desrepfilter,tp,LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,e:GetHandler(),96)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g=Duel.SelectMatchingCard(tp,s.desrepfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(g,nil,2,REASON_EFFECT+REASON_REPLACE)
end
function s.linkfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:IsType(TYPE_MONSTER)
end
function s.indescon(e,c)
	return e:GetHandler():GetLinkedGroup():IsExists(s.linkfilter,1,nil)
end
function s.indestg(e,c)
	return c:IsFaceup() and c:IsSetCard(0x71) and c:IsType(TYPE_SPELL+TYPE_TRAP)
end

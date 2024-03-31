--火轟嵐凰ヴォルカライズ・フェニックス
--Blazebolt Chemistorm Fenghuang Volcalize Phoenix
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	c:AddMaximumAtkHandler()
end
s.MaximumAttack=3500
function s.filter1(c)
	return c:IsCode(160014015)
end
function s.filter2(c)
	return c:IsCode(160014017)
end
function s.condition(e)
	return e:GetHandler():IsMaximumMode()
end
function s.cfilter(c)
	return (c:IsRace(RACE_PYRO) or c:IsAttribute(ATTRIBUTE_FIRE)) and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_HAND,0,1,1,nil)
	if Duel.SendtoGrave(g,REASON_COST)~=1 then return end
	--Effect
	Duel.Damage(1-tp,1000,REASON_EFFECT)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(3012)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(function(e,re,rp) return re:IsTrapEffect() and re:GetOwnerPlayer()~=e:GetOwnerPlayer() end)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
	c:AddCenterToSideEffectHandler(e1)
	c:AddPiercing(RESETS_STANDARD_PHASE_END)
end
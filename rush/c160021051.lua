--ストライク・タマーボーリング
--Strike Tamabowling
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Gain ATK and piercing
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={CARD_TAMABOT}
function s.filter1(c)
	return c:IsFaceup() and c:IsCode(CARD_TAMABOT)
end
function s.filter2(c)
	return c:IsFaceup() and c:IsAttackAbove(100)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter1),tp,LOCATION_MZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TODECK,nil,1,tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local g1=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter1),tp,LOCATION_MZONE,0,1,1,nil)
	if #g1==0 then return end
	Duel.HintSelection(g1)
	local tc=g1:GetFirst()
	local g2=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter2),tp,0,LOCATION_MZONE,1,1,nil)
	if #g2==0 then return end
	Duel.HintSelection(g2)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetValue(g2:GetFirst():GetAttack())
	e1:SetRange(LOCATION_MZONE)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	tc:RegisterEffect(e1)
	tc:AddPiercing(RESETS_STANDARD_PHASE_END,c)
end
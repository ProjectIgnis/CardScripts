--叛骨のメイニ
--Meini the Defiant Soul
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Make up to 1 of your monsters gain 700 ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160018030,160018031}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsCode(160018030,160018031)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,2,REASON_COST)<0 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_APPLYTO)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil)
	Duel.HintSelection(g)
	local tc=g:GetFirst()
	--Effect
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetValue(700)
	e1:SetReset(RESETS_STANDARD_PHASE_END,2)
	tc:RegisterEffect(e1)
	--Cannot be destroyed by your opponent's card effects
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(3060)
	e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e2:SetValue(aux.indoval)
	e2:SetReset(RESETS_STANDARD_PHASE_END,2)
	tc:RegisterEffect(e2)
end
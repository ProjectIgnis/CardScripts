--ヴォイドヴェルグ・ストーク
--Voidvelg Stork
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name change
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={160018001,160010025}
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil) or Duel.IsPlayerCanDiscardDeckAsCost(tp,2) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return not c:IsCode(160018001) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local b1=Duel.IsExistingMatchingCard(Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,nil)
	local b2=Duel.IsPlayerCanDiscardDeckAsCost(tp,2)
	local op=Duel.SelectEffect(tp,{b1,aux.Stringid(id,1)},{b2,aux.Stringid(id,2)})
	local requiem=false
	if op==1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		local g=Duel.SelectMatchingCard(tp,Card.IsAbleToGraveAsCost,tp,LOCATION_HAND,0,1,1,nil)
		if Duel.SendtoGrave(g,REASON_COST)==0 then return end
		requiem=true
	elseif op==2 then
		if Duel.DiscardDeck(tp,2,REASON_COST)<0 then return end
	end
	--Effect
	local c=e:GetHandler()
	local code=160018001
	if not c:IsCode(160010025) and requiem and Duel.SelectYesNo(tp,aux.Stringid(id,3)) then
		code=160010025
	end
	--Name change
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_CHANGE_CODE)
	e1:SetValue(code)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	c:RegisterEffect(e1)
end
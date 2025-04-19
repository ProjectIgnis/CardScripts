--御茶女邪神ヌヴィア
--Nuvia the Mischievous
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	--Increase ATK of Aqua monsters by 200
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_ATKCHANGE+CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.atkcond)
	e1:SetCost(s.atkcost)
	e1:SetTarget(s.atktg)
	e1:SetOperation(s.atkop)
	c:RegisterEffect(e1)
end
s.listed_names={160010048}
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_AQUA) and c:IsNotMaximumModeSide()
end
function s.atkcond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetMatchingGroupCountRush(s.filter,tp,LOCATION_MZONE,0,nil)>=3
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.atktg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,0,nil)>0 end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,LOCATION_GRAVE)
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,nil,1,tp,0)
end
function s.thfilter(c)
	return c:IsCode(160010048) and c:IsAbleToHand()
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--effect
	local g=Duel.GetMatchingGroupRush(s.filter,tp,LOCATION_MZONE,0,nil)
	if #g==0 then return end
	local c=e:GetHandler()
	for tc in g:Iter() do
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(200)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		tc:RegisterEffect(e1)
	end
	local thg=Duel.GetMatchingGroup(s.thfilter,tp,LOCATION_GRAVE,0,nil)
	if #thg>0 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
		local sg=thg:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.BreakEffect()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
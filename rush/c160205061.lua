--夢中のランビリス
--Delirium Lampyris
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Take control of an opponent's Level 5-8 monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_CONTROL)
	e1:SetRange(LOCATION_MZONE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsFaceup),tp,0,LOCATION_MZONE,2,nil)
end
function s.costfilter(c,tp)
	return c:IsMonster() and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.ctrlfilter,tp,0,LOCATION_MZONE,1,nil,c:GetRace()) 
end
function s.ctrlfilter(c,race)
	return c:IsFaceup() and c:IsRace(race) and c:IsLevelAbove(5) and c:IsLevelBelow(8) and c:IsControlerCanBeChanged()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return e:GetHandler():IsAbleToGraveAsCost() and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil,tp) end
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,g,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local tg=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil,tp)
	local race=tg:GetFirst():GetRace()
	tg:AddCard(c)
	if Duel.SendtoGrave(tg,REASON_COST)~=2 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONTROL)
	local dg=Duel.SelectMatchingCard(tp,s.ctrlfilter,tp,0,LOCATION_MZONE,1,1,nil,race)
	if #dg>0 then
		Duel.HintSelection(dg,true)
		Duel.GetControl(dg,tp)
	end
end

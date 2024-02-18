--ラヴ・リターン
--Love Return
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Destroy the monsters with the highest levels
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_FAIRY) and c:GetBaseAttack()==0 and c:GetBaseDefense()==0
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==tp and r==REASON_RULE and Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	local sg=g:GetMaxGroup(Card.GetBaseAttack)
	if #sg>0 then
		sg=sg:AddMaximumCheck()
		Duel.SendtoHand(sg,nil,REASON_EFFECT)
	end
end
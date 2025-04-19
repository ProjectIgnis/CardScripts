--テールスイング
--Tail Swipe (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	-- Grant piercing damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_DINOSAUR) and c:IsLevelAbove(5)
		and Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_MZONE,1,nil,c:GetLevel())
end
function s.thfilter(c,lv)
	return (c:IsFacedown() or c:IsLevelBelow(lv-1)) and c:IsNotMaximumModeSide() and c:IsAbleToHand()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local tc=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,tp):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local sg=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_MZONE,1,2,nil,tc:GetLevel())
	sg=sg:AddMaximumCheck()
	Duel.HintSelection(sg)
	Duel.SendtoHand(sg,nil,REASON_EFFECT)
end
--バブリーマン・ショック！
--Bubbleburst Shock!
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsRace(RACE_AQUA) and c:IsFaceup() and c:IsLevelAbove(8)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.desfilter(c)
	return c:IsLevelBelow(8) and c:IsFaceup() and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	local atk=g:GetSum(Card.GetAttack)
	if chk==0 then return atk>0 end
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,tp,atk)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,0,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local g=Duel.GetMatchingGroup(s.desfilter,tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	local atk=g:GetSum(Card.GetAttack)
	if atk==0 then return end
	if Duel.Damage(tp,atk,REASON_EFFECT)>0 then
		Duel.BreakEffect()
		Duel.Destroy(g,REASON_EFFECT)
	end
end

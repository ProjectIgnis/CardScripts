--ジャイアント革命
--Gi-ant Revolution
--scripted by edo9300
local s,id=GetID()
function s.initial_effect(c)
	--Destroy all level 8 or lower monsters your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_INSECT) and c:IsAttackBelow(100)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	return tc and tc:IsControler(1-tp) and Duel.GetMatchingGroupCountRush(s.cfilter,tp,LOCATION_MZONE,0,nil)==3
end
function s.desfilter(c)
	return c:IsFaceup() and c:IsLevelBelow(8) and c:IsNotMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	if chk==0 then return #g>0 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,g,#g,0,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(aux.FilterMaximumSideFunctionEx(s.desfilter),tp,0,LOCATION_MZONE,nil)
	if #g==0 then return end
	Duel.Destroy(g,REASON_EFFECT)
end
--ロード・マジック－エクスプロージョン
--Road Magic - Explosion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.costfilter(c)
	return c:IsMonster() and c:IsAbleToGraveAsCost() and c:IsAttribute(ATTRIBUTE_FIRE)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c:IsRace(RACE_SPELLCASTER)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)>0 end
	Duel.SetTargetPlayer(1-tp)
	local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*400
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--requirement
	if Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST)>0 then
		--effect
		local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
		local dam=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD,0)*400
		Duel.Damage(p,dam,REASON_EFFECT)
	end
end
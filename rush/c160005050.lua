-- 魔迅雷
--Majinrai, the Striking Storm
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_HANDES+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	
end
s.listed_names={CARD_SUMMONED_SKULL}
function s.costfilter(c)
	return c:IsType(TYPE_NORMAL) and c:IsDiscardable() and c:IsAbleToGraveAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,e:GetHandler()) end
end
function s.filter(c)
	return c:IsRace(RACE_FIEND) and c:IsLevelAbove(7) and c:IsType(TYPE_NORMAL) and c:IsFaceup()
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return
	(Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_SUMMONED_SKULL),tp,LOCATION_MZONE,0,1,nil)
	or
	Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil))
end

function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(1300)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,1300)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	-- requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND,0,1,1,nil)
	local ct=Duel.SendtoGrave(g,REASON_COST)
	if ct>0 then
		--Effect
		local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
		Duel.Damage(p,d,REASON_EFFECT)
	end
end
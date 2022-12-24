-- βバーン・ドラゴン
-- Beta Burn Dragon
local s,id=GetID()
function s.initial_effect(c)
	--Inflict 100 damage per monster
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SUMMON_TURN) and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsRace,RACE_DRAGON),tp,LOCATION_MZONE,0,1,c)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)>0 end
	local ct=Duel.GetFieldGroupCountRush(tp,0,LOCATION_MZONE)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*100)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*100)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end
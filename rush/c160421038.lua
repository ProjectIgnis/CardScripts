 -- 陰陽士カラタケ
 -- Onmyou Warrior Karatake
local s,id=GetID()
function s.initial_effect(c)
	--Pay LP to deal damage
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e)
	return Duel.IsExistingMatchingCard(aux.FilterFaceupFunction(Card.IsRace,RACE_WARRIOR),e:GetHandlerPlayer(),LOCATION_MZONE,0,1,e:GetHandler())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local ct=Duel.GetFieldGroupCount(tp,0,LOCATION_SZONE)
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(ct*200)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,ct*200)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Damage(p,d,REASON_EFFECT)
end

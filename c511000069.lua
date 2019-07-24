--Toichi the Nefarious Debt Collector
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	--damage
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetCountLimit(1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	--indes
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetCondition(s.indcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
s.listed_names={511000068}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil,511000068) end
	local dam=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,511000068)*1000
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local d=Duel.GetMatchingGroupCount(Card.IsCode,tp,LOCATION_ONFIELD,LOCATION_ONFIELD,nil,511000068)*1000
	Duel.Damage(p,d,REASON_EFFECT)
end
function s.indfilter(c)
	return c:IsFaceup() and c:IsCode(511000068)
end
function s.indcon(e)
	return Duel.IsExistingMatchingCard(s.indfilter,e:GetOwnerPlayer(),LOCATION_ONFIELD,LOCATION_ONFIELD,1,nil)
end

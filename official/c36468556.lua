--停戦協定
--Ceasefire
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return (c:IsFaceup() and c:IsType(TYPE_EFFECT)) or c:IsPosition(POS_FACEDOWN_DEFENSE)
end
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_EFFECT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.tgfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local dam=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(dam)
	if dam>0 then Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,dam) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsPosition,tp,LOCATION_MZONE,LOCATION_MZONE,nil,POS_FACEDOWN_DEFENSE)
	Duel.ChangePosition(g,0,0,0,POS_FACEUP_DEFENSE,true)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local dam=Duel.GetMatchingGroupCount(s.filter,tp,LOCATION_MZONE,LOCATION_MZONE,nil)*500
	Duel.Damage(p,dam,REASON_EFFECT)
end

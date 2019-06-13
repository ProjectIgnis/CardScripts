--生命力吸収魔術
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(nil,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	local rec=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,LOCATION_MZONE,nil)*400
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(rec)
	if rec>0 then Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,rec) end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(Card.IsFacedown,tp,LOCATION_MZONE,LOCATION_MZONE,nil)
	Duel.ChangePosition(g,POS_FACEUP_ATTACK,POS_FACEUP_ATTACK,POS_FACEUP_DEFENSE,POS_FACEUP_DEFENSE,true)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local rec=Duel.GetMatchingGroupCount(aux.FilterFaceupFunction(Card.IsType,TYPE_EFFECT),tp,LOCATION_MZONE,LOCATION_MZONE,nil)*400
	Duel.Recover(p,rec,REASON_EFFECT)
end

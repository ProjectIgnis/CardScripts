--天使の涙
--Graceful Tear
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,LOCATION_HAND,0)>0 end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(2000)
	Duel.SetOperationInfo(0,CATEGORY_RECOVER,nil,0,tp,2000)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	local g=Duel.GetFieldGroup(p,LOCATION_HAND,0)
	if #g==0 then return end
	Duel.Hint(HINT_SELECTMSG,p,aux.Stringid(id,0))
	local sg=g:Select(p,1,1,nil)
	if Duel.SendtoHand(sg,1-p,REASON_EFFECT)~=0 then
		Duel.ShuffleHand(p)
		Duel.BreakEffect()
		Duel.Recover(p,d,REASON_EFFECT)
	end
end
--７チャンス
-- 7 Chance
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Draw and Gain LP
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp and Duel.GetAttacker():IsLevelAbove(7)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDraw(tp,3) end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	if Duel.Draw(tp,3,REASON_EFFECT)<2 then return end
	local dg=Duel.GetOperatedGroup()
	Duel.ConfirmCards(1-tp,dg)
	local ct=dg:FilterCount(Card.IsLevel,nil,7)
	if ct>1 then Duel.Recover(tp,ct*1500,REASON_EFFECT) end
	Duel.ShuffleHand(tp)
end
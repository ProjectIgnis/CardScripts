-- 手札増刷
--Card Reprinting
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Draw
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DRAW+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(function(_,tp) return Duel.GetAttacker():IsControler(1-tp) end)
	e1:SetTarget(s.drtg)
	e1:SetOperation(s.drop)
	c:RegisterEffect(e1)
end
function s.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=5-Duel.GetFieldGroupCountRush(tp,LOCATION_HAND,0)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDraw(tp,ct) end
	Duel.SetTargetPlayer(tp)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,ct)
end
function s.drop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	local ct=5-Duel.GetFieldGroupCountRush(tp,LOCATION_HAND,0)
	if ct<1 or Duel.Draw(p,ct,REASON_EFFECT)<1 then return end
	local hg=Duel.GetFieldGroup(tp,LOCATION_HAND,0)
	if #hg==0 then return end
	Duel.ConfirmCards(1-tp,hg)
	if #hg:Match(Card.IsMonster,nil)>0 then
		Duel.ShuffleHand(tp)
		Duel.Recover(tp,#hg*200,REASON_EFFECT)
	end
end
-- ハーディフェンス・ミッション
-- Hardefense Mission
-- Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	-- Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.destg)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==1-tp
end
function s.destg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tc=Duel.GetAttacker()
	if chk==0 then return tc:IsOnField() and tc:IsLevelBelow(8) and tc:GetBaseAttack()>=2500 end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,tc,1,0,0)
	Duel.SetChainLimit(function(e)return not e:IsHasType(EFFECT_TYPE_ACTIVATE)end)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttacker()
	if tc and tc:CanAttack() and tc:IsRelateToBattle() and not tc:IsStatus(STATUS_ATTACK_CANCELED) then
		local tg=Group.CreateGroup()
		tg:AddCard(tc)
		tg=tg:AddMaximumCheck()
		Duel.Destroy(tg,REASON_EFFECT)
	end
end

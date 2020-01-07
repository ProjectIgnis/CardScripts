--Shield Strike
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and eg:GetFirst():IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttacker()
	if chk==0 then return true end
	Duel.SetTargetPlayer(1-tp)
	Duel.SetTargetParam(tg:GetDefense())
	Duel.SetOperationInfo(0,CATEGORY_DAMAGE,nil,0,1-tp,tg:GetDefense())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tg=Duel.GetAttacker()
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if tg:IsRelateToBattle() then
		Duel.Damage(p,tg:GetDefense(),REASON_EFFECT)
	end
end

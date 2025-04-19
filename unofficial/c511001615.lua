--エクシーズ・スパイラル
--Xyz Spiral
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Inflict damage to your opponent equal to the Rank of attacking Xyz monster x 200
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetCategory(CATEGORY_DAMAGE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(s.damcon)
	e1:SetOperation(function(_,tp) Duel.Damage(1-tp,Duel.GetAttacker():GetRank()*200,REASON_EFFECT) end)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	--Draw 1 card at the end of the Battle Phase
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e2:SetCountLimit(1)
	e2:SetOperation(function(_,tp) Duel.Draw(tp,1,REASON_EFFECT) end)
	e2:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e2,tp)
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=Duel.GetAttackTarget()
	if not d then return false end
	return a:IsType(TYPE_XYZ) and d:IsDefensePos() and a:GetAttack()>d:GetDefense()
end
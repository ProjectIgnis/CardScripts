--トランザム・ライトニング
--Transam Lightning
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Prevent battle destruction
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetAttackTarget()
	local ac=Duel.GetAttacker()
	return tc and tc:IsFaceup() and tc:IsControler(tp) and ac:IsControler(1-tp)
		and tc:IsLevelBelow(4) and tc:IsType(TYPE_NORMAL) and tc:IsRace(RACE_GALAXY) and not tc:IsHasEffect(EFFECT_INDESTRUCTABLE_BATTLE)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=Duel.GetAttackTarget()
	if chk==0 then return tg:IsControler(tp) and tg:IsOnField() end
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	local d=Duel.GetAttackTarget()
	if d and d:IsRelateToBattle() and d:IsFaceup() then
		--Cannot be destroyed by battle
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetDescription(3000)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESETS_STANDARD_PHASE_END)
		d:RegisterEffect(e1)
	end
end
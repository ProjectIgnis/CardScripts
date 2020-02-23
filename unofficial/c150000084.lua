--連鎖ボーナス
--Chain Bonus
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DAMAGE_CAL)
	e1:SetTarget(s.condition)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	if not s.global_check then
		s.global_check=true
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
		e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
		e1:SetOperation(s.op)
		Duel.RegisterEffect(e1,0)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetBattleDamage(0)>0 or Duel.GetBattleDamage(1)>0 then
		Duel.RegisterFlagEffect(0,id,RESET_PHASE+PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return (Duel.GetBattleDamage(0)>0 or Duel.GetBattleDamage(1)>0)
		and Duel.GetFlagEffect(0,id)>0
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ge1=Effect.CreateEffect(e:GetHandler())
	ge1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	ge1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	ge1:SetReset(RESET_PHASE+PHASE_DAMAGE_CAL)
	ge1:SetOperation(s.dop)
	Duel.RegisterEffect(ge1,tp)
end
function s.dop(e,tp,eg,ep,ev,re,r,rp)
	Duel.DoubleBattleDamage(tp)
	Duel.DoubleBattleDamage(1-tp)
end

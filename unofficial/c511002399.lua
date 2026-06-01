--被弾回避
--Evasion Under Fire
local s,id=GetID()
function s.initial_effect(c)
	--If a player(s) would take battle damage: That damage becomes 0.
	local e1=Effect.CreateEffect(c)	
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetCondition(function(_,tp) return Duel.GetBattleDamage(tp)>0 or Duel.GetBattleDamage(1-tp)>0 end)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local dam=0
	if Duel.GetBattleDamage(tp)>0 then
		dam=dam+1
	end
	if Duel.GetBattleDamage(1-tp)>0 then
		dam=dam+2
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e1:SetOperation(s.damop)
	e1:SetLabel(dam)
	e1:SetReset(RESET_PHASE|PHASE_DAMAGE)
	Duel.RegisterEffect(e1,tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	local dam=e:GetLabel()
	if dam==1 then
		Duel.ChangeBattleDamage(tp,0)
	elseif dam==2 then
		Duel.ChangeBattleDamage(1-tp,0)
	elseif dam==3 then
		Duel.ChangeBattleDamage(tp,0)
		Duel.ChangeBattleDamage(1-tp,0)
	end
end

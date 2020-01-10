--オッドアイズ・ペンデュラム・ドラゴン
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--pendulum summon
	Pendulum.AddProcedure(c)
	--reduce
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(16178681,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCondition(s.rdcon)
	e2:SetOperation(s.rdop)
	c:RegisterEffect(e2)
	--double
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_PRE_BATTLE_DAMAGE)
	e4:SetCondition(s.damcon)
	e4:SetOperation(s.damop)
	c:RegisterEffect(e4)
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():GetFlagEffect(id)>0 then return false end
	local tc=Duel.GetAttacker()
	if tc:IsControler(1-tp) then tc=Duel.GetAttackTarget() end
	return ep==tp and tc and tc:IsType(TYPE_PENDULUM) and Duel.GetBattleDamage(tp)>0
end
function s.rdop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:GetFlagEffect(id)==0 and Duel.SelectEffectYesNo(tp,c) then
		Duel.Hint(HINT_CARD,0,id)
		c:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		Duel.ChangeBattleDamage(tp,0)
	end
end
function s.damcon(e,tp,eg,ep,ev,re,r,rp)
	local bc=e:GetHandler():GetBattleTarget()
	return ep~=tp and bc and bc:IsLevelAbove(5) and bc:IsControler(1-tp)
end
function s.damop(e,tp,eg,ep,ev,re,r,rp)
	Duel.ChangeBattleDamage(ep,ev*2)
end

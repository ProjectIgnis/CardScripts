--Welcome to the Jungle
--Scripted by The Razgriz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabelObject(e)
	e1:SetLabel(0)
	e1:SetOperation(s.op)
	c:RegisterEffect(e1)
end
s.listed_series={SET_AMAZONESS}
function s.op(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--Reduce ATK if your "Amazoness" monster battled an opponent's monster and you took battle damage
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_BATTLED)
	e1:SetRange(0x5f)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	Duel.RegisterEffect(e1,tp)
end
function s.bfilter(c)
	return c:IsAttackPos() and c:IsSetCard(SET_AMAZONESS)
end
function s.condition(e)
	local tp=e:GetHandlerPlayer()
	local a,at=Duel.GetBattleMonster(tp)
	return Duel.GetBattleDamage(tp)>0 and a and at and a:IsAttackPos() and a:IsSetCard(SET_AMAZONESS)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local cc,oc=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	if chk==0 then return s.bfilter(cc) and oc:IsOnField() and not oc:IsStatus(STATUS_BATTLE_DESTROYED) end
	Duel.SetOperationInfo(0,CATEGORY_ATKCHANGE,oc,1,tp,LOCATION_MZONE)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,0,id)
	local cc,oc=Duel.GetBattleMonster(tp),Duel.GetBattleMonster(1-tp)
	local atk=cc:GetAttack()
	if cc and cc:IsSetCard(SET_AMAZONESS) and oc and not oc:IsStatus(STATUS_BATTLE_DESTROYED) then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e1:SetValue(-atk)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_PHASE|PHASE_END)
		oc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_UPDATE_DEFENSE)
		oc:RegisterEffect(e2)
	end
end


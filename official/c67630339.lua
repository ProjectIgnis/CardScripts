--コンフュージョン・チャフ
local s,id=GetID()
function s.initial_effect(c)
	--damage cal
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		s[0]=0
		s[1]=0
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_ATTACK_ANNOUNCE)
		ge1:SetOperation(s.check)
		Duel.RegisterEffect(ge1,0)
		local ge2=Effect.CreateEffect(c)
		ge2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge2:SetCode(EVENT_ATTACK_DISABLED)
		ge2:SetOperation(s.check2)
		Duel.RegisterEffect(ge2,0)
		aux.AddValuesReset(function()
			s[0]=0
			s[1]=0
		end)
	end)
end
function s.check(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if Duel.GetAttackTarget()==nil then
		s[1-tc:GetControler()]=s[1-tc:GetControler()]+1
		Duel.GetAttacker():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		if s[1-tc:GetControler()]==1 then
			s[2]=Duel.GetAttacker()
		end
	end
end
function s.check2(e,tp,eg,ep,ev,re,r,rp)
	local tc=eg:GetFirst()
	if tc:GetFlagEffect(id)~=0 and Duel.GetAttackTarget()~=nil then
		s[1-tc:GetControler()]=s[1-tc:GetControler()]-1
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()~=tp and Duel.GetAttackTarget()==nil and s[tp]==2
		and s[2]:GetFlagEffect(id)~=0 and Duel.GetAttacker()~=s[2]
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local d=s[2]
	if a:GetFlagEffect(id)~=0 and d:GetFlagEffect(id)~=0 
		and a:CanAttack() and not a:IsImmuneToEffect(e) and not d:IsImmuneToEffect(e) then
		Duel.CalculateDamage(a,d)
	end
end

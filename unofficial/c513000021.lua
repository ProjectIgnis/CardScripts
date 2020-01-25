local s,id=GetID()function s.initial_effect(c)
	c:EnableReviveLimit()
	Fusion.AddProcCode2(c,78651105,96938777,true,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(s.vala)
	c:RegisterEffect(e1)
	--pos Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(s.regop)
	c:RegisterEffect(e2)
	--attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EFFECT_EXTRA_ATTACK)
	e3:SetValue(9999)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_DIRECT_ATTACK)
	e4:SetCondition(s.dircon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetCondition(s.atkcon2)
	c:RegisterEffect(e5)
end
function s.vala(e,c)
	local ca=e:GetHandler()
	return ca:GetFlagEffect(id)>0 
		and (c:GetLevel()>ca:GetLevel()-ca:GetFlagEffect(id) or c:IsFacedown())
end
function s.regop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d then
		local i=0
		local lv=d:GetLevel()
		while i<lv do
			e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE,0,0)
			i=i+1
		end
	end
end
function s.dircon(e)
	return e:GetHandler():GetAttackAnnouncedCount()>0
end
function s.atkcon2(e)
	return e:GetHandler():IsDirectAttacked()
end

function c513000021.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddFusionProcCode2(c,78651105,96938777,true,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e1:SetValue(c513000021.vala)
	c:RegisterEffect(e1)
	--pos Change
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(c513000021.regop)
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
	e4:SetCondition(c513000021.dircon)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EFFECT_CANNOT_ATTACK)
	e5:SetCondition(c513000021.atkcon2)
	c:RegisterEffect(e5)
end
function c513000021.vala(e,c)
	local ca=e:GetHandler()
	return ca:GetFlagEffect(513000021)>0 
		and (c:GetLevel()>ca:GetLevel()-ca:GetFlagEffect(513000021) or c:IsFacedown())
end
function c513000021.regop(e,tp,eg,ep,ev,re,r,rp)
	local d=Duel.GetAttackTarget()
	if d then
		local i=0
		local lv=d:GetLevel()
		while i<lv do
			e:GetHandler():RegisterFlagEffect(513000021,RESET_EVENT+0x1fe0000+RESET_PHASE+PHASE_BATTLE,0,0)
			i=i+1
		end
	end
end
function c513000021.dircon(e)
	return e:GetHandler():GetAttackAnnouncedCount()>0
end
function c513000021.atkcon2(e)
	return e:GetHandler():IsDirectAttacked()
end

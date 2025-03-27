--ソニック・シューター
--Sonic Shooter
local s,id=GetID()
function s.initial_effect(c)
	--Direct attack
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	e1:SetCondition(s.dircon)
	c:RegisterEffect(e1)
	--Reduce damage
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_CHANGE_BATTLE_DAMAGE)
	e2:SetCondition(s.rdcon)
	e2:SetValue(s.rdval)
	c:RegisterEffect(e2)
end
function s.dfilter(c)
	return c:GetSequence()<5
end
function s.dircon(e)
	return not Duel.IsExistingMatchingCard(s.dfilter,e:GetHandlerPlayer(),0,LOCATION_SZONE,1,nil)
end
function s.rdcon(e,tp,eg,ep,ev,re,r,rp)
	local c,tp=e:GetHandler(),e:GetHandlerPlayer()
	return Duel.GetAttackTarget()==nil and c:GetEffectCount(EFFECT_DIRECT_ATTACK)<2 and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
end
function s.rdval(e,damp)
	if damp==1-e:GetHandlerPlayer() then
		return e:GetHandler():GetBaseAttack()
	else
		return -1
	end
end
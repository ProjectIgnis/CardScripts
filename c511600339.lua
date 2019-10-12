--転生炎獣の熱芯
--Salamangreat Kernel
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,0,s.eqfilter)
	--immune
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetValue(s.immval)
	c:RegisterEffect(e1)
	--control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_CANNOT_CHANGE_CONTROL)
	c:RegisterEffect(e2)
	--indes
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e3:SetCondition(s.con)
	e3:SetValue(1)
	c:RegisterEffect(e3)
	--cannot remove
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCode(EFFECT_CANNOT_REMOVE)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.con)
	c:RegisterEffect(e4)
	--atk down
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_UPDATE_ATTACK)
	e5:SetRange(LOCATION_SZONE)
	e5:SetTargetRange(0,LOCATION_MZONE)
	e5:SetCondition(function(e) return Duel.GetCurrentPhase()&(PHASE_DAMAGE|PHASE_DAMAGE_CAL)>0 and Duel.GetAttacker()==e:GetHandler():GetEquipTarget() end)
	e5:SetTarget(s.atktg)
	e5:SetValue(-800)
	c:RegisterEffect(e5)
	--destroy replace
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_EQUIP)
	e6:SetCode(EFFECT_DESTROY_REPLACE)
	e6:SetCountLimit(1)
	e6:SetTarget(s.desreptg)
	e6:SetOperation(s.desrepop)
	c:RegisterEffect(e6)
end
s.listed_series={0x119}
function s.eqfilter(c)
	return c:IsSetCard(0x119) and c:GetSequence()>4
end
function s.immval(e,te)
	return te:IsActiveType(TYPE_MONSTER) and not te:GetHandler():IsType(TYPE_LINK)
		and e:GetHandlerPlayer()~=te:GetHandlerPlayer()and te:IsActivated()
end
function s.con(e)
	return e:GetHandler():GetEquipTarget()
end
function s.atktg(e,c)
	return Duel.GetAttackTarget()==c
end
function s.desrepfilter(c)
	return c:IsType(TYPE_LINK) and c:GetLink()>1 and c:IsSetCard(0x119) and c:IsAbleToExtra()
end
function s.desreptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local tg=c:GetEquipTarget()
	if chk==0 then return not c:IsStatus(STATUS_DESTROY_CONFIRMED)
		and tg and tg:IsReason(REASON_BATTLE+REASON_EFFECT) and not tg:IsReason(REASON_REPLACE)
		and Duel.IsExistingMatchingCard(s.desrepfilter,tp,LOCATION_GRAVE,0,1,nil) end
	return Duel.SelectEffectYesNo(tp,c)
end
function s.desrepop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESREPLACE)
	local tc=Duel.SelectMatchingCard(tp,s.desrepfilter,tp,LOCATION_GRAVE,0,1,1,nil)
	Duel.SendtoDeck(tc,nil,2,REASON_EFFECT+REASON_REPLACE)
	local c=e:GetHandler()
	local eqc=c:GetEquipTarget()
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
	eqc:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	eqc:RegisterEffect(e2)
end
function s.repval(e,c)
	return c==e:GetHandler():GetEquipTarget()
end

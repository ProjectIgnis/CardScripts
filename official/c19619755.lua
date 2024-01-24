--EM五虹の魔術師
--Performapal Five-Rainbow Magician
local s,id=GetID()
function s.initial_effect(c)
	Pendulum.AddProcedure(c)
	--Place itself from the GY in the Pendulum Zone
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SSET)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetCondition(s.pencon)
	e1:SetTarget(s.pentg)
	e1:SetOperation(s.penop)
	c:RegisterEffect(e1)
	--You cannot Pendulum Summon, except from the Extra Deck
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_PZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CANNOT_NEGATE)
	e2:SetTargetRange(1,0)
	e2:SetTarget(s.splimit)
	c:RegisterEffect(e2)
	--Monsters cannot attack
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetCode(EFFECT_CANNOT_ATTACK)
	e3:SetRange(LOCATION_PZONE)
	e3:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e3:SetTarget(s.atktg)
	c:RegisterEffect(e3)
	--Monsters cannot activate their effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetRange(LOCATION_PZONE)
	e4:SetTargetRange(1,1)
	e4:SetValue(s.limval)
	c:RegisterEffect(e4)
	--Double the ATK of monsters on the field
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD)
	e5:SetCode(EFFECT_SET_ATTACK_FINAL)
	e5:SetRange(LOCATION_PZONE)
	e5:SetTargetRange(LOCATION_MZONE,0)
	e5:SetCondition(s.atkcon0)
	e5:SetValue(s.atkval)
	c:RegisterEffect(e5)
	local e6=e5:Clone()
	e6:SetTargetRange(0,LOCATION_MZONE)
	e6:SetCondition(s.atkcon1)
	c:RegisterEffect(e6)
end
function s.pencon(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(Card.IsControler,1,nil,tp)
end
function s.pentg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckPendulumZones(tp) end
	Duel.SetOperationInfo(0,CATEGORY_LEAVE_GRAVE,e:GetHandler(),1,0,0)
end
function s.penop(e,tp,eg,ep,ev,re,r,rp)
	if e:GetHandler():IsRelateToEffect(e) and Duel.CheckPendulumZones(tp) then
		Duel.MoveToField(e:GetHandler(),tp,tp,LOCATION_PZONE,POS_FACEUP,true)
	end
end
function s.splimit(e,c,tp,sumtp,sumpos)
	return (sumtp&SUMMON_TYPE_PENDULUM)==SUMMON_TYPE_PENDULUM and not c:IsLocation(LOCATION_EXTRA)
end
function s.countfilter(c)
	return c:IsFacedown() and c:GetSequence()<5
end
function s.atktg(e,c)
	local tp=c:GetControler()
	return Duel.GetMatchingGroupCount(s.countfilter,tp,LOCATION_SZONE,0,nil)==0
end
function s.limval(e,re,rp)
	local rc=re:GetHandler()
	local tp=rc:GetControler()
	return rc:IsLocation(LOCATION_MZONE) and re:IsMonsterEffect()
		and Duel.GetMatchingGroupCount(s.countfilter,tp,LOCATION_SZONE,0,nil)==0
end
function s.atkcon0(e)
	return Duel.GetMatchingGroupCount(s.countfilter,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)>=4
end
function s.atkcon1(e)
	return Duel.GetMatchingGroupCount(s.countfilter,e:GetHandlerPlayer(),0,LOCATION_SZONE,nil)>=4
end
function s.atkval(e,c)
	return c:GetBaseAttack()*2
end
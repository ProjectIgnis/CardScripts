--眠れる巨人ズシン
--Zushin the Sleeping Giant (TF6)
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Cannot be Special Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--Special summon procedure
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--ATK/DEF increase
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.atkup)
	c:RegisterEffect(e3)
	--Unaffected
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetValue(s.efilter)
	c:RegisterEffect(e4)
	aux.GlobalCheck(s,function()
		--Special summon procedure
		local e0=Effect.CreateEffect(c)
		e0:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e0:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e0:SetCode(EVENT_PHASE+PHASE_END)
		e0:SetCountLimit(1)
		e0:SetOperation(s.endop)
		Duel.RegisterEffect(e0,0)
	end)
end
function s.spfilter1(c)
	return c:IsFaceup() and c:IsLevel(1) and c:IsType(TYPE_NORMAL)
end
function s.endop(e,tp,c)
	local c=e:GetHandler()
	local g=Duel.GetMatchingGroup(s.spfilter1,Duel.GetTurnPlayer(),LOCATION_MZONE,0,nil)
	local rc=g:GetFirst()
	while rc do
		if rc:GetFlagEffect(id)==0 then
			local e1=Effect.CreateEffect(rc)
			e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_PHASE_START+PHASE_STANDBY)
			e1:SetCountLimit(1)
			e1:SetRange(LOCATION_MZONE)
			e1:SetCondition(s.ctcon)
			e1:SetLabel(0)
			e1:SetOperation(s.ctop)
			rc:RegisterEffect(e1)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=g:GetNext()
	end
end
function s.ctcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp)
end
function s.ctop(e,tp,c)
	local c=e:GetHandler()
	if not c:IsControler(Duel.GetTurnPlayer()) then return end
	local ct=e:GetLabel()
	if c:GetFlagEffect(id)~=0 and ct==8 then 
		c:RegisterFlagEffect(id+1,RESET_EVENT+RESETS_STANDARD,0,1)
	else
		e:SetLabel(ct+1)
	end
end
function s.filter(c,tp)
	return c:IsFaceup() and c:IsLevel(1) and c:IsType(TYPE_NORMAL) and c:GetFlagEffect(id+1)~=0
end
function s.spcon(e,c)
	if c==nil then return true end
	return Duel.CheckReleaseGroup(c:GetControler(),s.filter,1,false,1,true,c,c:GetControler(),nil,false,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.filter,1,1,false,true,true,c,nil,nil,false,nil)
	if g then
		g:KeepAlive()
		e:SetLabelObject(g)
	return true
	end
	return false
end
function s.spop(e,tp,eg,ep,ev,re,r,rp,c)
	local g=e:GetLabelObject()
	if not g then return end
	Duel.Release(g,REASON_COST)
	g:DeleteGroup()
end
function s.atkup(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=c:GetBattleTarget()
	if not tc or tc:IsControler(tp) then return end
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_SET_ATTACK)
	e1:SetValue(tc:GetAttack()+1000)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_DAMAGE_CAL)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(e:GetHandler())
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_DISABLE)
	e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE)
	tc:RegisterEffect(e3)
	local e4=e3:Clone()
	e4:SetCode(EFFECT_DISABLE_EFFECT)
	tc:RegisterEffect(e4)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
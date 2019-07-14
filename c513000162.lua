--Zushin the Sleeping Giant (Anime)
--眠れる巨人ズシン 
--scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--cannot special summon
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.FALSE)
	c:RegisterEffect(e1)
	--special summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SPSUMMON_PROC)
	e2:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e2:SetRange(LOCATION_HAND)
	e2:SetCondition(s.spcon3)
	e2:SetOperation(s.spop3)
	c:RegisterEffect(e2)
	--atk/def up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_SET_ATTACK_FINAL)
	e3:SetRange(LOCATION_MZONE)
	e3:SetValue(s.value)
	c:RegisterEffect(e3)
	--negate
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_DISABLE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(0,LOCATION_MZONE)
	e4:SetTarget(s.distg)
	c:RegisterEffect(e4)
	--cannot be target
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(1)
	c:RegisterEffect(e5)
	aux.GlobalCheck(s,function()
		--spsummon proc
		local e2=Effect.CreateEffect(c) 
		e2:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetOperation(s.spop)
		Duel.RegisterEffect(e2,0)
	end)
end
function s.distg(e,c)
	local uc=e:GetHandler()
	if Duel.GetAttacker()==uc then
		return Duel.GetAttackTarget()==c
	elseif Duel.GetAttackTarget()==uc then
		return Duel.GetAttacker()==c
	else return false end
end
function s.value(e,c)
	local g=Duel.GetMatchingGroup(aux.TRUE,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil)
	local uc=g:GetFirst()
	while uc do
		if Duel.GetAttacker()==uc and Duel.GetAttackTarget()==c then
			return uc:GetAttack()+1000
		elseif Duel.GetAttackTarget()==uc and Duel.GetAttacker()==c then
			return uc:GetAttack()+1000
		else return 0 
		end
		uc=g:GetNext()
	end
end
function s.spfilter1(c)
	return c:IsFaceup() and c:GetLevel()==1 and c:IsType(TYPE_NORMAL)
end
function s.spop(e,tp,c)
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
			e1:SetCondition(s.spcon1)
			e1:SetLabel(0)
			e1:SetOperation(s.spop2)
			rc:RegisterEffect(e1)
			rc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1)
		end
		rc=g:GetNext()
	end
end
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetTurnPlayer()==tp
end
function s.spop2(e,tp,c)
	local c=e:GetHandler()
	if c:GetControler()~=Duel.GetTurnPlayer() then return end
	local ct=e:GetLabel()
	if c:GetFlagEffect(id)~=0 and ct==8 then 
		c:RegisterFlagEffect(100000111,RESET_EVENT+RESETS_STANDARD,0,1) 
	else	
		e:SetLabel(ct+1)
	end
end
function s.filter(c)
	return c:IsFaceup() and c:GetLevel()==1 and c:IsType(TYPE_NORMAL) and c:GetFlagEffect(100000111)~=0
end
function s.spcon3(e,c)
	local c=e:GetHandler()
	if c==nil then return true end
	return Duel.GetLocationCount(c:GetControler(),LOCATION_MZONE)>-1
		and Duel.CheckReleaseGroup(c:GetControler(),s.filter,1,nil)
end
function s.spop3(e,tp,eg,ep,ev,re,r,rp,c)
	local g=Duel.SelectReleaseGroup(tp,s.filter,1,1,nil)
	Duel.Release(g,REASON_COST)
end
function s.efilter(e,te)
	return te:GetOwner()~=e:GetOwner()
end
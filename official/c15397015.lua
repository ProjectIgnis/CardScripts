--インスペクト・ボーダー
--Inspect Boarder
local s,id=GetID()
function s.initial_effect(c)
	--summon limit
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_CANNOT_SUMMON)
	e1:SetCondition(s.sumcon)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e2:SetCode(EFFECT_SPSUMMON_CONDITION)
	e2:SetValue(s.sumlimit)
	c:RegisterEffect(e2)
	--activate limit
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e2:SetCode(EVENT_CHAINING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetOperation(s.aclimit1)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetCode(EVENT_CHAIN_NEGATED)
	e3:SetRange(LOCATION_MZONE)
	e3:SetOperation(s.aclimit2)
	c:RegisterEffect(e3)
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e4:SetCode(EFFECT_CANNOT_ACTIVATE)
	e4:SetRange(LOCATION_MZONE)
	e4:SetTargetRange(1,0)
	e4:SetCondition(s.econ1)
	e4:SetValue(s.elimit)
	c:RegisterEffect(e4)
	local e5=e2:Clone()
	e5:SetOperation(s.aclimit3)
	c:RegisterEffect(e5)
	local e6=e3:Clone()
	e6:SetOperation(s.aclimit4)
	c:RegisterEffect(e6)
	local e7=e4:Clone()
	e7:SetCondition(s.econ2)
	e7:SetTargetRange(0,1)
	c:RegisterEffect(e7)
end
function s.sumcon(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_MZONE,0)>0
end
function s.sumlimit(e,se,sp,st,pos,tp)
	return Duel.GetFieldGroupCount(sp,LOCATION_MZONE,0)==0 and sp~=e:GetHandlerPlayer()
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK)
end
function s.typecount(c)
	return c:GetType()&TYPE_FUSION+TYPE_RITUAL+TYPE_SYNCHRO+TYPE_XYZ+TYPE_PENDULUM+TYPE_LINK
end
function s.aclimit1(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_CONTROL+RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit2(e,tp,eg,ep,ev,re,r,rp)
	if ep~=tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(id)
end
function s.econ1(e)
	local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetClassCount(s.typecount)
	return e:GetHandler():GetFlagEffect(id)>=ct
end
function s.aclimit3(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsActiveType(TYPE_MONSTER) then return end
	e:GetHandler():RegisterFlagEffect(id+1,RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_CONTROL+RESET_PHASE+PHASE_END,0,1)
end
function s.aclimit4(e,tp,eg,ep,ev,re,r,rp)
	if ep==tp or not re:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
	e:GetHandler():ResetFlagEffect(id+1)
end
function s.econ2(e)
	local g=Duel.GetMatchingGroup(s.cfilter,e:GetHandlerPlayer(),LOCATION_MZONE,LOCATION_MZONE,nil)
	local ct=g:GetClassCount(s.typecount)
	return e:GetHandler():GetFlagEffect(id+1)>=ct
end
function s.elimit(e,re,tp)
	return re:IsActiveType(TYPE_MONSTER)
end

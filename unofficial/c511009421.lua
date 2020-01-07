--Dragon Creeping Plant
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	aux.AddPersistentProcedure(c,1,s.filter,CATEGORY_CONTROL,nil,nil,nil,s.condition,nil,s.target)
	--atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_SET_CONTROL)
	e1:SetRange(LOCATION_SZONE)
	e1:SetTargetRange(LOCATION_MZONE,LOCATION_MZONE)
	e1:SetTarget(s.cttg)
	e1:SetValue(s.ctval)
	c:RegisterEffect(e1)
	--destroy2
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.descon)
	e3:SetOperation(s.desop)
	c:RegisterEffect(e3)
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_DRAGON)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil)
end
function s.filter(c)
	local g=Duel.GetFieldGroup(c:GetControler(),LOCATION_MZONE,0)
	if #g<=0 then return false end
	local sg=g:GetMaxGroup(Card.GetLevel)
	if not sg then return false end
	return c:IsFaceup() and c:IsRace(RACE_DRAGON) and c:IsControlerCanBeChanged() 
		and (not sg:IsContains(c) or (c:IsType(TYPE_XYZ) and not c:IsHasEffect(EFFECT_RANK_LEVEL) and not c:IsHasEffect(EFFECT_RANK_LEVEL_S)))
end
function s.target(e,tp,eg,ep,ev,re,r,rp,tc,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_CONTROL,tc,1,0,0)
end
function s.cttg(e,c)
	return e:GetHandler():IsHasCardTarget(c)
end
function s.ctval(e,c)
	return e:GetHandlerPlayer()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsStatus(STATUS_DESTROY_CONFIRMED) then return false end
	local tc=c:GetFirstCardTarget()
	return tc and eg:IsContains(tc)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Destroy(e:GetHandler(),REASON_EFFECT)
end

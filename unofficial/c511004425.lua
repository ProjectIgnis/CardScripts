--Rank-Up Gravity
--fixed by MLD
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--cannot attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCondition(s.tgcon)
	e2:SetTargetRange(0,LOCATION_MZONE)
	e2:SetValue(s.tgval)
	c:RegisterEffect(e2)
	--banishu
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
	e3:SetRange(LOCATION_SZONE)
	e3:SetOperation(s.rmop)
	c:RegisterEffect(e3)
	--SDestroy
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetRange(LOCATION_SZONE)
	e4:SetCondition(s.descon)
	e4:SetOperation(s.desop)
	c:RegisterEffect(e4)
	--activate
	aux.GlobalCheck(s,function()
		local e1=Effect.CreateEffect(c)
		e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_SPSUMMON_SUCCESS)
		e1:SetOperation(s.rumcheck)
		Duel.RegisterEffect(e1,0)
	end)
end
function s.rumcheck(e,tp,eg,ev,ep,re,r,rp)
	if not re then return end
	local rc=re:GetHandler()
	if rc:IsSetCard(0x95) and rc:IsType(TYPE_SPELL) then
		local ec=eg:GetFirst()
		while ec do
			ec:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
			ec=eg:GetNext()
		end
	end
end
function s.filter(c)
	return c:IsType(TYPE_XYZ) and c:GetFlagEffect(id)~=0
end
function s.tgcon(e,tp,eg,ev,ep,re,r,rp)
	return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil)
end
function s.tgval(e,c)
	return not s.filter(c)
end
function s.rmfilter(c)
	return c:GetAttackedCount()==0 and c:IsAbleToRemove()
end
function s.rmop(e,tp,eg,ev,ep,re,r,rp)
	if Duel.GetTurnPlayer()==tp then return end
	local g=Duel.GetMatchingGroup(s.rmfilter,tp,0,LOCATION_MZONE,nil)
	if #g>0 then
		Duel.Hint(HINT_CARD,0,id)
		Duel.Remove(g,POS_FACEUP,REASON_EFFECT)
	end
end
function s.descon(e,tp,eg,ev,ep,re,r,rp)
	return not s.tgcon(e,tp,eg,ev,ep,re,r,rp)
end
function s.desop(e,tp,eg,ev,ep,re,r,rp)
	if Duel.Destroy(e:GetHandler(),REASON_EFFECT)>0 and Duel.GetCurrentPhase()>=PHASE_BATTLE_START 
		and Duel.GetCurrentPhase()<=PHASE_BATTLE then
		Duel.SkipPhase(Duel.GetTurnPlayer(),PHASE_BATTLE,RESET_PHASE+PHASE_BATTLE,1)
	end
end

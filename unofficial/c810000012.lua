-- Narrow Tunnel
-- scripted by: UnknownGuest
local s,id=GetID()
function s.initial_effect(c)
	-- Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	-- disable summon
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EFFECT_CANNOT_SPECIAL_SUMMON)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetTargetRange(1,1)
	e2:SetTarget(s.sumlimit)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_CANNOT_SUMMON)
	c:RegisterEffect(e3)
	local e4=e2:Clone()
	e4:SetCode(EFFECT_CANNOT_FLIP_SUMMON)
	c:RegisterEffect(e4)
	--destroy monster
	local e8=Effect.CreateEffect(c)
	e8:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e8:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e8:SetCode(EVENT_MSET)
	e8:SetRange(LOCATION_SZONE)
	e8:SetCondition(s.descon)
	e8:SetOperation(s.desop)
	c:RegisterEffect(e8)
	local e9=e8:Clone()
	e9:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e9)
	local e10=e8:Clone()
	e10:SetCode(EVENT_SUMMON_SUCCESS)
	c:RegisterEffect(e10)
	local e11=e8:Clone()
	e11:SetCode(EVENT_FLIP_SUMMON_SUCCESS)
	c:RegisterEffect(e11)
	--adjust
	local e12=Effect.CreateEffect(c)
	e12:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e12:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e12:SetCode(EVENT_ADJUST)
	e12:SetRange(LOCATION_SZONE)
	e12:SetCondition(s.descon)
	e12:SetOperation(s.desop)
	c:RegisterEffect(e12)
end
function s.sumlimit(e,c,sump,sumtype,sumpos,targetp)
	--local p=c:GetControler()
	return Duel.GetActivityCount(targetp,ACTIVITY_SUMMON)>0 or Duel.GetActivityCount(targetp,ACTIVITY_FLIPSUMMON)>0 
		or Duel.GetActivityCount(targetp,ACTIVITY_SPSUMMON)>0 or Duel.GetActivityCount(targetp,ACTIVITY_NORMALSUMMON)>0
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>=2 or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>=2
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local ft=Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0,nil)
	if ft>1 then
		local ct=ft-1
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_MZONE,0,ct,ct,nil)
		local tc=g:GetFirst()
		while tc do
			Duel.Destroy(tc,REASON_EFFECT)
			tc=g:GetNext()
		end
	end
	ft=Duel.GetFieldGroupCount(1-tp,LOCATION_MZONE,0,nil)
	if ft>1 then
		local ct=ft-1
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
		local g=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_MZONE,0,ct,ct,nil)
		local tc=g:GetFirst()
		while tc do
			Duel.Destroy(tc,REASON_EFFECT)
			tc=g:GetNext()
		end
	end
end

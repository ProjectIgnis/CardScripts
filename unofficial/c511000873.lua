--Star Excursion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	return at and a:IsType(TYPE_SYNCHRO) and at:IsType(TYPE_SYNCHRO)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	if chk==0 then return at and a:IsAbleToRemove() and at:IsAbleToRemove() end
	local g=Group.FromCards(a,at)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local a=Duel.GetAttacker()
	local at=Duel.GetAttackTarget()
	local g=Group.FromCards(a,at)
	if Duel.Remove(g,0,REASON_EFFECT+REASON_TEMPORARY)~=0 then
		local og=Duel.GetOperatedGroup()
		local oc=og:GetFirst()
		while oc do
			if oc:IsControler(tp) then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,0,4)
			else
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,0,4)
			end
			oc=og:GetNext()
		end
		if not e:IsHasType(EFFECT_TYPE_ACTIVATE) then return end
		og:KeepAlive()
		local c=e:GetHandler()
		local res
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_BATTLE)
		if Duel.GetTurnPlayer()~=tp then
			res=4
			e1:SetLabel(-1)
		else
			res=3
			e1:SetLabel(0)
		end
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,res)
		e1:SetCountLimit(1)
		e1:SetLabelObject(og)
		e1:SetCondition(s.retcon)
		e1:SetOperation(s.retop)
		Duel.RegisterEffect(e1,tp)
		local descnum=tp==c:GetOwner() and 0 or 1
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetDescription(aux.Stringid(4931121,descnum))
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(1082946)
		e2:SetLabelObject(e1)
		e2:SetOwnerPlayer(tp)
		e2:SetOperation(s.reset)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,res)
		c:RegisterEffect(e2)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return end
	s.retop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return Duel.GetTurnPlayer()~=tp end
end
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	e:GetHandler():SetTurnCounter(ct)
	if ct>=3 then
		local g=e:GetLabelObject()
		local sg=g:Filter(s.retfilter,nil)
		g:DeleteGroup()
		local tc=sg:GetFirst()
		while tc do
			Duel.ReturnToField(tc)
			tc:SetStatus(STATUS_SUMMON_TURN+STATUS_FORM_CHANGED,false)
			tc=sg:GetNext()
		end
		if re then re:Reset() end
	end
end

--スター・エクスカージョン
--Star Excursion
--rescripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_REMOVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_BE_BATTLE_TARGET)
	e1:SetCondition(s.rmcon)
	e1:SetTarget(s.rmtg)
	e1:SetOperation(s.rmop)
	c:RegisterEffect(e1)
end
function s.rmcon(e,tp,eg,ep,ev,re,r,rp)
	local at=eg:GetFirst()
	local a=at:GetBattleTarget()
	return Duel.IsBattlePhase() and Duel.GetTurnPlayer()~=tp and at and at:IsType(TYPE_SYNCHRO)
		and at:IsControler(tp) and a and a:IsType(TYPE_SYNCHRO) and a:IsControler(1-tp)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk)
	local at=eg:GetFirst()
	local a=at:GetBattleTarget()
	if chk==0 then return at and a and a:IsAbleToRemove() and at:IsAbleToRemove() end
	local g=Group.FromCards(a,at)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,2,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local at=eg:GetFirst()
	local a=at:GetBattleTarget()
	if not a or not at or not a:IsRelateToBattle() or not at:IsRelateToBattle() then return end
	local g=Group.FromCards(a,at)
	if Duel.Remove(g,0,REASON_EFFECT)~=0 then
		local og=Duel.GetOperatedGroup()
		for oc in aux.Next(og) do
			if oc:IsControler(tp) then
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,0,4)
			else
				oc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_BATTLE+RESET_SELF_TURN,0,4)
			end
		end
		og:KeepAlive()
		local c=e:GetHandler()
		local res=Duel.IsTurnPlayer(1-tp) and 4 or 3
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_PHASE+PHASE_END)
		e1:SetCountLimit(1)
		e1:SetLabel(0)
		e1:SetLabelObject(og)
		e1:SetCondition(s.tccon)
		e1:SetOperation(s.tcop)
		e1:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,res)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(aux.Stringid(id,0))
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
		e2:SetCode(1082946)
		e2:SetLabelObject(e1)
		e2:SetOwnerPlayer(tp)
		e2:SetOperation(s.reset)
		e2:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,res)
		c:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_BATTLE)
		e3:SetCountLimit(1)
		e3:SetLabelObject(e1)
		e3:SetCondition(s.retcon)
		e3:SetOperation(s.retop)
		e3:SetReset(RESET_PHASE+PHASE_BATTLE+RESET_OPPO_TURN,res)
		Duel.RegisterEffect(e3,tp)
		Duel.RegisterFlagEffect(0,e1:GetFieldID()+id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.reset(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return end
	s.tcop(e:GetLabelObject(),tp,eg,ep,ev,e,r,rp)
end
function s.retfilter(c)
	return c:GetFlagEffect(id)~=0
end
function s.tccon(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil) or e:GetLabel()==2 and Duel.GetTurnPlayer()~=tp then
		g:DeleteGroup()
		e:Reset()
		return false
	else return Duel.GetTurnPlayer()~=tp and Duel.GetFlagEffect(0,e:GetFieldID()+id)==0 end
end
function s.tcop(e,tp,eg,ep,ev,re,r,rp)
	local ct=e:GetLabel()+1
	e:SetLabel(ct)
	e:GetOwner():SetTurnCounter(ct)
end
function s.retcon(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return false end
	local g=e:GetLabelObject():GetLabelObject()
	if not g:IsExists(s.retfilter,1,nil) then
		g:DeleteGroup()
		e:Reset()
		return false
	else return Duel.GetTurnPlayer()~=tp and e:GetLabelObject():GetLabel()==2 end
end
function s.retop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetLabelObject() then e:Reset() return false end
	local g=e:GetLabelObject():GetLabelObject()
	local sg=g:Filter(s.retfilter,nil)
	for tc in aux.Next(sg) do
		local sp=tc:GetPreviousControler()
		Duel.SpecialSummonStep(tc,0,sp,sp,false,false,POS_FACEUP)
	end
	Duel.SpecialSummonComplete()
	if re then re:Reset() end
	g:DeleteGroup()
	e:Reset()
	e:GetLabelObject():Reset()
end
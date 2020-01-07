--Snare
local s,id=GetID()
function s.initial_effect(c)
	--disable attack
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(82593786,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_ATTACK_ANNOUNCE)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
	local g=Group.CreateGroup()
	g:KeepAlive()
	e1:SetLabelObject(g)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE)
	e2:SetCode(1082946)
	e2:SetLabelObject(e1)
	e2:SetCondition(s.resetcon)
	e2:SetOperation(s.resetop)
	c:RegisterEffect(e2)
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetOperation(s.endop)
	e3:SetCountLimit(1)
	e3:SetLabelObject(e2)
	Duel.RegisterEffect(e3,0)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetCard(Duel.GetAttacker())
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.NegateAttack() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetCondition(s.con)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+RESET_SELF_TURN,3)
		tc:RegisterEffect(e1)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_CANNOT_ATTACK)
		tc:RegisterEffect(e2)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e3:SetCode(id)
		e3:SetLabelObject(e)
		e3:SetLabel(0)
		e3:SetOwnerPlayer(tp)
		e3:SetValue(tc:GetControler())
		local rst=tc:IsControler(tp) and RESET_SELF_TURN or RESET_OPPO_TURN
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END+rst,3)
		tc:RegisterEffect(e3)
		e1:SetLabelObject(e3)
		e2:SetLabelObject(e3)
		e:GetLabelObject():AddCard(tc)
	end
end
function s.rfilter(c,e)
	if not c:IsLocation(LOCATION_MZONE) then return true end
	local eff={c:GetCardEffect(id)}
	for _,te in ipairs(eff) do
		if te:GetLabelObject()==e then return false end
	end
	return true
end
function s.con(e)
	local te=e:GetLabelObject()
	if not te then
		e:Reset()
		return false
	end
	return true
end
function s.resetcon(e)
	local g=e:GetLabelObject():GetLabelObject()
	local rg=g:Filter(s.rfilter,nil,e:GetLabelObject())
	g:Sub(rg)
	return #g>0
end
function s.resetop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject()
	local sg=g:Select(tp,1,1,nil)
	Duel.HintSelection(sg)
	s.rstop(sg:GetFirst(),e:GetLabelObject(),e:GetHandler(),false)
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject():GetLabelObject()
	local tc=g:GetFirst()
	while tc do
		s.rstop(tc,e:GetLabelObject():GetLabelObject(),e:GetHandler(),true)
		tc=g:GetNext()
	end
end
function s.rstop(tc,e,c,pchk)
	local eff={tc:GetCardEffect(id)}
	for _,te in ipairs(eff) do
		if te:GetLabelObject()==e and (not pchk or te:GetValue()==Duel.GetTurnPlayer()) then
			local ct=te:GetLabel()+1
			te:SetLabel(ct)
			c:SetTurnCounter(ct)
			if ct==3 then
				te:GetLabelObject():Reset()
			end
		end
	end
end

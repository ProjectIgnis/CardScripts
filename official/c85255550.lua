--異国の剣士
local s,id=GetID()
function s.initial_effect(c)
	--
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLED)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
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
	e3:SetCondition(function(e)return #e:GetLabelObject():GetLabelObject():GetLabelObject()>0 end)
	e3:SetOperation(s.endop)
	e3:SetCountLimit(1)
	e3:SetLabelObject(e2)
	Duel.RegisterEffect(e3,0)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	return c==Duel.GetAttacker() and bc and bc:IsRelateToBattle() and bc:IsFaceup()
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local bc=c:GetBattleTarget()
	if bc and bc:IsRelateToBattle() then
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(id)
		e1:SetLabelObject(e)
		e1:SetLabel(0)
		e1:SetOwnerPlayer(tp)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		bc:RegisterEffect(e1)
		e:GetLabelObject():AddCard(bc)
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
	s.desop(sg:GetFirst(),e:GetLabelObject(),e:GetHandler())
end
function s.endop(e,tp,eg,ep,ev,re,r,rp)
	local g=e:GetLabelObject():GetLabelObject():GetLabelObject()
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		s.desop(tc,e:GetLabelObject():GetLabelObject(),e:GetHandler())
	end
end
function s.desop(tc,e,c)
	local eff={tc:GetCardEffect(id)}
	for _,te in ipairs(eff) do
		if te:GetLabelObject()==e then
			local ct=te:GetLabel()+1
			te:SetLabel(ct)
			c:SetTurnCounter(ct)
			if ct==5 and Duel.Destroy(tc,REASON_EFFECT)>0 then
				--to be added if andre's PRs are merged
				--tc:SetReasonPlayer(te:GetOwnerPlayer())
				--tc:SetReasonEffect(te)
			end
		end
	end
end

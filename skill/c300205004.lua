--Twisted Personality
local s,id=GetID()
function s.initial_effect(c)
	aux.AddSkillProcedure(c,2,false,nil,nil)
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE+EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_STARTUP)
	e1:SetCountLimit(1)
	e1:SetRange(0x5f)
	e1:SetLabel(0)
	e1:SetOperation(s.flipop)
	c:RegisterEffect(e1)
end
function s.flipop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SKILL_FLIP,tp,id|(1<<32))
	Duel.Hint(HINT_CARD,tp,id)
	--opd register
	Duel.RegisterFlagEffect(ep,id,0,0,0)
	
	local c=e:GetHandler()
	
	if Duel.GetFlagEffect(tp,id+1)==0 then
		--add counter
		local lp1=Duel.GetLP(c:GetControler())
		local lp2=Duel.GetLP(1-c:GetControler())
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_ADJUST)
		e1:SetLabel(lp1)
		e1:SetLabelObject(e)
		e1:SetCondition(s.lpcon1)
		e1:SetOperation(s.lpop1)
		Duel.RegisterEffect(e1,tp)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_ADJUST)
		e2:SetLabel(lp2)
		e2:SetLabelObject(e)
		e2:SetCondition(s.lpcon2)
		e2:SetOperation(s.lpop2)
		Duel.RegisterEffect(e2,tp)
		--discard/Destruction
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_FREE_CHAIN)
		e3:SetCountLimit(1)
		e3:SetLabelObject(e)
		e3:SetCondition(s.con)
		e3:SetOperation(s.op)
		Duel.RegisterEffect(e3,tp)
	end
	Duel.RegisterFlagEffect(ep,id+1,0,0,0)
	
end
--Lose lp check
function s.lpcon1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	return (Duel.GetLP(p)~=e:GetLabel() and not Duel.IsExistingTarget(Card.IsFaceup,tp,LOCATION_MZONE,0,1,nil)) or Duel.GetLP(p)>e:GetLabel()
end
function s.lpcon2(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	return (Duel.GetLP(1-p)~=e:GetLabel() and not Duel.IsExistingTarget(Card.IsFaceup,tp,0,LOCATION_MZONE,1,nil)) or Duel.GetLP(1-p)>e:GetLabel()
end
function s.lpop1(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	e:SetLabel(Duel.GetLP(p))
	if e:GetLabelObject():GetLabel()<3 then
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
		Debug.Message(e:GetLabelObject():GetLabel() .. " counter(s) on the Skill")
	end
end
function s.lpop2(e,tp,eg,ep,ev,re,r,rp)
	local p=e:GetHandler():GetControler()
	e:SetLabel(Duel.GetLP(1-p))
	if e:GetLabelObject():GetLabel()<3 then
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()+1)
		Debug.Message(e:GetLabelObject():GetLabel() .. " counter(s) on the Skill")
	end
end
--
function s.con(e,tp,eg,ep,ev,re,r,rp)
	--
	local g1=Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
	--fusion
	local g2=Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0
	return Duel.IsMainPhase() and Duel.GetTurnPlayer()==tp and ((e:GetLabelObject():GetLabel()>1 and  g1) or (e:GetLabelObject():GetLabel()>2 and g2))
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	--discard
	local g1=e:GetLabelObject():GetLabel()>1 and Duel.GetFieldGroupCount(1-tp,LOCATION_HAND,0)>0
	--destruction
	local g2=e:GetLabelObject():GetLabel()>2 and Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD)>0

	local opt=0
	if g1 and g2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif g1 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,1))
	elseif g2 then
		opt=Duel.SelectOption(tp,aux.Stringid(id,2))+1
	else return end
	if opt==0 then
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()-2)
		Debug.Message(e:GetLabelObject():GetLabel() .. " counter(s) on the Skill")
		local g=Duel.GetFieldGroup(1-tp,LOCATION_HAND,0)
		if #g==0 then return end
		local sg=g:RandomSelect(1-tp,1)
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
	else 
		e:GetLabelObject():SetLabel(e:GetLabelObject():GetLabel()-3)
		Debug.Message(e:GetLabelObject():GetLabel() .. " counter(s) on the Skill")
		local g=Duel.GetFieldGroup(tp,0,LOCATION_ONFIELD)
		if #g==0 then return end
		local sg=g:Select(tp,1,1,nil)
		Duel.HintSelection(sg)
		Duel.Destroy(sg,REASON_EFFECT)
	end
end

--アルティメット・フルバースト
--Ultimate Full Burst
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x95}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase()
end
function s.cfilter(c,tp)
	local re=c:GetReasonEffect()
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ) and c:IsXyzSummoned()
		and re and re:GetHandler():IsSetCard(SET_RANK_UP_MAGIC) and re:IsActiveType(TYPE_SPELL)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.cfilter,nil,tp)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return g:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET) 
	local tc=g:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	Duel.SetTargetCard(tc)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(51103038,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		if Duel.GetCurrentChain()==1 then
			local e1=Effect.CreateEffect(e:GetHandler())
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTarget(s.tg)
			e1:SetOperation(s.op)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_CHAIN)
			tc:RegisterEffect(e1,true)
		end
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.descon)
		e2:SetOperation(s.desop)
		Duel.RegisterEffect(e2,tp)
	end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	if chkc then
		if not c:IsHasEffect(id) then return false end
		local tgeffs={c:GetCardEffect(id)}
		for _,tge in ipairs(tgeffs) do
			if tge:GetLabel()==ev then return tge:GetLabelObject():GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		end
		return false
	end
	if chk==0 then
		if not c:IsHasEffect(511002571) then return false end
		local effs={c:GetCardEffect(511002571)}
		for _,teh in ipairs(effs) do
			local temp=teh:GetLabelObject()
			if temp:GetCode()&511001822==511001822 or temp:GetLabel()==511001822 then temp=temp:GetLabelObject() end
			e:SetCategory(temp:GetCategory())
			e:SetProperty(temp:GetProperty())
			local con=temp:GetCondition()
			local cost=temp:GetCost()
			local tg=temp:GetTarget()
			if (not con or con(e,tp,eg,ep,ev,re,r,rp))
				and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
				and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)) then
				return true
			end
		end
		return false
	end
	local effs={c:GetCardEffect(511002571)}
	local acd={}
	local ac={}
	for _,teh in ipairs(effs) do
		local temp=teh:GetLabelObject()
		if temp:GetCode()&511001822==511001822 or temp:GetLabel()==511001822 then temp=temp:GetLabelObject() end
		e:SetCategory(temp:GetCategory())
		e:SetProperty(temp:GetProperty())
		local con=temp:GetCondition()
		local cost=temp:GetCost()
		local tg=temp:GetTarget()
		if (not con or con(e,tp,eg,ep,ev,re,r,rp))
			and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
			and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)) then
			table.insert(ac,teh)
			table.insert(acd,temp:GetDescription())
		end
	end
	local te=nil
	if #ac==1 then te=ac[1] elseif #ac>1 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
		local op=Duel.SelectOption(tp,table.unpack(acd))+1
		te=ac[op]
	end
	local teh=te
	te=teh:GetLabelObject()
	if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local cost=te:GetCost()
	if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1,chkc) end
	te:UseCountLimit(tp)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(id)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetLabel(Duel.GetCurrentChain())
	e1:SetLabelObject(te)
	e1:SetReset(RESET_CHAIN)
	c:RegisterEffect(e1)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsHasEffect(id) then
		local tgeffs={c:GetCardEffect(id)}
		for _,tge in ipairs(tgeffs) do
			if tge:GetLabel()==Duel.GetCurrentChain() then
				local te=tge:GetLabelObject()
				local operation=te:GetOperation()
				if operation then operation(e,tp,eg,ep,ev,re,r,rp) end
			end
		end
	end
	if c:IsFaceup() and c:IsRelateToEffect(e) then
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetOwner())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(e:GetOwner())
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ATTACK_ALL)
		e2:SetValue(1)
		e2:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		c:RegisterEffect(e2)
	end
	e:Reset()
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if tc:GetFlagEffectLabel(51103038)==e:GetLabel() then
		return true
	else
		e:Reset()
		return false
	end
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	Duel.Destroy(tc,REASON_EFFECT)
end
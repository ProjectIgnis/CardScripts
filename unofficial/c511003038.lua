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
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetCurrentPhase()>=PHASE_BATTLE_START and Duel.GetCurrentPhase()<=PHASE_BATTLE 
		and re and re:GetHandler():IsSetCard(0x95)
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ) and c:IsSummonType(SUMMON_TYPE_XYZ)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.cfilter,nil,tp)
	local tc=g:GetFirst()
	if chkc then return g:IsContains(chkc) end
	if chk==0 then
		if not tc or not tc:IsHasEffect(511002571) or #g~=1 or not tc:IsCanBeEffectTarget(e) then return false end
		local eff={tc:GetCardEffect(511002571)}
		for _,teh in ipairs(eff) do
			local te=teh:GetLabelObject()
			local tg=te:GetTarget()
			if not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0) then return true end
		end
		return false
	end
	Duel.SetTargetCard(g)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local eff={tc:GetCardEffect(511002571)}
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(eff) do
			local temp=teh:GetLabelObject()
			local tg=temp:GetTarget()
			if not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0) then
				table.insert(ac,teh)
				table.insert(acd,temp:GetDescription())
			end
		end
		if #ac==1 then te=ac[1] elseif #ac>1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
			op=Duel.SelectOption(tp,table.unpack(acd))
			op=op+1
			te=ac[op]
		end
		if not te then return end
		local teh=te
		te=teh:GetLabelObject()
		local tg=te:GetTarget()
		local op=te:GetOperation()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		if g then
			local etc=g:GetFirst()
			while etc do
				etc:CreateEffectRelation(te)
				etc=g:GetNext()
			end
		end
		if op then op(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		if etc then	
			etc=g:GetFirst()
			while etc do
				etc:ReleaseEffectRelation(te)
				etc=g:GetNext()
			end
		end
		Duel.BreakEffect()
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_MUST_ATTACK)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1)
		local e3=Effect.CreateEffect(e:GetHandler())
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetCode(EFFECT_ATTACK_ALL)
		e3:SetValue(1)
		e3:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e3)
		local fid=e:GetHandler():GetFieldID()
		tc:RegisterFlagEffect(51103038,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e2=Effect.CreateEffect(e:GetHandler())
		e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e2:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e2:SetCode(EVENT_PHASE+PHASE_END)
		e2:SetCountLimit(1)
		e2:SetLabel(fid)
		e2:SetLabelObject(tc)
		e2:SetCondition(s.descon)
		e2:SetOperation(s.desop)
		Duel.RegisterEffect(e2,tp)
	end
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

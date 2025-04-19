--ＲＲ－ラピッド・エクシーズ
--Raidraptor - Rapid Xyz
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_BATTLE_START+TIMING_BATTLE_END)
	e1:SetCondition(s.xyzcon)
	e1:SetTarget(s.xyztg)
	e1:SetOperation(s.xyzop)
	c:RegisterEffect(e1)
end
s.listed_series={0xba}
function s.cfilter(c)
	return c:IsSpecialSummoned()
end
function s.xyzcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsBattlePhase() and Duel.IsExistingMatchingCard(s.cfilter,tp,0,LOCATION_MZONE,1,nil)
end
function s.xyzfilter(c)
	return c:IsXyzSummonable() and c:IsSetCard(SET_RAIDRAPTOR)
end
function s.xyztg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_EXTRA,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_EXTRA)
end
function s.xyzop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_EXTRA,0,1,1,nil):GetFirst()
	if tc then
		local e1=Effect.CreateEffect(e:GetHandler())
		e1:SetType(EFFECT_TYPE_QUICK_O)
		e1:SetCode(EVENT_FREE_CHAIN)
		e1:SetRange(LOCATION_MZONE)
		e1:SetTarget(s.tg)
		e1:SetOperation(s.op)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD&~RESET_TOFIELD+RESET_PHASE+PHASE_END)
		tc:RegisterEffect(e1,true)
		Duel.XyzSummon(tp,tc)
	end
end
function s.tg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	e:SetCategory(0)
	e:SetProperty(0)
	if chkc then
		if not c:IsHasEffect(id) then return false end
		local tgeffs={c:GetCardEffect(id)}
		for _,tge in ipairs(tgeffs) do
			if tge:GetLabel()==ev then return tge:GetLabelObject():GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		end
		return false
	end
	if chk==0 then
		if not c:IsHasEffect(511002571) or not Duel.IsBattlePhase() then return false end
		local effs={c:GetCardEffect(511002571)}
		for _,teh in ipairs(effs) do
			local temp=teh:GetLabelObject()
			if temp:GetCode()&511001822==511001822 or temp:GetLabel()==511001822 then temp=temp:GetLabelObject() end
			if temp:IsHasType(EFFECT_TYPE_IGNITION) then
				e:SetCategory(temp:GetCategory())
				e:SetProperty(temp:GetProperty())
				local con=temp:GetCondition()
				local cost=temp:GetCost()
				local tg=temp:GetTarget()
				if (not con or co(e,tp,eg,ep,ev,re,r,rp))
					and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
					and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0,chkc)) then
					return true
				end
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
		if temp:IsHasType(EFFECT_TYPE_IGNITION) then
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
				e:SetCategory(te:GetCategory())
				e:SetProperty(te:GetProperty())
				local operation=te:GetOperation()
				if operation then operation(e,tp,eg,ep,ev,re,r,rp) end
			end
		end
	end
end
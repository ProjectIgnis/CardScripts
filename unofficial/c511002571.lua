--オーバー・タキオン・ユニット
--Tachyon Unit
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,500) end
	Duel.PayLPCost(tp,500)
end
function s.filter(c,e,tp)
	if c:IsFacedown() or not c:IsTachyon() or not c:IsHasEffect(id) then return false end
	local eff={c:GetCardEffect(id)}
	for _,teh in ipairs(eff) do
		local te=teh:GetLabelObject()
		if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
		local con=te:GetCondition()
		local tg=te:GetTarget()
		if (not con or con(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE))
			and (not tg or tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then return true
		end
	end
	return false
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.filter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.filter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	Duel.SelectTarget(tp,s.filter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		local eff={tc:GetCardEffect(id)}
		local te=nil
		local acd={}
		local ac={}
		for _,teh in ipairs(eff) do
			local temp=teh:GetLabelObject()
			if temp:GetCode()&511001822==511001822 or temp:GetLabel()==511001822 then temp=temp:GetLabelObject() end
			local con=temp:GetCondition()
			local tg=temp:GetTarget()
			if (not con or con(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE))
				and (not tg or tg(temp,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,0)) then
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
		if te:GetCode()&511001822==511001822 or te:GetLabel()==511001822 then te=te:GetLabelObject() end
		local tg=te:GetTarget()
		if tg then tg(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		Duel.BreakEffect()
		tc:CreateEffectRelation(te)
		Duel.BreakEffect()
		local g=Duel.GetChainInfo(0,CHAININFO_TARGET_CARDS)
		for etc in aux.Next(g) do
			etc:CreateEffectRelation(te)
		end
		local operation=te:GetOperation()
		if operation then operation(te,tp,Group.CreateGroup(),PLAYER_NONE,0,teh,REASON_EFFECT,PLAYER_NONE,1) end
		tc:ReleaseEffectRelation(te)
		for etc in aux.Next(g) do
			etc:ReleaseEffectRelation(te)
		end
	end
end
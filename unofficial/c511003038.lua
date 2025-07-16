--アルティメット・フルバースト
--Ultimate Full Burst
local s,id=GetID()
function s.initial_effect(c)
	--Activate an Xyz monster's effect that is activated by detaching its own Xyz Material(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_DELAY)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function() return Duel.IsBattlePhase() end)
	e1:SetTarget(s.acttg)
	e1:SetOperation(s.actop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_RANK_UP_MAGIC}
function s.actfilter(c,tp)
	local re=c:GetReasonEffect()
	return c:IsFaceup() and c:IsSummonPlayer(tp) and c:IsType(TYPE_XYZ) and c:IsXyzSummoned()
		and re and re:GetHandler():IsSetCard(SET_RANK_UP_MAGIC) and re:IsSpellEffect()
end
function s.acttg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local g=eg:Filter(s.actfilter,nil,tp)
	if chkc then return g:IsContains(chkc) end
	if chk==0 then return g:IsExists(Card.IsCanBeEffectTarget,1,nil,e) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tc=g:FilterSelect(tp,Card.IsCanBeEffectTarget,1,1,nil,e)
	Duel.SetTargetCard(tc)
end
function s.actop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc:IsFaceup() and tc:IsRelateToEffect(e) then
		local c=e:GetHandler()
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD,0,1,fid)
		if Duel.GetCurrentChain()==1 then
			--Activate that monster's effect immediately after this effect resolves
			local e1=Effect.CreateEffect(c)
			e1:SetDescription(aux.Stringid(id,1))
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetRange(LOCATION_MZONE)
			e1:SetTarget(s.efftg)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
			tc:RegisterEffect(e1,true)
		end
		--During the End Phase, destroy that monster
		aux.DelayedOperation(tc,PHASE_END,id,e,tp,function(ag) Duel.Destroy(ag,REASON_EFFECT) end,nil,0,0,aux.Stringid(id,2))
	end
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local c=e:GetHandler()
	local effs={}
	for _,eff in ipairs({c:GetOwnEffects(id)}) do
		if eff:HasDetachCost() then table.insert(effs,eff) end
	end
	if chkc then
		for _,eff in ipairs(effs) do
			if eff:GetFieldID()==e:GetLabel() then return eff:GetTarget()(e,tp,eg,ep,ev,re,r,rp,chk,chkc) end
		end
		return false
	end
	local options={}
	local has_option=false
	for _,eff in ipairs(effs) do
		e:SetCategory(eff:GetCategory())
		e:SetProperty(eff:GetProperty())
		local con=eff:GetCondition()
		local cost=eff:GetCost()
		local tg=eff:GetTarget()
		local eff_chk=(not con or con(e,tp,eg,ep,ev,re,r,rp))
			and (not cost or cost(e,tp,eg,ep,ev,re,r,rp,0))
			and (not tg or tg(e,tp,eg,ep,ev,re,r,rp,0))
		if eff_chk then has_option=true end
		table.insert(options,{eff_chk,eff:GetDescription()})
	end
	e:SetCategory(0)
	e:SetProperty(0)
	if chk==0 then return has_option end
	local op=#options==1 and 1 or Duel.SelectEffect(tp,table.unpack(options))
	if not op then return end
	local te=effs[op]
	if not te then return end
	e:SetLabel(te:GetFieldID())
	e:SetCategory(te:GetCategory())
	e:SetProperty(te:GetProperty())
	local cost=te:GetCost()
	if cost then cost(e,tp,eg,ep,ev,re,r,rp,1) end
	local tg=te:GetTarget()
	if tg then tg(e,tp,eg,ep,ev,re,r,rp,1) end
	te:UseCountLimit(tp)
	e:SetOperation(s.effop(te:GetOperation()))
end
function s.effop(fn)
	return function(e,...)
		fn(e,...)
		local c=e:GetHandler()
		if c:IsFaceup() and c:IsRelateToEffect(e) then
			Duel.BreakEffect()
			--That monster must attack all monsters your opponent controls, once each, during each Battle Phase this turn
			local e1=Effect.CreateEffect(e:GetOwner())
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_MUST_ATTACK)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			c:RegisterEffect(e1)
			local e2=e1:Clone()
			e2:SetCode(EFFECT_ATTACK_ALL)
			e2:SetValue(1)
			c:RegisterEffect(e2)
		end
		e:Reset()
	end
end
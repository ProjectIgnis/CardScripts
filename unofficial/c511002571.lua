--オーバー・タキオン・ユニット
--Tachyon Unit
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 "Tachyon" monster's effect that is activated by detaching its own Xyz Material(s)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMING_END_PHASE)
	e1:SetCost(Cost.PayLP(500))
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
function s.runfn(fn,eff,re,tp,chk)
	return not fn or fn(eff,tp,Group.CreateGroup(),PLAYER_NONE,0,re,REASON_EFFECT,PLAYER_NONE,chk)
end
function s.efffilter(c,e,tp)
	if c:IsFacedown() or not c:IsTachyon() then return false end
	for _,eff in ipairs({c:GetOwnEffects()}) do
		if eff:HasDetachCost() and s.runfn(eff:GetCondition(),eff,e,tp) and s.runfn(eff:GetTarget(),eff,e,tp,0) then return true end
	end
	return false
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsControler(tp) and s.efffilter(chkc,e,tp) end
	if chk==0 then return Duel.IsExistingTarget(s.efffilter,tp,LOCATION_MZONE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_EFFECT)
	Duel.SelectTarget(tp,s.efffilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) then return end
	local effs={}
	local options={}
	for _,eff in ipairs({tc:GetOwnEffects()}) do
		if eff:HasDetachCost() then
			table.insert(effs,eff)
			local eff_chk=s.runfn(eff:GetCondition(),eff,e,tp) and s.runfn(eff:GetTarget(),eff,e,tp,0)
			table.insert(options,{eff_chk,eff:GetDescription()})
		end
	end
	local op=#options==1 and 1 or Duel.SelectEffect(tp,table.unpack(options))
	if not op then return end
	local te=effs[op]
	if not te then return end
	Duel.ClearTargetCard()
	s.runfn(te:GetTarget(),te,e,tp,1)
	Duel.BreakEffect()
	tc:CreateEffectRelation(te)
	Duel.BreakEffect()
	local tg=Duel.GetTargetCards(te)
	tg:ForEach(Card.CreateEffectRelation,te)
	s.runfn(te:GetOperation(),te,e,tp,1)
	tg:ForEach(Card.ReleaseEffectRelation,te)
end

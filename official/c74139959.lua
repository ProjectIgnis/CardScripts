--星界樹イルミスティル
--Cosmic Tree Irmistil
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Link Summon procedure
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_EFFECT),3)
	--You can only control 1 "Astral World Tree Illumistil"
	c:SetUniqueOnField(1,0,id)
	--Gain LP equal to the ATK of a monster(s) Special Summoned by your opponent
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(function(e,tp,eg) return Duel.IsMainPhase() and eg:IsExists(aux.FaceupFilter(Card.IsSummonPlayer,1-tp),1,nil) end)
	e1:SetOperation(s.lpgainop)
	c:RegisterEffect(e1)
	--Make this card gain ATK based on how much LP you pay
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_ATKCHANGE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetCondition(function() return not (Duel.IsPhase(PHASE_DAMAGE) and Duel.IsDamageCalculated()) end)
	e2:SetCost(s.atkcost)
	e2:SetOperation(s.atkop)
	c:RegisterEffect(e2)
end
s.listed_names={id}
function s.lpgainop(e,tp,eg,ep,ev,re,r,rp)
	local val=eg:Filter(aux.FaceupFilter(Card.IsSummonPlayer,1-tp),nil):GetSum(Card.GetAttack)
	if not Duel.IsChainSolving() then
		if val>0 then
			Duel.Hint(HINT_CARD,1-tp,id)
			Duel.Recover(tp,val,REASON_EFFECT)
		end
	else
		local eff=e:GetLabelObject()
		if eff and not eff:IsDeleted() then
			eff:SetLabel(eff:GetLabel()+val)
		else
			local c=e:GetHandler()
			--Gain LP equal to the ATK of a monster(s) Special Summoned by your opponent at the end of the Chain Link
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e1:SetCode(EVENT_CHAIN_SOLVED)
			e1:SetRange(LOCATION_MZONE)
			e1:SetOperation(s.chainsolvedop)
			e1:SetLabel(val)
			e1:SetLabelObject(e)
			e1:SetReset(RESET_EVENT|RESETS_STANDARD|RESET_CHAIN)
			c:RegisterEffect(e1)
			e:SetLabelObject(e1)
			--Reset the label object of "e" in the case that "e1" isn't executed
			local e2=Effect.CreateEffect(c)
			e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
			e2:SetCode(EVENT_CHAIN_SOLVED)
			e2:SetOperation(function() e:SetLabelObject(nil) end)
			e2:SetReset(RESET_CHAIN)
			Duel.RegisterEffect(e2,tp)
		end
	end
end
function s.chainsolvedop(e,tp,eg,ep,ev,re,r,rp)
	local val=e:GetLabel()
	if val>0 then
		Duel.Hint(HINT_CARD,1-tp,id)
		Duel.Recover(tp,val,REASON_EFFECT)
	end
	e:Reset()
	e:GetLabelObject():SetLabelObject(nil)
end
function s.atkcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.CheckLPCost(tp,1000) end
	local cost_options={}
	for i=1,math.floor(math.min(Duel.GetLP(tp),3000)/1000) do
		cost_options[i]=i*1000
	end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local lp_cost=Duel.AnnounceNumber(tp,cost_options)
	e:SetLabel(lp_cost)
	Duel.PayLPCost(tp,lp_cost)
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) and c:IsFaceup() then
		--Gains ATK equal to the amount of LP you paid
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_UPDATE_ATTACK)
		e1:SetValue(e:GetLabel())
		e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE)
		c:RegisterEffect(e1)
	end
end
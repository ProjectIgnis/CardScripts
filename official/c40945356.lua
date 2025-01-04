--黄昏の中忍－ニチリン
--Twilight Ninja Nichirin, the Chunin
local s,id=GetID()
function s.initial_effect(c)
	--Activate 1 of these effects
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetHintTiming(TIMING_DAMAGE_STEP,TIMING_DAMAGE_STEP|TIMINGS_CHECK_MONSTER)
	e1:SetCost(s.effcost)
	e1:SetTarget(s.efftg)
	e1:SetOperation(s.effop)
	c:RegisterEffect(e1)
end
s.listed_series={SET_NINJA,SET_NINJITSU_ART}
function s.cfilter(c)
	return c:IsSetCard(SET_NINJA) and c:IsMonster() and c:IsDiscardable()
end
function s.effcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_HAND,0,1,nil) end
	Duel.DiscardHand(tp,s.cfilter,1,1,REASON_COST|REASON_DISCARD)
end
function s.efftg(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=not (Duel.HasFlagEffect(tp,id) or Duel.IsPhase(PHASE_DAMAGE))
	local b2=not (Duel.IsPhase(PHASE_DAMAGE) and Duel.IsDamageCalculated())
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsSetCard,SET_NINJA),tp,LOCATION_MZONE,0,1,nil)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	e:SetCategory(op==1 and 0 or CATEGORY_ATKCHANGE)
end
function s.effop(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	local c=e:GetHandler()
	if op==1 then
		--This turn, "Ninja" monsters and "Ninjitsu Art" cards you control cannot be destroyed by battle or card effects
		if Duel.HasFlagEffect(tp,id) then return end
		Duel.RegisterFlagEffect(tp,id,RESET_PHASE|PHASE_END,0,1)
		--"Ninja" monsters and "Ninjitsu Art" cards cannot be destroyed by battle or card effects
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_FIELD)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetTargetRange(LOCATION_MZONE,0)
		e1:SetTarget(function(e,c) return c:IsSetCard(SET_NINJITSU_ART) or (c:IsSetCard(SET_NINJA) and c:IsMonster()) end)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE|PHASE_END)
		Duel.RegisterEffect(e1,tp)
		local e2=e1:Clone()
		e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
		e2:SetTargetRange(LOCATION_ONFIELD,0)
		Duel.RegisterEffect(e2,tp)
		aux.RegisterClientHint(c,0,tp,1,0,aux.Stringid(id,3))
	elseif op==2 then
		--1 "Ninja" monster you control gains 1000 ATK until the end of this turn
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local tc=Duel.SelectMatchingCard(tp,aux.FaceupFilter(Card.IsSetCard,SET_NINJA),tp,LOCATION_MZONE,0,1,1,nil):GetFirst()
		if tc then
			Duel.HintSelection(tc,true)
			--Gains 1000 ATK
			local e3=Effect.CreateEffect(c)
			e3:SetType(EFFECT_TYPE_SINGLE)
			e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e3:SetCode(EFFECT_UPDATE_ATTACK)
			e3:SetValue(1000)
			e3:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e3)
		end
	end
end
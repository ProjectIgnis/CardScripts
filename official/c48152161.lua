--神属の堕天使
--The Sanctified Darklord
local s,id=GetID()
function s.initial_effect(c)
	--Negate the effects of 1 Effect Monster on the field until the end of this turn, and if you do, gain LP equal to its ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE+CATEGORY_RECOVER)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_DARKLORD}
function s.costfilter(c)
	return c:IsSetCard(SET_DARKLORD) and c:IsMonster() and (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.disfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c)
end
function s.disfilter(c)
	return c:IsNegatableMonster() and c:IsType(TYPE_EFFECT)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g=Duel.SelectMatchingCard(tp,s.costfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,1,nil)
	Duel.SendtoGrave(g,REASON_COST)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_NEGATE)
	local sc=Duel.SelectMatchingCard(tp,s.disfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil):GetFirst()
	if not sc then return end
	Duel.HintSelection(sc)
	if sc:IsCanBeDisabledByEffect(e) then
		--Negate its effects until the end of the turn
		sc:NegateEffects(e:GetHandler(),RESETS_STANDARD_PHASE_END)
		Duel.AdjustInstantly(sc)
		local atk=sc:GetAttack()
		if atk>0 then
			Duel.Recover(tp,atk,REASON_EFFECT)
		end
	end
end
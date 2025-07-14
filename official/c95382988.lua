--再世十戒
--Regenesis Commands
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--Apply effects to all cards your opponent controls in the same column as your "Regenesis" monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DISABLE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetHintTiming(0,TIMING_STANDBY_PHASE|TIMING_MAIN_END|TIMINGS_CHECK_MONSTER_E)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={SET_REGENESIS}
function s.oppfilter(c,tp)
	return (c:IsNegatable() or c:IsFacedown()) and c:GetColumnGroup():IsExists(s.regenesisfilter,1,nil,tp)
end
function s.regenesisfilter(c,tp)
	return c:IsSetCard(SET_REGENESIS) and c:IsMonster() and c:IsFaceup() and c:IsControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.oppfilter,tp,0,LOCATION_ONFIELD,1,nil,tp) end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE,nil,1,1-tp,LOCATION_ONFIELD)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.oppfilter,tp,0,LOCATION_ONFIELD,nil,tp)
	if #g==0 then return end
	local c=e:GetHandler()
	local faceup_g,facedown_g=g:Split(Card.IsFaceup,nil)
	for neg_c in faceup_g:Iter() do
		--Negate their effects
		neg_c:NegateEffects(c,nil,true)
	end
	if #facedown_g==0 then return end
	local facedown_mons,facedown_st=facedown_g:Split(Card.IsMonster,nil)
	for pos_c in facedown_mons:Iter() do
		--Cannot change their battle positions
		local e1=Effect.CreateEffect(c)
		e1:SetDescription(3313)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e1:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		pos_c:RegisterEffect(e1)
	end
	for act_c in facedown_st:Iter() do
		--Cannot be activated until the end of the next turn
		local e2=Effect.CreateEffect(c)
		e2:SetDescription(3302)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_CANNOT_TRIGGER)
		e2:SetReset(RESETS_STANDARD_PHASE_END,2)
		act_c:RegisterEffect(e2)
	end
end
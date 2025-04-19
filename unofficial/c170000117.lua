--時間融合－タイム・フュージョン
--Time Fusion
--Re-scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,e:GetHandler()) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectMatchingCard(tp,Card.IsAbleToRemoveAsCost,tp,LOCATION_HAND,0,1,1,e:GetHandler())
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.spfilter(c,tp)
	return c:IsType(TYPE_FUSION) and c:IsFaceup()
		and c:IsReason(REASON_DESTROY) and c:GetTurnID()==Duel.GetTurnCount()
		and c:IsPreviousLocation(LOCATION_MZONE) and c:IsPreviousControler(tp)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,0x70,0x70,1,nil,tp) end
	Duel.SetPossibleOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0x70)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,s.spfilter,tp,0x70,0x70,1,1,nil,tp):GetFirst()
	if not tc then return end
	Duel.HintSelection(tc,true)
	local ct=Duel.GetCurrentPhase()==PHASE_STANDBY and 2 or 1
	local tid=Duel.GetTurnCount()
	aux.DelayedOperation(tc,PHASE_STANDBY,id,e,tp,
		function(ag)
			local sc=ag:GetFirst()
			if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and Duel.SpecialSummonStep(sc,0,tp,tp,true,false,POS_FACEUP) then
				local e1=Effect.CreateEffect(e:GetHandler())
				e1:SetDescription(3206)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_CANNOT_ATTACK)
				e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
				e1:SetReset(RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END)
				sc:RegisterEffect(e1,true)
			end
			Duel.SpecialSummonComplete()
		end,
		function()
			return Duel.IsTurnPlayer(tp) and (ct==1 or Duel.GetTurnCount()~=tid)
		end,
		RESET_PHASE|PHASE_STANDBY|RESET_SELF_TURN,ct)
end
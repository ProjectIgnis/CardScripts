--ヘルシィ・ティガサティー
--Healthie Tigasati
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Ritual
	c:EnableReviveLimit()
	--change position
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsPlayerCanDiscardDeckAsCost(tp,1) end
end
function s.filter(c)
	return c:IsFaceup() and c:IsRace(RACE_PYRO) and c:IsType(TYPE_EFFECT) and c:IsLevelAbove(7) and c:IsCanTurnSet() and c:IsCanChangePositionRush()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_POSITION,nil,1,0,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	if Duel.DiscardDeck(tp,1,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_POSCHANGE)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,LOCATION_MZONE,0,1,2,nil)
	if #g>0 then
		Duel.HintSelection(g)
		Duel.ChangePosition(g,POS_FACEDOWN_DEFENSE,0,POS_FACEDOWN_DEFENSE,0)
		Duel.ChangePosition(g,POS_FACEUP_ATTACK)
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
			e1:SetRange(LOCATION_MZONE)
			e1:SetValue(400)
			e1:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e1)
			--Cannot activate its effects
			local e2=Effect.CreateEffect(c)
			e2:SetDescription(3302)
			e2:SetProperty(EFFECT_FLAG_CLIENT_HINT)
			e2:SetType(EFFECT_TYPE_SINGLE)
			e2:SetCode(EFFECT_CANNOT_TRIGGER)
			e2:SetReset(RESETS_STANDARD_PHASE_END)
			tc:RegisterEffect(e2)
		end
	end
end
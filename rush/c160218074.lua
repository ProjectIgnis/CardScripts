--幻惑の光
--Light of Bewitchment
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Change the attribute for up to 3 of opponent's monsters
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
	aux.GlobalCheck(s,function()
		local ge1=Effect.CreateEffect(c)
		ge1:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		ge1:SetCode(EVENT_CHAIN_SOLVED)
		ge1:SetOperation(s.checkop)
		Duel.RegisterEffect(ge1,0)
	end)
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	if re:GetHandler():IsCode(160218074) then
		Duel.RegisterFlagEffect(rp,id,RESET_PHASE|PHASE_END,0,1)
	end
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFlagEffect(tp,id)==0
end
function s.cfilter(c,tp)
	return c:IsFaceup() and c:IsRace(RACE_SPELLCASTER)
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,0,LOCATION_MZONE,1,nil,c:GetAttribute())
end
function s.cfilter2(c,attr)
	return c:IsFaceup() and not c:IsAttribute(attr)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_MZONE,0,1,nil,tp) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	local g=Duel.GetMatchingGroup(s.cfilter,tp,LOCATION_MZONE,0,nil,tp)
	local available_attributes=g:GetBitwiseOr(function(c) return c:GetAttribute() end)
	local attr=Duel.AnnounceAttribute(tp,1,available_attributes)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_FACEUP)
	local g=Duel.SelectMatchingCard(tp,s.cfilter2,tp,0,LOCATION_MZONE,1,1,nil,attr)
	Duel.HintSelection(g)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_CHANGE_ATTRIBUTE)
	e1:SetValue(attr)
	e1:SetReset(RESETS_STANDARD_PHASE_END)
	g:GetFirst():RegisterEffect(e1)
	if c:IsSSetable(true) and e:IsHasType(EFFECT_TYPE_ACTIVATE) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.BreakEffect()
		c:CancelToGrave()
		Duel.ChangePosition(c,POS_FACEDOWN)
		Duel.RaiseEvent(c,EVENT_SSET,e,REASON_EFFECT,tp,tp,0)
	end
end

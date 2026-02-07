--ヴォイドアルヴ・スターメイフライ
--Voidalfr Star Mayfly
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Fusion Summon procedure
	c:EnableReviveLimit()
	Fusion.AddProcMix(c,true,true,160024006,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER))
	--Return up to 3 cards on the field to the hand
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOHAND)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonPhaseMain() and c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.tdfilter(c)
	return c:IsMonster() and c:IsRace(RACE_GALAXY) and c:IsAbleToDeckOrExtraAsCost()
end
function s.rescon(sg,e,tp,mg)
	return sg:FilterCount(Card.IsAttribute,nil,ATTRIBUTE_WATER)>0
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	if chk==0 then return aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,0) end
end
function s.thfilter(c)
	return (c:IsFacedown() or (c:IsFaceup() and c:IsLevelBelow(8))) and not c:IsMaximumModeSide()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.thfilter,tp,0,LOCATION_MZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,1,tp,0)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	--Requirement
	local g=Duel.GetMatchingGroup(s.tdfilter,tp,LOCATION_GRAVE,0,e:GetHandler())
	local og=aux.SelectUnselectGroup(g,e,tp,3,3,s.rescon,1,tp,HINTMSG_TODECK,s.rescon)
	Duel.HintSelection(og)
	if Duel.SendtoDeck(og,nil,SEQ_DECKSHUFFLE,REASON_COST)<1 then return end
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_RTOHAND)
	local g=Duel.SelectMatchingCard(tp,s.thfilter,tp,0,LOCATION_MZONE,1,3,nil)
	if #g>0 then
		g=g:AddMaximumCheck()
		Duel.HintSelection(g)
		Duel.SendtoHand(g,nil,REASON_EFFECT)
	end
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetDescription(aux.Stringid(id,2))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ATTACK_ANNOUNCE)
	e1:SetTargetRange(LOCATION_MZONE,0)
	e1:SetCondition(s.atkcon)
	e1:SetTarget(s.atktg)
	e1:SetReset(RESET_PHASE|PHASE_END)
	Duel.RegisterEffect(e1,tp)
	local e2=Effect.CreateEffect(e:GetHandler())
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e2:SetCode(EVENT_ATTACK_ANNOUNCE)
	e2:SetOperation(s.checkop)
	e2:SetReset(RESET_PHASE|PHASE_END)
	e2:SetLabelObject(e1)
	Duel.RegisterEffect(e2,tp)
end
function s.atkcon(e)
	return e:GetLabel()~=0
end
function s.atktg(e,c)
	return c:GetFieldID()~=e:GetLabel()
end
function s.checkop(e,tp,eg,ep,ev,re,r,rp)
	local fid=eg:GetFirst():GetFieldID()
	e:GetLabelObject():SetLabel(fid)
end

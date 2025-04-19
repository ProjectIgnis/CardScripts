--現夢中のシルビクス
--Oneirophrenia Delirium Silbyx
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--fusion material
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,s.matfilter,2)
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.matfilter(c,fc,sumtype,tp)
	return c:IsLevelBetween(7,9) and c:IsRace(RACE_INSECT,fc,sumtype,tp) and c:IsType(TYPE_EFFECT,fc,sumtype,tp)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsStatus(STATUS_SPSUMMON_TURN) and c:IsSummonType(SUMMON_TYPE_FUSION)
end
function s.cfilter(c)
	return c:IsMonster() and c:IsRace(RACE_INSECT) and not c:IsLevel(9) and c:IsAbleToDeckOrExtraAsCost()
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter,tp,LOCATION_GRAVE,0,3,nil) end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Requirement
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
	local cg=Duel.SelectMatchingCard(tp,s.cfilter,tp,LOCATION_GRAVE,0,3,3,nil)
	if #cg==0 then return end
	Duel.HintSelection(cg)
	if Duel.SendtoDeck(cg,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)==0 then return end
	--Effect
	--Increase ATK
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD_DISABLE|RESET_PHASE|PHASE_END)
	e1:SetValue(500)
	c:RegisterEffect(e1)
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,nil) and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TODECK)
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(Card.IsAbleToDeck),tp,0,LOCATION_ONFIELD,1,1,nil)
		if #g>0 then
			g=g:AddMaximumCheck()
			Duel.HintSelection(g)
			Duel.SendtoDeck(g,nil,SEQ_DECKSHUFFLE,REASON_EFFECT)
		end
	end
end

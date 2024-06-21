--アビスカイト・パーティ
--Abysskite Party
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send cards from the top of your Deck to the GY
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES+CATEGORY_ATKCHANGE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.tgfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.tgfilter),tp,LOCATION_MZONE,0,nil)
	if chk==0 then return ct>0 and Duel.IsPlayerCanDiscardDeck(tp,ct) and Duel.IsPlayerCanDiscardDeck(1-tp,ct) end
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,ct)
end
function s.filter(c,e,tp)
	return c:IsFaceup() and c:IsRace(RACE_SEASERPENT) and c:IsAttribute(ATTRIBUTE_LIGHT) and c:GetBaseAttack()==800
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetMatchingGroupCount(aux.FilterMaximumSideFunctionEx(s.tgfilter),tp,LOCATION_MZONE,0,nil)
	Duel.DiscardDeck(tp,ct,REASON_EFFECT)
	Duel.DiscardDeck(1-tp,ct,REASON_EFFECT)
	if Duel.IsExistingMatchingCard(aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,nil)
		and Duel.SelectYesNo(tp,aux.Stringid(id,1)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATKDEF)
		local g=Duel.SelectMatchingCard(tp,aux.FilterMaximumSideFunctionEx(s.filter),tp,LOCATION_MZONE,0,1,3,nil)
		if #g<1 then return end
		Duel.HintSelection(g)
		local c=e:GetHandler()
		for tc in g:Iter() do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_ATTACK)
			e1:SetValue(1600)
			e1:SetReset(RESETS_STANDARD_PHASE_END,2)
			tc:RegisterEffect(e1)
		end
	end
end
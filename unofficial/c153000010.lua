--心眼の女神 (Deck Master)
--Goddess with the Third Eye (Deck Master)
--Scripted by Larry126
local s,id=GetID()
function s.initial_effect(c)
	if not DeckMaster then
		return
	end
	--Deck Master Effect
	local dme1=Effect.CreateEffect(c)
	dme1:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_FIELD)
	dme1:SetCode(EVENT_FREE_CHAIN)
	dme1:SetCondition(s.dmcon)
	dme1:SetOperation(s.dmop)
	DeckMaster.RegisterAbilities(c,dme1)
	--fusion substitute
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_FUSION_SUBSTITUTE)
	e1:SetCondition(s.subcon)
	c:RegisterEffect(e1)
end
function s.subcon(e)
	return e:GetHandler():IsLocation(LOCATION_HAND|LOCATION_ONFIELD|LOCATION_GRAVE)
end
function s.costfilter(c)
	return c:IsSpell() and c:IsDiscardable()
end
function s.dmcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsTurnPlayer(tp) and Duel.IsMainPhase()
		and Duel.IsExistingMatchingCard(s.costfilter,tp,LOCATION_HAND,0,1,nil)
		and Fusion.SummonEffTG()(e,tp,eg,ep,ev,re,r,rp,0) and Duel.IsDeckMaster(tp,id)
end
function s.dmop(e,tp,eg,ep,ev,re,r,rp)
	if not Duel.SelectYesNo(tp,aux.Stringid(id,0)) or Duel.DiscardHand(tp,s.costfilter,1,1,REASON_COST+REASON_DISCARD)~=1 then return end
	Duel.Hint(HINT_CARD,tp,id)
	Duel.Hint(HINT_CARD,1-tp,id)
	Duel.BreakEffect()
	Fusion.SummonEffOP()(e,tp,eg,ep,ev,re,r,rp)
end
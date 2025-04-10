--フォース・リリース
--Unleash Your Power!
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_POSITION)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_card_types={TYPE_GEMINI}
function s.filter(c)
	return c:IsFaceup() and c:IsType(TYPE_GEMINI) and not c:IsGeminiStatus()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local g=Duel.GetMatchingGroup(s.filter,tp,LOCATION_MZONE,0,nil)
	if chk==0 then return #g>0 end
	Duel.SetTargetCard(g)
end
function s.filter2(c,e)
	return s.filter(c) and not c:IsImmuneToEffect(e)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetTargetCards(e):Match(s.filter2,nil,e)
	if #g==0 then return end
	g:ForEach(Card.EnableGeminiStatus)
	aux.DelayedOperation(g,PHASE_END,id,e,tp,function(ag) Duel.ChangePosition(ag,POS_FACEDOWN_DEFENSE) end)
end
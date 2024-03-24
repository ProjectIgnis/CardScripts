--魔法除去 (Rush)
--De-Spell (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Reveal 1 set card in opponent's S/T zones
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.filter(c)
	return c:IsFacedown() or c:IsSpell()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.filter,tp,0,LOCATION_SZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,s.filter,tp,0,LOCATION_SZONE,1,1,nil)
	Duel.HintSelection(g,true)
	if g:GetFirst():IsFacedown() then Duel.ConfirmCards(tp,g) end
	if g:GetFirst():IsSpell() then Duel.Destroy(g,REASON_EFFECT) end
end
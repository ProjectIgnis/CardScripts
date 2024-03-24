--罠はずし (Rush)
--Remove Trap (Rush)
--scripted by YoshiDuels
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
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_STZONE,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,nil,0,tp,1)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local g=Duel.SelectMatchingCard(tp,Card.IsFacedown,tp,0,LOCATION_STZONE,1,1,nil)
	Duel.ConfirmCards(tp,g)
	if g:GetFirst():IsTrap() then
		Duel.Destroy(g,REASON_EFFECT)
	end
end
--未来破壊
local s,id=GetID()
function s.initial_effect(c)
	--discard deck
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetProperty(EFFECT_FLAG_REPEAT)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.recop)
	c:RegisterEffect(e1)
end
function s.recop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local g=Duel.GetFieldGroupCount(c:GetControler(),LOCATION_HAND,0)
	Duel.DiscardDeck(tp,g,REASON_EFFECT)
end

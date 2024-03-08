--ボルテック・バイコーン
--Voltic Bicorn (Anime)
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsRace,RACE_BEAST),1,1,Synchro.NonTuner(nil),1,99)
	c:EnableReviveLimit()
	--deckdes
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DECKDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local c=e:GetHandler()
	local lvl=c:GetLevel()
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,tp,lvl)
	Duel.SetOperationInfo(0,CATEGORY_DECKDES,nil,0,1-tp,lvl)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)	
	local c=e:GetHandler()
	local lvl=c:GetLevel()
	Duel.DiscardDeck(tp,lvl,REASON_EFFECT)
	Duel.DiscardDeck(1-tp,lvl,REASON_EFFECT)
end
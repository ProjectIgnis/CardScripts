--トップ・シェア
--Top Share
--Scripted by Hatter
local s,id=GetID()
function s.initial_effect(c)
	--Place on top
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCountLimit(1,id,EFFECT_COUNT_CODE_OATH)
	e1:SetTarget(s.pltg)
	e1:SetOperation(s.plop)
	c:RegisterEffect(e1)
end
function s.pltg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then
		return Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,LOCATION_DECK,0,1,nil) 
			and Duel.IsExistingMatchingCard(aux.NOT(Card.IsPublic),tp,0,LOCATION_DECK,1,nil) 
	end
end
function s.plop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,1))
	local tc=Duel.SelectMatchingCard(tp,aux.NOT(Card.IsPublic),tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.ShuffleDeck(tp)
	Duel.MoveSequence(tc,0)
	Duel.ConfirmDecktop(tp,1)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,1))
	tc=Duel.SelectMatchingCard(1-tp,aux.NOT(Card.IsPublic),1-tp,LOCATION_DECK,0,1,1,nil):GetFirst()
	if not tc then return end
	Duel.BreakEffect()
	Duel.ShuffleDeck(1-tp)
	Duel.MoveSequence(tc,0)
	Duel.ConfirmDecktop(1-tp,1)
end
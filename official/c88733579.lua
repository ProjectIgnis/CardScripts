--穿孔虫
--Drill Bug
local s,id=GetID()
function s.initial_effect(c)
	--search
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
s.listed_names={27911549}
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SELF)
	local tc=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_DECK,0,1,1,nil,27911549):GetFirst()
	if tc then
		Duel.ShuffleDeck(tp)
		Duel.MoveToDeckTop(tc)
		Duel.ConfirmDecktop(tp,1)
	end
end
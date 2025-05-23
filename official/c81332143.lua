--友情 YU－JYO
--Yu-Jo Friendship
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_names={14731897} --"Unity"
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local opt=0
	if Duel.IsExistingMatchingCard(Card.IsCode,tp,LOCATION_HAND,0,1,nil,14731897) and Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
		local g=Duel.SelectMatchingCard(tp,Card.IsCode,tp,LOCATION_HAND,0,1,1,nil,14731897)
		Duel.ConfirmCards(1-tp,g)
		Duel.ShuffleHand(tp)
		opt=1
	end
	if opt==0 then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,0),aux.Stringid(id,1))
	else
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,0))
	end
	if opt==0 then
		local lp=(Duel.GetLP(tp)+Duel.GetLP(1-tp))/2
		Duel.SetLP(tp,lp)
		Duel.SetLP(1-tp,lp)
	end
end
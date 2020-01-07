--三位一択
--Tri-and-Guess
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetMatchingGroupCount(Card.IsFacedown,tp,LOCATION_EXTRA,0,nil)>0
		and Duel.GetMatchingGroupCount(Card.IsFacedown,tp,0,LOCATION_EXTRA,nil)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CARDTYPE)
	local op=Duel.SelectOption(tp,aux.Stringid(id,0),aux.Stringid(id,1),aux.Stringid(id,2))
	e:SetLabel(op)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,LOCATION_EXTRA,0)
	Duel.ConfirmCards(1-tp,g1)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_EXTRA)
	Duel.ConfirmCards(tp,g2)
	local tpe=0
	if e:GetLabel()==0 then tpe=TYPE_FUSION
	elseif e:GetLabel()==1 then tpe=TYPE_SYNCHRO
	else tpe=TYPE_XYZ end
	local ct1=g1:FilterCount(Card.IsType,nil,tpe)
	local ct2=g2:FilterCount(Card.IsType,nil,tpe)
	if ct1>ct2 then
		Duel.Recover(tp,3000,REASON_EFFECT)
	elseif ct1<ct2 then
		Duel.Recover(1-tp,3000,REASON_EFFECT)
	end
	Duel.ShuffleExtra(1-tp)
	Duel.ShuffleExtra(tp)
end

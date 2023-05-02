--首領・ザルーグ
--Don Zaloog
local s,id=GetID()
function s.initial_effect(c)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e1:SetCode(EVENT_BATTLE_DAMAGE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	local b1=Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>0
	local b2=Duel.IsPlayerCanDiscardDeck(1-tp,2)
	if chk==0 then return b1 or b2 end
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,1)},
		{b2,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.SetOperationInfo(0,CATEGORY_HANDES,0,0,1-tp,1)
		e:SetCategory(CATEGORY_HANDES)
	else
		Duel.SetOperationInfo(0,CATEGORY_DECKDES,0,0,1-tp,2)
		e:SetCategory(CATEGORY_DECKDES)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if e:GetLabel()==1 then
		local g=Duel.GetFieldGroup(ep,LOCATION_HAND,0,nil)
		local sg=g:RandomSelect(ep,1)
		Duel.SendtoGrave(sg,REASON_DISCARD+REASON_EFFECT)
	else
		Duel.DiscardDeck(1-tp,2,REASON_EFFECT)
	end
end

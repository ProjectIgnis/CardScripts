--トラディショナル・タックス
--Traditional Tax
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Send 2 random cards from your opponent's hand to the Graveyard
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCategory(CATEGORY_HANDES)
	e1:SetCode(EVENT_DRAW)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return ep==1-tp and Duel.IsMainPhase()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetFieldGroupCount(tp,0,LOCATION_HAND)>1 end
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,2,1-tp,0)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	if #g<2 then return end
	local sg=g:RandomSelect(tp,2)
	if #sg>0 then
		Duel.SendtoGrave(sg,REASON_EFFECT)
	end
end
--ゴースト・サイクロン
--Ghost Cyclone

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Destroy 1 spell/trap your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
end
	--Activation legality
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,nil) end
end
	--Send 1 card from hand to GY to destroy 1 spell/trap your opponent controls
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	--Effect
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_DESTROY)
	local dg=Duel.SelectTarget(tp,Card.IsSpellTrap,tp,0,LOCATION_ONFIELD,1,1,nil)
	if #dg>0 then
		Duel.HintSelection(dg,true)
		if Duel.Destroy(dg,REASON_EFFECT)>0 and not Duel.IsExistingMatchingCard(Card.IsMonster,tp,LOCATION_GRAVE,0,4,nil)
			and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Draw(tp,1,REASON_EFFECT)
		end
	end
end
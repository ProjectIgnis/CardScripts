--バブル・クラッシュ
--Bubble Crash
local s,id=GetID()
function s.initial_effect(c)
	--Make players send cards to the GY until hand and field have only 5 card
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD|LOCATION_HAND,0)>=6 or Duel.GetFieldGroupCount(tp,0,LOCATION_ONFIELD|LOCATION_HAND)>=6
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetPossibleOperationInfo(0,CATEGORY_TOGRAVE,nil,0,PLAYER_ALL,LOCATION_ONFIELD|LOCATION_HAND)
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local ct=Duel.GetFieldGroupCount(tp,LOCATION_ONFIELD|LOCATION_HAND,0)
	local g1=Group.CreateGroup()
	if ct>=6 then
		local c=e:GetHandler()
		local exc=c:IsRelateToEffect(e) and c or nil
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
		g1=Duel.SelectMatchingCard(tp,nil,tp,LOCATION_ONFIELD|LOCATION_HAND,0,ct-5,ct-5,exc)
	end
	ct=Duel.GetFieldGroupCount(1-tp,LOCATION_ONFIELD|LOCATION_HAND,0)
	local g2=Group.CreateGroup()
	if ct>=6 then
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_TOGRAVE)
		g2=Duel.SelectMatchingCard(1-tp,nil,1-tp,LOCATION_ONFIELD|LOCATION_HAND,0,ct-5,ct-5,nil)
	end
	Duel.SendtoGrave(g1,REASON_RULE,PLAYER_NONE,1-tp)
	Duel.SendtoGrave(g2,REASON_RULE,PLAYER_NONE,1-tp)
end
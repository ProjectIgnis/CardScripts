--異種闘争
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_TOGRAVE)
	e1:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetHintTiming(0,TIMINGS_CHECK_MONSTER)
	e1:SetCondition(s.condition)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)>0
		and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0
		and not Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil)
end
function s.getattr(g)
	local aat=0
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		aat=(aat|tc:GetAttribute())
	end
	return aat
end
function s.rmfilter(c,at)
	return c:GetAttribute()==at
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetFieldGroupCount(tp,LOCATION_MZONE,0)==0
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,LOCATION_MZONE,0,1,nil)
		or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)==0
		or Duel.IsExistingMatchingCard(Card.IsFacedown,tp,0,LOCATION_MZONE,1,nil) then return end
	local g1=Duel.GetFieldGroup(tp,LOCATION_MZONE,0)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local c=e:GetHandler()
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,0))
	local r1=Duel.AnnounceAttribute(tp,1,s.getattr(g1))
	g1:Remove(s.rmfilter,nil,r1)
	Duel.Hint(HINT_SELECTMSG,1-tp,aux.Stringid(id,0))
	local r2=Duel.AnnounceAttribute(1-tp,1,s.getattr(g2))
	g2:Remove(s.rmfilter,nil,r2)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_EFFECT)
end

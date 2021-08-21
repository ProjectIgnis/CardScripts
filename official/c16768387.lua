--大王目玉
--Big Eye
local s,id=GetID()
function s.initial_effect(c)
	--sort the top deck
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_FLIP)
	e1:SetOperation(s.operation)
	c:RegisterEffect(e1)
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local ct=math.min(5,Duel.GetFieldGroupCount(tp,LOCATION_DECK,0))
	if ct==0 then return end
	local ac=ct==1 and ct or Duel.AnnounceNumberRange(tp,1,ct)
	Duel.SortDecktop(tp,tp,ct)
end

--Ｓｐ－大地讃頌
local s,id=GetID()
function s.initial_effect(c)
	local e1=Ritual.CreateProc(c,RITPROC_EQUAL,aux.FilterBoolFunction(Card.IsAttribute,ATTRIBUTE_EARTH),nil,1057)
	e1:SetCondition(s.condition)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	return tc and tc:GetCounter(0x91)>1
end
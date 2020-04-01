--呪われた棺
--Dark Coffin
local s,id=GetID()
function s.initial_effect(c)
	--Destroy
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_DESTROY+CATEGORY_HANDES)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_TO_GRAVE)
	e1:SetCondition(s.descon)
	e1:SetOperation(s.desop)
	c:RegisterEffect(e1)
end
function s.descon(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_DESTROY)~=0
		and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
		and e:GetHandler():IsPreviousPosition(POS_FACEDOWN)
end
function s.desop(e,tp,eg,ep,ev,re,r,rp)
	local g1=Duel.GetFieldGroup(tp,0,LOCATION_HAND)
	local g2=Duel.GetFieldGroup(tp,0,LOCATION_MZONE)
	local opt=0
	if #g1>0 and #g2>0 then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,1),aux.Stringid(id,2))
	elseif #g1>0 then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,1))
	elseif #g2>0 then
		opt=Duel.SelectOption(1-tp,aux.Stringid(id,2))+1
	else return end
	if opt==0 then
		local dg=g1:RandomSelect(1-tp,1)
		Duel.SendtoGrave(dg,REASON_EFFECT+REASON_DISCARD)
	else
		Duel.Hint(HINT_SELECTMSG,1-tp,HINTMSG_DESTROY)
		local dg=g2:Select(1-tp,1,1,nil)
		Duel.Destroy(dg,REASON_EFFECT)
	end
end

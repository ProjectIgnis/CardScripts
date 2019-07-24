--Number Frame
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,0,aux.FilterBoolFunction(Card.IsSetCard,0x7f),nil,nil,nil,s.op)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(1500)
	c:RegisterEffect(e2)
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() then
		local g=Duel.GetMatchingGroup(Card.IsSetCard,tp,LOCATION_EXTRA,0,nil,0x48)
		if #g>=2 and Duel.SelectYesNo(tp,aux.Stringid(id,0)) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
			local og=g:Select(tp,2,2,nil)
			Duel.Overlay(tc,og)
		end
	end
end

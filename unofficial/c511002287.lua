--Cyber Roar
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x93),nil,nil,s.tg,s.op)
	--atk up
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(300)
	c:RegisterEffect(e2)
end
s.listed_names={CARD_CYBER_DRAGON}
function s.tg(e,tp,eg,ep,ev,re,r,rp,tc)
	e:SetCategory(CATEGORY_EQUIP+CATEGORY_DRAW)
	if tc:IsCode(CARD_CYBER_DRAGON) then
		Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
	end
end
function s.op(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local tc=Duel.GetFirstTarget()
	if c:IsRelateToEffect(e) and tc and tc:IsRelateToEffect(e) and tc:IsFaceup() and tc:IsCode(CARD_CYBER_DRAGON) then
		Duel.Draw(tp,1,REASON_EFFECT)
	end
end

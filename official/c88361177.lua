--ドラグニティ－アングス
local s,id=GetID()
function s.initial_effect(c)
	--pierce
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_PIERCE)
	e1:SetCondition(s.pcon)
	c:RegisterEffect(e1)
end
s.listed_series={0x29}
function s.pcon(e)
	return e:GetHandler():GetEquipGroup():IsExists(Card.IsSetCard,1,nil,0x29)
end

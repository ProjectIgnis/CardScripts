--Supreme King Violent Spirit
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(id)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsSetCard(0xf8) and c:IsFaceup() 
end

--ヘル・アライアンス
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c)
	--Atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetValue(s.value)
	c:RegisterEffect(e2)
end
function s.filter(c,code)
	return c:IsFaceup() and c:IsCode(code)
end
function s.value(e,c)
	return Duel.GetMatchingGroupCount(s.filter,0,LOCATION_MZONE,LOCATION_MZONE,nil,c:GetCode())*800
end

--マタタビ・タービン
Duel.LoadScript("c420.lua")
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--Atk up
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_EQUIP)
	e3:SetCode(EFFECT_UPDATE_ATTACK)
	e3:SetValue(1200)
	c:RegisterEffect(e3)
	--cannot attack
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_EQUIP)
	e4:SetCode(EFFECT_CANNOT_SELECT_BATTLE_TARGET)
	e4:SetValue(s.vala)
	c:RegisterEffect(e4)
end
function s.filter(c)
	return c:IsCat() or c:IsNeko()
end
function s.vala(e,c)
	return c:GetControler()~=e:GetHandlerPlayer()
end

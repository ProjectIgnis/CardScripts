--転生炎獣の烈爪
--Salamangreat Claw
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:SetUniqueOnField(1,0,id)
	aux.AddEquipProcedure(c,nil,aux.FilterBoolFunction(Card.IsSetCard,0x119))
	aux.EnableCheckReincarnation(c)
	--indes
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e1:SetValue(1)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	c:RegisterEffect(e2)
	--pierce
	local e3=e1:Clone()
	e3:SetCode(EFFECT_PIERCE)
	c:RegisterEffect(e3)
	--multiattack
	local e4=e1:Clone()
	e4:SetCode(EFFECT_EXTRA_ATTACK_MONSTER)
	e4:SetCondition(s.macon)
	e4:SetValue(function(e,c) return c:GetLink()-1 end)
	c:RegisterEffect(e4)
end
function s.macon(e)
	local c=e:GetHandler():GetEquipTarget()
	return c:IsSetCard(0x119) and c:IsType(TYPE_LINK) and c:IsReincarnationSummoned()
end


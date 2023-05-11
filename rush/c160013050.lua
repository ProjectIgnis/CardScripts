--ヴォイドヴェルグ・グリンブルスティ
--Voidvelgr Gullinbursti
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--equip
	aux.AddEquipProcedure(c,0,s.eqfilter,s.eqlimit)
	--Cannot be destroyed by spell effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_EQUIP)
	e1:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e1:SetValue(s.efilter)
	c:RegisterEffect(e1)
	--Increase ATK
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.condition)
	e2:SetValue(800)
	c:RegisterEffect(e2)
end
function s.eqfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_GALAXY) and c:IsAttribute(ATTRIBUTE_DARK) and not c:IsMaximumModeSide()
end
function s.eqlimit(e,c)
    return c:IsFaceup()
end
function s.efilter(e,te)
	return te:IsSpellEffect()
end
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
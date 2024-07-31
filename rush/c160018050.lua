--サイバー・オステウス
--Cyber Osteus
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Fusion Summon Procedure
	Fusion.AddProcMixN(c,true,true,32393580,2)
	--Monsters on your opponent's field lose 600 ATK/DEF
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(aux.TargetBoolFunction(Card.IsFaceup))
	e1:SetValue(-600)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_UPDATE_DEFENSE)
	c:RegisterEffect(e2)
end
function s.condition(e)
	return Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
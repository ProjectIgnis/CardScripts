--Ｎｏ．３５ ラベノス・タランチュラ (Manga)
--Number 35: Ravenous Tarantula (Manga)
Duel.LoadCardScript("c90162951.lua")
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Xyz Summon procedure
	Xyz.AddProcedure(c,nil,10,2)
	--Cannot be destroyed by battle with non-"Number" monsters
    	local e1=Effect.CreateEffect(c)
    	e1:SetType(EFFECT_TYPE_SINGLE)
    	e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
    	e1:SetValue(aux.NOT(aux.TargetBoolFunction(Card.IsSetCard,SET_NUMBER)))
    	c:RegisterEffect(e1)
	--All Insect monsters you control have their ATK/DEF set to half the difference between each player's LP
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_SET_ATTACK)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(function(e,c) return c:IsRace(RACE_INSECT) end)
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetCode(EFFECT_SET_DEFENSE)
	c:RegisterEffect(e3)
end
s.listed_series={SET_NUMBER}
s.xyz_number=35
function s.val(e,c)
	local tp=e:GetHandler():GetControler()
	if Duel.GetLP(tp)<=Duel.GetLP(1-tp) then
		return (Duel.GetLP(1-tp)-Duel.GetLP(tp))/2
	else
		return (Duel.GetLP(tp)-Duel.GetLP(1-tp))/2
	end
end
--光学迷彩アーマー
local s,id=GetID()
function s.initial_effect(c)
	aux.AddEquipProcedure(c,nil,s.filter)
	--direct attack
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_EQUIP)
	e2:SetCode(EFFECT_DIRECT_ATTACK)
	e2:SetCondition(s.con)
	c:RegisterEffect(e2)
end
function s.filter(c)
	return c:IsLevelBelow(3) and c:IsRace(RACE_FAIRY)
end
function s.con(e)
	return not Duel.IsExistingMatchingCard(Card.IsAttackPos,e:GetHandlerPlayer(),0,LOCATION_MZONE,1,nil)
end

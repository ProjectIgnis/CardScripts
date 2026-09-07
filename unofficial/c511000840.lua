--鏡の迷宮－ミラー・ラビリンス
--Mirror Labyrinth
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--If you control no Level 5 or higher monsters, and the only monster you control is a Level 4 or lower monster: That monster can attack twice during each Battle Phase
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_EXTRA_ATTACK)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCondition(s.extraattackcon)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.extraattackcon(e)
	local g=Duel.GetFieldGroup(e:GetHandlerPlayer(),LOCATION_MZONE,0)
	return #g==1 and g:IsExists(aux.FaceupFilter(Card.IsLevelBelow,4),1,nil) and g:FilterCount(aux.FaceupFilter(Card.IsLevelAbove,5),nil)==0
end

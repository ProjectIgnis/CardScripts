--Infernity Pawn
local s,id=GetID()
function s.initial_effect(c)
	--cannot draw
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_DRAW)
	e1:SetRange(LOCATION_GRAVE)
	e1:SetTargetRange(1,0)
	e1:SetCondition(s.con)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EFFECT_DRAW_COUNT)
	e2:SetValue(0)
	c:RegisterEffect(e2)
end
function s.con(e)
	return Duel.GetFieldGroupCount(e:GetHandlerPlayer(),LOCATION_HAND,0)==0
end

--魔装獣ギアパルド
--Magiarms Beast Gearpard
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.con)
	e1:SetValue(200)
	c:RegisterEffect(e1)
	--battle protection
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.indcond)
	e2:SetValue(1)
	c:RegisterEffect(e2)
end
function s.con(e)
	return Duel.GetMatchingGroupCount(nil,e:GetHandlerPlayer(),LOCATION_SZONE,0,nil)>0
end
function s.indcond(e)
	return e:GetHandler():IsAttackPos() and Duel.GetTurnPlayer()~=e:GetHandlerPlayer() and s.con(e)
end
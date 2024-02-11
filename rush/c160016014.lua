--ダイスキー・キャラメイル
--Dice Key Caramail
local s,id=GetID()
function s.initial_effect(c)
	--Opponent cannot activate Trap Cards during the Battle Phase
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetTargetRange(0,1)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.aclimit)
	c:RegisterEffect(e1)
end
function s.confilter(c)
	return c:IsFaceup() and c:IsLevelAbove(7) and c.roll_dice
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(s.confilter,e:GetHandlerPlayer(),LOCATION_MZONE,0,1,nil) and Duel.IsBattlePhase()
end
function s.aclimit(e,re,tp)
	return re:GetHandler():IsTrap() and re:IsHasType(EFFECT_TYPE_ACTIVATE)
end
--破界王帝ウィッシュ・オブ・アウターバース［Ｒ］
--Wish of OuTerverSe the World-Shattering Emperor [R]
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Name becomes "OuTerverSe" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160022200)
	c:RegisterEffect(e0)
	--atkup
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetValue(s.val)
	c:RegisterEffect(e1)
	c:AddSideMaximumHandler(e1)
end
function s.condition(e)
	return e:GetHandler():IsMaximumMode() and Duel.IsTurnPlayer(1-e:GetHandlerPlayer())
end
function s.filter(c)
	return c:IsFaceup() and not c:IsRace(RACE_GALAXY) and not c:IsMaximumModeSide()
end
function s.val(e,c)
	return Duel.GetMatchingGroupCount(s.filter,c:GetControler(),0,LOCATION_MZONE,nil)*3000
end
--破界王帝ウィッシュ・オブ・アウターバース
--Wish of OuTerverSe the World-Shattering Emperor
--scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Maximum Procedure
	Maximum.AddProcedure(c,nil,s.filter1,s.filter2)
	c:AddMaximumAtkHandler()
	--Name becomes "OuTerverSe" in the Graveyard
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CHANGE_CODE)
	e0:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e0:SetRange(LOCATION_GRAVE)
	e0:SetValue(160022200)
	c:RegisterEffect(e0)
	--Atk
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,LOCATION_MZONE)
	e1:SetCondition(s.condition)
	e1:SetTarget(aux.NOT(aux.TargetBoolFunction(Card.IsRace,RACE_GALAXY)))
	e1:SetValue(-3000)
	c:RegisterEffect(e1)
	--pierce
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_PIERCE)
	e2:SetCondition(s.condition2)
	c:RegisterEffect(e2)
	--change type
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetCode(EFFECT_CHANGE_RACE)
	e3:SetValue(RACE_GALAXY)
	e3:SetCondition(s.condition2)
	c:RegisterEffect(e3)
end
s.MaximumAttack=3800
s.listed_names={160022200,160216058,160216060}
function s.filter1(c)
	return c:IsCode(160216058)
end
function s.filter2(c)
	return c:IsCode(160216060)
end
function s.condition(e)
	return e:GetHandler():IsMaximumMode()
end
function s.condition2(e)
	return e:GetHandler():IsMaximumMode() and Duel.GetTurnPlayer()==e:GetHandler():GetControler()
end
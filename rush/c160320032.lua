--摩天楼 －スカイスクレイパー－
--Skyscraper (Rush)
--Scripted by YoshiDuels
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--atk
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetRange(LOCATION_FZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetCondition(s.atkcon)
	e2:SetTarget(s.tg)
	e2:SetValue(1000)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetTargetRange(0,LOCATION_MZONE)
	e3:SetCondition(s.atkcon2)
	c:RegisterEffect(e3)
end
s.listed_names={21844576,58932615,84327329,20721928,79979666,CARD_NEOS}
function s.tg(e,c)
	return c:IsCode(21844576,58932615,84327329,20721928,79979666,CARD_NEOS) or (c:IsRace(RACE_WARRIOR) and c:IsType(TYPE_FUSION) and c:IsLevelBetween(5,8))
end
function s.atkcon(e)
	return Duel.GetTurnPlayer()==e:GetHandlerPlayer()
end
function s.atkcon2(e)
	return Duel.GetTurnPlayer()~=e:GetHandlerPlayer()
end
--クリアー・ヴィシャス・ナイト
--Clear Vicious Knight
--scripted by pyrQ
local s,id=GetID()
function s.initial_effect(c)
	--You can Tribute Summon this card by Tributing 1 monster that mentions "Clear World"
	aux.AddNormalSummonProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),function(c) return c:ListsCode(CARD_CLEAR_WORLD) end)
	aux.AddNormalSetProcedure(c,true,true,1,1,SUMMON_TYPE_TRIBUTE,aux.Stringid(id,0),function(c) return c:ListsCode(CARD_CLEAR_WORLD) end)
	--Gains ATK equal to the highest original ATK among monsters your opponent controls
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetCode(EFFECT_UPDATE_ATTACK)
	e1:SetRange(LOCATION_MZONE)
	e1:SetValue(s.atkval)
	c:RegisterEffect(e1)
	--You are unaffected by the effects of "Clear World"
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCode(EFFECT_CLEAR_WORLD_IMMUNE)
	e2:SetRange(LOCATION_MZONE)
	e2:SetTargetRange(1,0)
	c:RegisterEffect(e2)
	--Your opponent cannot activate the effects of Special Summoned monsters with ATK lower than this Tribute Summoned card's
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_FIELD)
	e3:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e3:SetCode(EFFECT_CANNOT_ACTIVATE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetTargetRange(0,1)
	e3:SetCondition(function(e) return e:GetHandler():IsTributeSummoned() end)
	e3:SetValue(s.actlimval)
	c:RegisterEffect(e3)
end
s.listed_names={CARD_CLEAR_WORLD}
function s.atkval(e,c)
	local _,val=Duel.GetMatchingGroup(Card.IsFaceup,e:GetHandlerPlayer(),0,LOCATION_MZONE,nil):GetMaxGroup(Card.GetBaseAttack)
	return val or 0
end
function s.actlimval(e,re,rp)
	local rc=re:GetHandler()
	return re:IsMonsterEffect() and rc:IsSpecialSummoned() and rc:GetAttack()<e:GetHandler():GetAttack() and rc:IsFaceup()
		and rc:IsLocation(LOCATION_MZONE)
end
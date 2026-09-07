--トマト・パラダイス
--Tomato Paradise
local s,id=GetID()
function s.initial_effect(c)
	--activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Plant monsters you control gain 200 ATK for each Plant monster you control
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_FIELD)
	e2:SetCode(EFFECT_UPDATE_ATTACK)
	e2:SetRange(LOCATION_SZONE)
	e2:SetTargetRange(LOCATION_MZONE,0)
	e2:SetTarget(aux.TargetBoolFunction(Card.IsRace,RACE_PLANT))
	e2:SetValue(s.val)
	c:RegisterEffect(e2)
	--The player who Summoned a Plant monster from the hand can Special Summon 1 "Tomato Token" to their field
	local e3a=Effect.CreateEffect(c)
	e3a:SetDescription(aux.Stringid(id,0))
	e3a:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3a:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3a:SetProperty(EFFECT_FLAG_BOTH_SIDE)
	e3a:SetCode(EVENT_SUMMON_SUCCESS)
	e3a:SetRange(LOCATION_FZONE)
	e3a:SetTarget(s.tktg)
	e3a:SetOperation(s.tkop)
	c:RegisterEffect(e3a)
	local e3b=e3a:Clone()
	e3b:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e3b)
end
s.listed_names={511000104} --"Tomato Token"
function s.val(e,c)
	return Duel.GetMatchingGroupCount(aux.FaceupFilter(Card.IsRace,RACE_PLANT),c:GetControler(),LOCATION_MZONE,0,nil)*200
end
function s.cfilter(c)
	return c:IsFaceup() and c:IsRace(RACE_PLANT) and c:IsSummonLocation(LOCATION_HAND)
end
function s.tktg(e,tp,eg,ep,ev,re,r,rp,chk)
	local tg=eg:Filter(s.cfilter,nil)
	local b1=tg:IsExists(Card.IsSummonPlayer,1,nil,tp)
	local b2=tg:IsExists(Card.IsSummonPlayer,1,nil,1-tp)
	local p=b1 and b2 and PLAYER_ALL or b1 and tp or 1-tp
	if chk==0 then return (b1 or b2) and Duel.GetLocationCount(p,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(p,id+1,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) end
	Duel.SetTargetPlayer(p)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,p,0)
end
function s.tkop(e,tp,eg,ep,ev,re,r,rp)
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if e:GetHandler():IsRelateToEffect(e) and Duel.GetLocationCount(p,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(p,id+1,0,TYPES_TOKEN,0,0,1,RACE_PLANT,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(p,id+1)
		Duel.SpecialSummon(token,0,p,p,false,false,POS_FACEUP)
	end
end

--セルケトの紋章
--Seal of Serket
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--This card remains on the field
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_REMAIN_FIELD)
	c:RegisterEffect(e2)
	--Once while on the field, Special Summon "Mystical Beast of Serket"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetProperty(EFFECT_FLAG_NO_TURN_RESET)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_SZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--"Mystical Beast of Serket" cannot be destroyed by card effects while this card and "Cup of Sealed Soul" are on the field
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD)
	e4:SetCode(EFFECT_INDESTRUCTABLE_EFFECT)
	e4:SetRange(LOCATION_SZONE)
	e4:SetTargetRange(LOCATION_ONFIELD,LOCATION_ONFIELD)
	e4:SetCondition(function(e) return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511001306),e:GetHandlerPlayer(),LOCATION_SZONE,0,1,nil) end)
	e4:SetTarget(function(e,c) return c:IsFaceup() and c:IsCode(89194033) end)
	e4:SetValue(1)
	c:RegisterEffect(e4)
end
s.listed_names={511001306,CARD_TEMPLE_OF_THE_KINGS,89194033} --"Cup of Sealed Soul, Mystical Beast of Serket"
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,511001306),tp,LOCATION_SZONE,0,1,nil)
		and Duel.IsExistingMatchingCard(aux.FaceupFilter(Card.IsCode,CARD_TEMPLE_OF_THE_KINGS),tp,LOCATION_SZONE,0,1,nil)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,89194033,0,TYPE_MONSTER|TYPE_EFFECT,2500,2000,6,RACE_FAIRY,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if not e:GetHandler():IsRelateToEffect(e) then return end
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 
		or not Duel.IsPlayerCanSpecialSummonMonster(tp,89194033,0,TYPE_MONSTER|TYPE_EFFECT,2500,2000,6,RACE_FAIRY,ATTRIBUTE_EARTH) then return end
	local token=Duel.CreateToken(tp,89194033)
	Duel.SpecialSummon(token,0,tp,tp,true,false,POS_FACEUP)
end
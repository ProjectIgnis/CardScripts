--Magni and Modi of the Nordic Champions
--designed by Thaumablazer#4134, scripted by Naim
function c210777085.initial_effect(c)
	--special summon from hand
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210777085,0))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_PROC)
	e1:SetRange(LOCATION_HAND)
	e1:SetCountLimit(1,210777085)
	e1:SetCondition(c210777085.hspcon)
	e1:SetOperation(c210777085.hspop)
	c:RegisterEffect(e1)
	--special summon from deck
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777085,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetCode(EVENT_BATTLE_DESTROYING)
	e2:SetCondition(aux.bdocon)
	e2:SetTarget(c210777085.target)
	e2:SetOperation(c210777085.operation)
	c:RegisterEffect(e2)
	--special summon token
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210777085,2))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCountLimit(1)
	e3:SetCondition(c210777085.spcon)
	e3:SetTarget(c210777085.sptg)
	e3:SetOperation(c210777085.spop)
	c:RegisterEffect(e3)
end
function c210777085.hspfilter(c,ft,tp)
	return c:IsSetCard(0x42)
		and (ft>0 or (c:IsControler(tp) and c:GetSequence()<5)) and (c:IsControler(tp) or c:IsFaceup())
end
function c210777085.hspcon(e,c)
	if c==nil then return true end
	local tp=c:GetControler()
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	return ft>-1 and Duel.CheckReleaseGroup(tp,c210777085.hspfilter,1,nil,ft,tp)
end
function c210777085.hspop(e,tp,eg,ep,ev,re,r,rp,c)
	local ft=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local g=Duel.SelectReleaseGroup(tp,c210777085.hspfilter,1,1,nil,ft,tp)
	Duel.Release(g,REASON_COST)
end
function c210777085.filter(c,e,tp)
	return c:IsSetCard(0x42) and not c:IsType(TYPE_TUNER) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210777085.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210777085.filter,tp,LOCATION_DECK,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_DECK)
end
function c210777085.operation(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,c210777085.filter,tp,LOCATION_DECK,0,1,1,nil,e,tp)
	local tc=g:GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
function c210777085.spfilter(c)
	return c:IsFaceup() and c:IsSetCard(0x42) and c:IsType(TYPE_TUNER)
end
function c210777085.spcon(e,c,tp)
	return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210777085.spfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210777085.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210777084,0x42,0x4011,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function c210777085.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and Duel.IsPlayerCanSpecialSummonMonster(tp,210777084,0x42,0x4011,0,0,1,RACE_BEAST,ATTRIBUTE_EARTH) then
		local token=Duel.CreateToken(tp,210777084)
		Duel.SpecialSummon(token,0,tp,tp,false,false,POS_FACEUP)
	end
end


--Hermodr of the Nordic Ascendant
--designed by Thaumablazer#4134, scripted by Naim
function c210777090.initial_effect(c)
	--nontuner
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(210777090,0))
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_NONTUNER)
	e1:SetCondition(c210777090.tuncond)
	c:RegisterEffect(e1)	
	--draw
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(210777090,1))
	e2:SetCategory(CATEGORY_DRAW)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e2:SetCountLimit(1,210777090)
	e2:SetCondition(c210777090.drcon)
	e2:SetTarget(c210777090.drtg)
	e2:SetOperation(c210777090.drop)
	c:RegisterEffect(e2)
	--spsummon
	local e3=Effect.CreateEffect(c)
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetDescription(aux.Stringid(210777090,2))
	e3:SetType(EFFECT_TYPE_IGNITION)
	e3:SetRange(LOCATION_GRAVE)
	e3:SetCountLimit(1,210777090+100)
	e3:SetCondition(c210777090.spcon)
	e3:SetTarget(c210777090.sptg)
	e3:SetOperation(c210777090.spop)
	c:RegisterEffect(e3)
end
function c210777090.cfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_TUNER)
end
function c210777090.tuncond(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210777090.cfilter1,tp,LOCATION_MZONE,0,1,nil)
end
function c210777090.drcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_SYNCHRO and (e:GetHandler():IsLocation(LOCATION_GRAVE) or e:GetHandler():IsLocation(LOCATION_REMOVED) or e:GetHandler():IsLocation(LOCATION_HAND))
end
function c210777090.drtg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(1)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,1)
end
function c210777090.drop(e,tp,eg,ep,ev,re,r,rp)
	local p,d=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER,CHAININFO_TARGET_PARAM)
	Duel.Draw(p,d,REASON_EFFECT)
end
function c210777090.sfilter(c)
	return c:IsFaceup() and (c:IsSetCard(0x42) or c:IsSetCard(0x4b))
end
function c210777090.spcon(e,tp,eg,ep,ev,re,r,rp)
	return Duel.IsExistingMatchingCard(c210777090.sfilter,tp,LOCATION_MZONE,0,1,nil)
end
function c210777090.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and e:GetHandler():IsCanBeSpecialSummoned(e,0,tp,false,false) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,e:GetHandler(),1,0,0)
end
function c210777090.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if c:IsRelateToEffect(e) then
		Duel.SpecialSummon(c,0,tp,tp,false,false,POS_FACEUP)
	end
end
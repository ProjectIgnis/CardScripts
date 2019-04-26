--Wattphoenix
--エレキフェニックス
function c210749503.initial_effect(c)
	c:EnableReviveLimit()
	aux.AddLinkProcedure(c,c210749503.sumfilter,2)
	--Attack directly
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_DIRECT_ATTACK)
	c:RegisterEffect(e1)
	--Cannot conduct battle phase
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_TOHAND)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCondition(c210749503.stuncon)
	e2:SetOperation(c210749503.stunop)
	c:RegisterEffect(e2)
	--Special summon from hand
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(210749503,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetCode(EVENT_BATTLE_DAMAGE)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCondition(c210749503.spcon)
	e3:SetTarget(c210749503.sptg)
	e3:SetOperation(c210749503.spop)
	c:RegisterEffect(e3)
end
function c210749503.sumfilter(c)
	return c:IsRace(RACE_THUNDER) and not c:IsType(TYPE_LINK)
end
--Opponent cannot conduct next battle phase
function c210749503.stuncon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_LINK) and c:GetMaterial():IsExists(c210749503.stunfilter,2,nil)
end
function c210749503.stunfilter(c)
	return c:IsSetCard(0xe)
end
function c210749503.stunop(e,tp,eg,ep,ev,re,r,rp)
	local e1=Effect.CreateEffect(e:GetHandler())
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
	e1:SetCode(EFFECT_CANNOT_BP)
	e1:SetTargetRange(0,1)
	e1:SetCondition(c210749503.countcon)
	e1:SetLabel(Duel.GetTurnCount())
	if Duel.GetTurnPlayer()==tp then
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,1)
	else
		e1:SetReset(RESET_PHASE+PHASE_END+RESET_OPPO_TURN,2)
	end
	Duel.RegisterEffect(e1,tp)
end
function c210749503.countcon(e)
	return Duel.GetTurnCount()~=e:GetLabel()
end
--Special summon Watt from hand
function c210749503.spcon(e,tp,eg,ep,ev,re,r,rp)
	return ep~=tp and Duel.GetAttackTarget()==nil
end
function c210749503.spfilter(c,e,tp)
	return c:IsSetCard(0xe) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210749503.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)>0
		and Duel.IsExistingMatchingCard(c210749503.spfilter,tp,LOCATION_HAND,0,1,nil,e,tp,zone) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND)
end
function c210749503.spop(e,tp,eg,ep,ev,re,r,rp)
	local zone=e:GetHandler():GetLinkedZone(tp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_TOFIELD,zone)<=0 then return end
	local g=Duel.SelectMatchingCard(tp,c210749503.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp,zone)
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP,zone)
	end
end
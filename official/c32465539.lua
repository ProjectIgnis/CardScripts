--電子光虫－コクーンデンサ
--Digital Bug Cocoondenser
local s,id=GetID()
function s.initial_effect(c)
	--xyzlimit
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_CANNOT_BE_XYZ_MATERIAL)
	e0:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e0:SetValue(s.xyzlimit)
	c:RegisterEffect(e0)
	--Special Summon
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_IGNITION)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCountLimit(1)
	e1:SetCondition(s.spcon)
	e1:SetTarget(s.sptg)
	e1:SetOperation(s.spop)
	c:RegisterEffect(e1)
	--effect gain
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_BE_MATERIAL)
	e2:SetCondition(s.efcon)
	e2:SetOperation(s.efop)
	c:RegisterEffect(e2)
end
function s.xyzlimit(e,c)
	if not c then return false end
	return not c:IsRace(RACE_INSECT)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPosition(POS_FACEUP_ATTACK)
end
function s.spfil(c,e,tp)
	return c:GetLevel()==3 and c:IsRace(RACE_INSECT) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsControler(tp) and chkc:IsLocation(LOCATION_GRAVE) and s.spfil(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfil,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfil,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsDefensePos() then return end
	Duel.ChangePosition(c,POS_FACEUP_DEFENSE)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	local tc=Duel.GetFirstTarget()
	if tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
function s.efcon(e,tp,eg,ep,ev,re,r,rp)
	return r==REASON_XYZ
end
function s.efop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local rc=c:GetReasonCard()
	local e1=Effect.CreateEffect(rc)
	e1:SetDescription(aux.Stringid(id,1))
	e1:SetType(EFFECT_TYPE_FIELD)
	e1:SetProperty(EFFECT_FLAG_PLAYER_TARGET+EFFECT_FLAG_CLIENT_HINT)
	e1:SetCode(EFFECT_CANNOT_ACTIVATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetTargetRange(0,1)
	e1:SetValue(1)
	e1:SetCondition(s.actcon)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	rc:RegisterEffect(e1,true)
	if not rc:IsType(TYPE_EFFECT) then
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_SINGLE)
		e2:SetCode(EFFECT_ADD_TYPE)
		e2:SetValue(TYPE_EFFECT)
		e2:SetReset(RESET_EVENT|RESETS_STANDARD)
		rc:RegisterEffect(e2,true)
	end
end
function s.actcon(e)
	return Duel.GetAttacker()==e:GetHandler() and Duel.GetAttackTarget() and Duel.GetAttackTarget():IsPosition(POS_DEFENSE)
end
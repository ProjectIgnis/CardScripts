--にらみ合い
--Starring Contest
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--move
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetRange(LOCATION_SZONE)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetCondition(s.mvcon(0))
	e2:SetTarget(s.mvtg1)
	e2:SetOperation(s.mvop1)
	c:RegisterEffect(e2)
	local e3=e2:Clone()
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCondition(s.mvcon(1))
	e3:SetTarget(s.mvtg2)
	e3:SetOperation(s.mvop2)
	c:RegisterEffect(e3)
end
function s.getzone(p,eg)
	local zone=0
	for tc in aux.Next(eg:Filter(s.cfilter,nil,p)) do
		zone=zone|tc:GetColumnZone(LOCATION_MZONE,0,0,1-p)
	end
	return zone
end
function s.cfilter(c,tp)
	return c:IsSummonPlayer(tp) and c:IsInExtraMZone()
end
function s.mvcon(i)
	return function(e,tp,eg,ep,ev,re,r,rp)
		return eg:IsExists(s.cfilter,1,nil,tp-i*(2*tp - 1))
	end
end
function s.mvtg1(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=s.getzone(tp,eg)
	if chkc then return chkc:IsInMainMZone(1-tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsInMainMZone,tp,0,LOCATION_MZONE,1,nil)
		and Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL,zone)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SelectTarget(tp,Card.IsInMainMZone,tp,0,LOCATION_MZONE,1,1,nil)
end
function s.mvop1(e,tp,eg,ep,ev,re,r,rp)
	local zone=s.getzone(tp,eg)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(tp) or tc:IsImmuneToEffect(e)
		or Duel.GetLocationCount(1-tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,0,LOCATION_MZONE,~(zone<<16))>>16,2))
end
function s.mvtg2(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local zone=s.getzone(1-tp,eg)
	if chkc then return chkc:IsInMainMZone(tp) end
	if chk==0 then return Duel.IsExistingTarget(Card.IsInMainMZone,tp,LOCATION_MZONE,0,1,nil)
		and Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL,zone)>0 end
	Duel.Hint(HINT_SELECTMSG,tp,aux.Stringid(id,2))
	Duel.SelectTarget(tp,Card.IsInMainMZone,tp,LOCATION_MZONE,0,1,1,nil)
end
function s.mvop2(e,tp,eg,ep,ev,re,r,rp)
	local zone=s.getzone(1-tp,eg)
	local tc=Duel.GetFirstTarget()
	if not tc:IsRelateToEffect(e) or tc:IsControler(1-tp)
		or Duel.GetLocationCount(tp,LOCATION_MZONE,tp,LOCATION_REASON_CONTROL,zone)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOZONE)
	Duel.MoveSequence(tc,math.log(Duel.SelectDisableField(tp,1,LOCATION_MZONE,0,~zone),2))
end

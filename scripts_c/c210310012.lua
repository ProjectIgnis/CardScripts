--Elemelon Harvest Season!
--AlphaKretin
function c210310012.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_DESTROYED)
	e1:SetProperty(EFFECT_FLAG_DAMAGE_STEP+EFFECT_FLAG_DELAY)
	e1:SetCountLimit(1,210310013+EFFECT_COUNT_CODE_OATH)
	e1:SetCondition(c210310012.condition)
	e1:SetTarget(c210310012.target)
	e1:SetOperation(c210310012.operation)
	c:RegisterEffect(e1)
end
function c210310012.cfilter(c,tp)
	return c:IsReason(REASON_BATTLE+REASON_EFFECT) and c:GetPreviousControler()==tp and c:IsPreviousLocation(LOCATION_ONFIELD) and c:IsSetCard(0xf31)
end
function c210310012.condition(e,tp,eg,ep,ev,re,r,rp)
	return eg:IsExists(c210310012.cfilter,1,nil,tp) and Duel.GetTurnPlayer()~=tp
end
function c210310012.sumfilter(c,e,tp)
	return c:IsSetCard(0xf31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function c210310012.elfilter(c)
	return c:IsFaceup() and c:IsSetCard(0xf31)
end
function c210310012.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(c210310012.sumfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) 
		and Duel.IsExistingMatchingCard(c210310012.elfilter,tp,LOCATION_MZONE,0,1,nil) 
		and Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)>0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function c210310012.attfilter(c,e,tp,ag)
	if not (c:IsSetCard(0xf31) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)) then return false end
	for ac in aux.Next(ag) do
		if c:GetAttribute()==ac:GetAttribute() then return false end
	end
	return true
end
function c210310012.operation(e,tp,eg,ep,ev,re,r,rp)
	local oppnum=Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 or Duel.GetFieldGroupCount(tp,0,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local attrs={}
	local g=Duel.SelectMatchingCard(tp,c210310012.sumfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	g:KeepAlive()
	while oppnum>1 and g:GetCount()<=Duel.GetLocationCount(tp,LOCATION_MZONE) do
		local tg=Duel.SelectMatchingCard(tp,c210310012.attfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp,g)
		g:Merge(tg)
		oppnum=oppnum-1
	end
	if g:GetCount()>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end

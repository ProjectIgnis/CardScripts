--Ancient Gear Rebirth Fusion
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_FUSION_SUMMON)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_LEAVE_FIELD)
	e1:SetCondition(s.con)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.con(e,tp,eg,ep,ev,re,r,rp)
	return (r&REASON_EFFECT)==REASON_EFFECT and rp~=tp
end
function s.cfilter(c,fc,e,tp)
	local fd=c:GetCode()
	if not c:IsSetCard(0x7) or c:IsPreviousPosition(POS_FACEDOWN) or not c:IsPreviousControler(tp) 
		or not c:IsCanBeEffectTarget(e) then return false end
	for i=1,fc.material_count do
		if fd==fc.material[i] then return true end
	end
	return false
end
function s.spfilter(c,e,tp,eg)
	local ct=c.material_count
	return ct~=nil and eg:IsExists(s.cfilter,1,nil,c,e,tp) and c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) 
		and c:CheckFusionMaterial()
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local sg=Duel.GetMatchingGroup(s.spfilter,tp,LOCATION_EXTRA,0,nil,e,tp,eg)
	if chkc then return false end
	if chk==0 then return #sg>0 and Duel.GetLocationCountFromEx(tp)>0 end
	local tcg=sg:GetFirst()
	local tg=Group.CreateGroup()
	while tcg do
		local g=eg:Filter(s.cfilter,nil,tcg,e,tp)
		tg:Merge(g)
		tcg=sg:GetNext()
	end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TARGET)
	local tgf=tg:Select(tp,1,1,nil)
	Duel.SetTargetCard(tgf)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,0,LOCATION_EXTRA)
end
function s.spfilter2(c,e,tp,tc)
	local fd=tc:GetCode()
	local ct=c.material_count
	if ct==nil or not c:IsCanBeSpecialSummoned(e,SUMMON_TYPE_FUSION,tp,false,false) then return false end
	for i=1,c.material_count do
		if fd==c.material[i] then return true end
	end
	return false
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if not tc or not tc:IsRelateToEffect(e) or Duel.GetLocationCountFromEx(tp)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local sc=Duel.SelectMatchingCard(tp,s.spfilter2,tp,LOCATION_EXTRA,0,1,1,nil,e,tp,tc):GetFirst()
	if sc and Duel.SpecialSummon(sc,SUMMON_TYPE_FUSION,tp,tp,false,false,POS_FACEUP)>0 then
		sc:CompleteProcedure()
	end
end

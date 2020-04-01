--黒竜の忍者
local s,id=GetID()
function s.initial_effect(c)
	--spsummon condition
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(s.splimit)
	c:RegisterEffect(e1)
	--remove
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetCategory(CATEGORY_REMOVE)
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetCode(EVENT_FREE_CHAIN)
	e2:SetRange(LOCATION_MZONE)
	e2:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e2:SetHintTiming(0,TIMINGS_CHECK_MONSTER_E)
	e2:SetCountLimit(1)
	e2:SetCost(s.rmcost)
	e2:SetTarget(s.rmtg)
	e2:SetOperation(s.rmop)
	c:RegisterEffect(e2)
	--special summon
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
	--clear
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e4:SetCode(EVENT_SUMMON_SUCCESS)
	e4:SetOperation(s.clearop)
	c:RegisterEffect(e4)
	local e5=e4:Clone()
	e5:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e5)
	local ng=Group.CreateGroup()
	ng:KeepAlive()
	e2:SetLabelObject(ng)
	e3:SetLabelObject(ng)
	e4:SetLabelObject(ng)
	e5:SetLabelObject(ng)
end
s.listed_series={0x2b,0x61}
function s.splimit(e,se,sp,st)
	return (se:IsActiveType(TYPE_MONSTER) and se:GetHandler():IsSetCard(0x2b)) or se:GetHandler():IsSetCard(0x61)
end
function s.cfilter1(c,tp)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsType(TYPE_MONSTER) and c:IsSetCard(0x2b) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingMatchingCard(s.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,c,c)
end
function s.cfilter2(c,cc)
	return (c:IsLocation(LOCATION_HAND) or c:IsFaceup()) and c:IsSetCard(0x61) and c:IsAbleToGraveAsCost()
		and Duel.IsExistingTarget(s.rmfilter,0,LOCATION_MZONE,LOCATION_MZONE,1,c,cc)
end
function s.rmfilter(c,cc)
	return c~=cc and c:IsAbleToRemove()
end
function s.rmcost(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g1=Duel.SelectMatchingCard(tp,s.cfilter1,tp,LOCATION_HAND+LOCATION_MZONE,0,1,1,nil,tp)
	local cc=g1:GetFirst()
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOGRAVE)
	local g2=Duel.SelectMatchingCard(tp,s.cfilter2,tp,LOCATION_HAND+LOCATION_ONFIELD,0,1,1,cc,cc)
	g1:Merge(g2)
	Duel.SendtoGrave(g1,REASON_COST)
end
function s.rmtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_MZONE) and chkc:IsAbleToRemove() end
	if chk==0 then return true end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_REMOVE)
	local g=Duel.SelectTarget(tp,Card.IsAbleToRemove,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil)
	Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
end
function s.rmop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) and Duel.Remove(tc,POS_FACEUP,REASON_EFFECT)~=0 and tc:IsLocation(LOCATION_REMOVED) then
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,0)
		e:GetLabelObject():AddCard(tc)
	end
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsPreviousPosition(POS_FACEUP) and not c:IsLocation(LOCATION_DECK)
end
function s.spfilter(c,e,tp)
	return c:GetFlagEffect(id)~=0
		and (c:IsCanBeSpecialSummoned(e,0,tp,false,false) or c:IsCanBeSpecialSummoned(e,0,tp,false,false,1-tp))
end
function s.spfilter1(c,e,tp)
	return c:GetFlagEffect(id)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false) and c:GetOwner()==tp
end
function s.spfilter2(c,e,tp)
	return c:GetFlagEffect(id)~=0 and c:IsCanBeSpecialSummoned(e,0,tp,false,false,1-tp) and c:GetOwner()==1-tp
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	local g=e:GetLabelObject():Filter(s.spfilter,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,#g,0,0)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local ft1=Duel.GetLocationCount(tp,LOCATION_MZONE)
	local ft2=Duel.GetLocationCount(1-tp,LOCATION_MZONE)
	local rg=e:GetLabelObject()
	if (ft1<=0 and ft2<=0) or #rg<=0 then return end
	local sg=nil
	local sg1=rg:Filter(s.spfilter1,nil,e,tp)
	local sg2=rg:Filter(s.spfilter2,nil,e,tp)
	local gc1=#sg1
	local gc2=#sg2
	if Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT) then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
		if ft1<=0 and gc2>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg=sg2:Select(tp,1,1,nil)
		elseif ft2<=0 and gc1>0 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg=sg1:Select(tp,1,1,nil)
		elseif (gc1>0 and ft1>0) or (gc2>0 and ft2>0) then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg=rg:FilterSelect(tp,s.spfilter,1,1,nil,e,tp)
		end
		if sg~=nil then
			Duel.SpecialSummon(sg,0,tp,sg:GetFirst():GetOwner(),false,false,POS_FACEUP)
		end
		rg:Clear()
		return
	end
	if gc1>0 and ft1>0 then
		if #sg1>ft1 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg1=sg1:Select(tp,ft1,ft1,nil)
		end
		local sc=sg1:GetFirst()
		for sc in aux.Next(sg1) do
			Duel.SpecialSummonStep(sc,0,tp,tp,false,false,POS_FACEUP)
		end
	end
	if gc2>0 and ft2>0 then
		if #sg2>ft2 then
			Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
			sg2=sg2:Select(tp,ft2,ft2,nil)
		end
		local sc=sg2:GetFirst()
		for sc in aux.Next(dg2) do
			Duel.SpecialSummonStep(sc,0,tp,1-tp,false,false,POS_FACEUP)
		end
	end
	Duel.SpecialSummonComplete()
	rg:Clear()
end
function s.clearop(e,tp,eg,ep,ev,re,r,rp)
	e:GetLabelObject():Clear()
end

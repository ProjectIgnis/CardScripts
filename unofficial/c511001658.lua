--真閃珖竜 スターダスト・クロニクル (Manga)
--Stardust Chronicle Spark Dragon (Manga)
local s,id=GetID()
function s.initial_effect(c)
	--synchro summon
	Synchro.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsType,TYPE_SYNCHRO),1,1,Synchro.NonTunerEx(Card.IsType,TYPE_SYNCHRO),1,99)
	c:EnableReviveLimit()
	--
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetLabel(0)
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetCode(EFFECT_MATERIAL_CHECK)
	e2:SetValue(s.valcheck)
	e2:SetLabelObject(e1)
	c:RegisterEffect(e2)
	--leave replace
	local e3=Effect.CreateEffect(c)
	e3:SetType(EFFECT_TYPE_CONTINUOUS+EFFECT_TYPE_SINGLE)
	e3:SetRange(LOCATION_MZONE)
	e3:SetProperty(EFFECT_FLAG_DAMAGE_STEP)
	e3:SetCode(EFFECT_SEND_REPLACE)
	e3:SetTarget(s.reptg)
	e3:SetLabelObject(e1)
	c:RegisterEffect(e3)
	--reset
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e4:SetCode(EVENT_ADJUST)
	e4:SetCountLimit(1)
	e4:SetRange(LOCATION_MZONE)
	e4:SetOperation(s.reset)
	e4:SetLabelObject(e1)
	c:RegisterEffect(e4)
	--Special Summon
	local e5=Effect.CreateEffect(c)
	e5:SetDescription(aux.Stringid(id,1))
	e5:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e5:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e5:SetCode(EVENT_LEAVE_FIELD)
	e5:SetCondition(s.spcon)
	e5:SetTarget(s.sptg)
	e5:SetOperation(s.spop)
	c:RegisterEffect(e5)
end
s.synchro_tuner_required=1
s.synchro_nt_required=1
s.listed_series={83994433}
function s.valcheck(e,c)
	local ct=c:GetMaterialCount()
	e:GetLabelObject():SetLabel(ct)
end
function s.reptg(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=e:GetLabelObject():GetLabel()
	if chk==0 then return ct>0 end
	c:SetTurnCounter(ct-1)
	e:GetLabelObject():SetLabel(ct-1)
	return true
end
function s.reset(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	local ct=c:GetMaterialCount()
	c:SetTurnCounter(ct)
	e:GetLabelObject():SetLabel(ct)
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():IsPreviousPosition(POS_FACEUP) and e:GetHandler():IsPreviousLocation(LOCATION_ONFIELD)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return true end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_EXTRA)
end
function s.spfilter(c,e,tp)
	return c:IsCode(83994433) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
	and ((c:IsLocation(LOCATION_GRAVE) and Duel.GetLocationCount(tp,LOCATION_MZONE)>0)
	or (c:IsLocation(LOCATION_EXTRA) and Duel.GetLocationCountFromEx(tp,tp,nil,c)>0))
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_EXTRA,0,1,1,nil,e,tp):GetFirst()
	if tc then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP)
	end
end
--クラリアの蟲惑魔
--Traptrix Utricularia
--Logical Nonsense

--Substitute ID
local s,id=GetID()
function s.initial_effect(c)
	--Must be properly summoned before reviving
	c:EnableReviveLimit()
	--Link summon procedure
	Link.AddProcedure(c,s.matfilter,2,2)
	--Unaffected by trap effects
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCode(EFFECT_IMMUNE_EFFECT)
	e1:SetCondition(s.immcon)
	e1:SetValue(s.efilter)
	--Set 1 activated "Hole" normal trap instead of sending it to GY
	c:RegisterEffect(e1)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e2:SetCode(EVENT_CHAIN_SOLVING)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.setcon)
	e2:SetTarget(s.settg)
	e2:SetOperation(s.setop)
	c:RegisterEffect(e2)
	--Special summon 1 "Traptrix" monster from GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e3:SetRange(LOCATION_MZONE)
	e3:SetCode(EVENT_PHASE+PHASE_END)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(_,tp)return Duel.GetTurnPlayer()==tp end)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
	--Lists "Traptrix" and "Hole" archetypes
s.listed_series={0x108a,0x4c,0x89}
	
function s.matfilter(c,sc,st,tp)
	return c:IsRace(RACE_PLANT+RACE_INSECT,sc,st,tp)
end
	--If this card was link summoned
function s.immcon(e)
	return e:GetHandler():IsSummonType(SUMMON_TYPE_LINK)
end
	--Unaffected by trap effects
function s.efilter(e,te)
	return te:IsActiveType(TYPE_TRAP)
end
	--When a "Hole" normal trap is resolving
function s.setcon(e,tp,eg,ep,ev,re,r,rp)
	return rp==tp and re:GetActiveType()==TYPE_TRAP and re:IsHasType(EFFECT_TYPE_ACTIVATE)
		and (re:GetHandler():IsSetCard(0x4c) or re:GetHandler():IsSetCard(0x89))
		and e:GetHandler():GetFlagEffect(id)==0
end
	--Activation legality
function s.settg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return re:GetHandler():IsCanTurnSet() end
end
	--Set 1 activated "Hole" normal trap instead of sending it to GY
function s.setop(e,tp,eg,ep,ev,re,r,rp)
	local rc=re:GetHandler()
	if not rc:IsFaceup() or not rc:IsRelateToEffect(e) then return end
	if Duel.SelectYesNo(tp,aux.Stringid(id,2)) then
		e:GetHandler():RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD+RESET_PHASE+PHASE_END,0,1)
		rc:CancelToGrave()
		Duel.ChangePosition(rc,POS_FACEDOWN)
	end
end
	--Check for a "Traptrix" monster
function s.spfilter(c,e,tp)
	return c:IsSetCard(0x108a) and c:IsCanBeSpecialSummoned(e,0,tp,false,false,POS_FACEUP_DEFENSE)
end
	--Activation legality
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chkc then return chkc:IsLocation(LOCATION_GRAVE) and chkc:IsControler(tp) and s.spfilter(chkc,e,tp) end
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingTarget(s.spfilter,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectTarget(tp,s.spfilter,tp,LOCATION_GRAVE,0,1,1,nil,e,tp)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,g,1,0,0)
end
	--Special summon 1 "Traptrix" monster from GY in defense position
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	local tc=Duel.GetFirstTarget()
	if tc and tc:IsRelateToEffect(e) then
		Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
	end
end
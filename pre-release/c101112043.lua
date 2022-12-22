--マナドゥム・プライムハート
--Manadome Prime-Heart
--scripted by Naim
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	--Synchro Summon procedure
	Synchro.AddProcedure(c,nil,1,99,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_LIGHT),1,1)
	--Check for the number of Tuners
	local e0=Effect.CreateEffect(c)
	e0:SetType(EFFECT_TYPE_SINGLE)
	e0:SetCode(EFFECT_MATERIAL_CHECK)
	e0:SetValue(s.valcheck)
	c:RegisterEffect(e0)
	--Multiple attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetCondition(function(e) return e:GetHandler():IsSummonType(SUMMON_TYPE_SYNCHRO) and e:GetLabelObject():GetLabel()>=2 end)
	e1:SetOperation(s.atkop)
	e1:SetLabelObject(e0)
	c:RegisterEffect(e1)
	--Cannot be targeted by opponent's effect if summoned with a "Manadome" Tuner
	local e2=Effect.CreateEffect(c)
	e2:SetType(EFFECT_TYPE_SINGLE)
	e2:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e2:SetCode(EFFECT_CANNOT_BE_EFFECT_TARGET)
	e2:SetRange(LOCATION_MZONE)
	e2:SetCondition(s.tgcond)
	e2:SetValue(aux.tgoval)
	c:RegisterEffect(e2)
	--Special Summon 1 "Visas Starfrost" or 1 monster with 1500 ATK/2100 DEF
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,0))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_LEAVE_FIELD)
	e3:SetCondition(s.spcon)
	e3:SetTarget(s.sptg)
	e3:SetOperation(s.spop)
	c:RegisterEffect(e3)
end
s.listed_series={SET_MANADOME}
s.listed_names={CARD_VISAS_STARFROST}
function s.tunerfilter(c,sc,tp)
	return c:IsSetCard(SET_MANADOME,sc,SUMMON_TYPE_SYNCHRO,tp) and c:IsType(TYPE_TUNER,sc,SUMMON_TYPE_SYNCHRO,tp)
end
function s.valcheck(e,c)
	local mg=c:GetMaterial()
	e:SetLabel(not mg and 0 or mg:FilterCount(Card.IsType,nil,TYPE_TUNER))
	if mg:IsExists(s.tunerfilter,1,nil,c,e:GetHandlerPlayer()) then
		c:RegisterFlagEffect(id,RESET_EVENT|RESETS_STANDARD&~(RESET_TOFIELD|RESET_LEAVE|RESET_TEMP_REMOVE),EFFECT_FLAG_CLIENT_HINT,1,0,aux.Stringid(id,1))
	end
end
function s.atkop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Grant additional attacks
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetCode(EFFECT_EXTRA_ATTACK)
	e1:SetValue(e:GetLabelObject():GetLabel()-1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD_DISABLE)
	c:RegisterEffect(e1)
end
function s.tgcond(e)
	local c=e:GetHandler()
	return c:IsSummonType(SUMMON_TYPE_SYNCHRO) and c:GetFlagEffect(id)>0
end
function s.spcon(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return rp==1-tp and c:IsPreviousControler(tp) and c:IsPreviousPosition(POS_FACEUP) and c:IsPreviousLocation(LOCATION_MZONE) and c:IsSummonType(SUMMON_TYPE_SYNCHRO)
end
function s.spfilter(c,e,tp)
	return (c:IsCode(CARD_VISAS_STARFROST) or (c:IsAttack(1500) and c:IsDefense(2100))) and c:IsFaceup()
		and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and
		Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE|LOCATION_REMOVED)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)==0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter),tp,LOCATION_GRAVE|LOCATION_REMOVED,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
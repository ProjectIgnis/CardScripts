--海晶乙女 ワンダーハート
--Marincess Wonder Heart
--Scripted by Eerie Code
local s,id=GetID()
function s.initial_effect(c)
	c:EnableReviveLimit()
	Link.AddProcedure(c,aux.FilterBoolFunctionEx(Card.IsAttribute,ATTRIBUTE_WATER),2)
	--special summon (equip)
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e1:SetType(EFFECT_TYPE_QUICK_O)
	e1:SetCode(EVENT_PRE_DAMAGE_CALCULATE)
	e1:SetRange(LOCATION_MZONE)
	e1:SetCondition(s.spcon1)
	e1:SetTarget(s.sptg1)
	e1:SetOperation(s.spop1)
	c:RegisterEffect(e1)
	aux.AddEREquipLimit(c,nil,s.eqval,aux.EquipByEffectAndLimitRegister,e1)
	--special summon (gy)
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY+EFFECT_FLAG_DAMAGE_STEP)
	e2:SetCode(EVENT_DESTROYED)
	e2:SetCondition(s.spcon2)
	e2:SetTarget(s.sptg2)
	e2:SetOperation(s.spop2)
	c:RegisterEffect(e2)
end
s.listed_series={0x12b}
function s.spcon1(e,tp,eg,ep,ev,re,r,rp)
	return e:GetHandler():GetBattleTarget()
end
function s.spfilter1(c,e,tp)
	return c:IsSetCard(0x12b) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg1(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 
		and c:GetEquipGroup():IsExists(s.spfilter1,1,nil,e,tp) and c:GetFlagEffect(id)==0 end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_SZONE)
	c:RegisterFlagEffect(id,RESET_CHAIN,0,1)
end
function s.spop1(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() or Duel.GetLocationCount(tp,LOCATION_MZONE)<1 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=c:GetEquipGroup():FilterSelect(tp,s.spfilter1,1,1,nil,e,tp):GetFirst()
	if tc and Duel.SpecialSummonStep(tc,0,tp,tp,false,false,POS_FACEUP) then
		local fid=c:GetFieldID()
		tc:RegisterFlagEffect(id,RESET_EVENT+RESETS_STANDARD,0,1,fid)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_INDESTRUCTABLE_BATTLE)
		e1:SetValue(1)
		e1:SetReset(RESET_PHASE+PHASE_DAMAGE)
		c:RegisterEffect(e1)
		local e2=Effect.CreateEffect(c)
		e2:SetType(EFFECT_TYPE_FIELD)
		e2:SetCode(EFFECT_AVOID_BATTLE_DAMAGE)
		e2:SetProperty(EFFECT_FLAG_PLAYER_TARGET)
		e2:SetTargetRange(1,0)
		e2:SetReset(RESET_PHASE+PHASE_DAMAGE)
		Duel.RegisterEffect(e2,tp)
		Duel.RegisterEffect(e2,tp)
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
		e3:SetCode(EVENT_PHASE+PHASE_END)
		e3:SetProperty(EFFECT_FLAG_IGNORE_IMMUNE)
		e3:SetCountLimit(1)
		e3:SetLabel(fid)
		e3:SetLabelObject(tc)
		e3:SetCondition(s.eqcon)
		e3:SetOperation(s.eqop)
		Duel.RegisterEffect(e3,tp)
		c:CreateEffectRelation(e3)
	end
	Duel.SpecialSummonComplete()
end
function s.eqval(ec,c,tp)
	return ec:IsSetCard(0x12b)
end
function s.eqcon(e,tp,eg,ep,ev,re,r,rp)
	local tc=e:GetLabelObject()
	if not tc or tc:GetFlagEffectLabel(id)~=e:GetLabel() then
		e:Reset()
		return false
	else return true end
end
function s.eqop(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_CARD,PLAYER_ALL,id)
	local c=e:GetHandler()
	local tc=e:GetLabelObject()
	if c:IsFaceup() and c:IsRelateToEffect(e) and Duel.GetLocationCount(tp,LOCATION_SZONE)>0 then
		Duel.Equip(tp,tc,c,true)
		local e1=Effect.CreateEffect(c)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetCode(EFFECT_EQUIP_LIMIT)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		e1:SetValue(s.eqlimit)
		e1:SetLabelObject(c)
		tc:RegisterEffect(e1)
	else
		Duel.SendtoGrave(tc,REASON_RULE)
	end
end
function s.eqlimit(e,c)
	return c==e:GetLabelObject()
end
function s.spcon2(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	return c:IsReason(REASON_BATTLE)
		or (rp~=tp and c:IsReason(REASON_EFFECT) and c:GetPreviousControler()==tp)
end
function s.spfilter2(c,e,tp)
	return c:IsSetCard(0x12b) and c:IsLinkBelow(3) and c:IsCanBeSpecialSummoned(e,0,tp,false,false)
end
function s.sptg2(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and Duel.IsExistingMatchingCard(s.spfilter2,tp,LOCATION_GRAVE,0,1,nil,e,tp) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_GRAVE)
end
function s.spop2(e,tp,eg,ep,ev,re,r,rp)
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local tc=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.spfilter2),tp,LOCATION_GRAVE,0,1,1,nil,e,tp):GetFirst()
	if tc then Duel.SpecialSummon(tc,0,tp,tp,false,false,POS_FACEUP) end
end
